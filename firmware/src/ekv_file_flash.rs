use core::convert::Infallible;
use ekv::flash::PageID;

#[cfg(feature = "std")]
use std::{
    fs::{self, File, OpenOptions},
    io::{Read, Seek, SeekFrom, Write},
    path::{Path, PathBuf},
};

/// One big file = all pages back-to-back.
/// Layout:
///   offset = page_id.index() * page_size + offset_in_page
///
/// Notes:
/// - This is blocking I/O inside async fns (fine on many embedded setups, but it WILL block the executor).
/// - Erased state is 0xFF. We ensure new files are filled with 0xFF.
/// - Optional "flash bit semantics" check (1->0 only) behind a feature.
#[cfg(feature = "std")]
pub struct PageFileFlash {
    path: PathBuf,
    file: File,
    page_count: usize,
    page_size: usize,

    // Scratch buffers to avoid re-allocations.
    erase_buf: Vec<u8>,
    #[cfg(feature = "enforce_flash_bits")]
    old_buf: Vec<u8>,
}

#[cfg(feature = "std")]
impl PageFileFlash {
    pub fn open_or_create(
        path: impl Into<PathBuf>,
        page_count: usize,
        page_size: usize,
    ) -> Result<Self, Infallible> {
        let path = path.into();
        if let Some(parent) = path.parent() {
            let _ = fs::create_dir_all(parent);
        }

        let mut file = OpenOptions::new()
            .create(true)
            .read(true)
            .write(true)
            .open(&path)
            .unwrap();

        let expected_len = (page_count as u64) * (page_size as u64);
        let current_len = file.metadata().unwrap().len();

        if current_len != expected_len {
            // Reinitialize to exact size and fill with erased bytes (0xFF).
            file.set_len(expected_len).unwrap();
            file.seek(SeekFrom::Start(0)).unwrap();
            Self::fill_with_ff(&mut file, expected_len as usize);
            file.flush().unwrap();
            #[cfg(feature = "durable")]
            file.sync_all().unwrap();
        }

        // Choose a chunk size that’s friendly to SD/FAT and stack.
        let chunk = 4096usize.min(page_size.max(512));
        let erase_buf = vec![0xFFu8; chunk];

        Ok(Self {
            path,
            file,
            page_count,
            page_size,
            erase_buf,
            #[cfg(feature = "enforce_flash_bits")]
            old_buf: Vec::new(),
        })
    }

    fn addr(&self, page_id: PageID, offset: usize) -> u64 {
        let page_idx = page_id.index();
        assert!(page_idx < self.page_count);
        assert!(offset <= self.page_size);
        (page_idx as u64) * (self.page_size as u64) + (offset as u64)
    }

    fn ensure_bounds(&self, page_id: PageID, offset: usize, len: usize) {
        let page_idx = page_id.index();
        assert!(page_idx < self.page_count);
        assert!(offset <= self.page_size);
        assert!(offset + len <= self.page_size);
    }

    fn fill_with_ff(file: &mut File, total: usize) {
        const BUF_SZ: usize = 8192;
        let buf = [0xFFu8; BUF_SZ];
        let mut remaining = total;
        while remaining > 0 {
            let n = remaining.min(BUF_SZ);
            file.write_all(&buf[..n]).unwrap();
            remaining -= n;
        }
    }

    fn write_ff_range(&mut self, start: u64, len: usize) {
        self.file.seek(SeekFrom::Start(start)).unwrap();

        let mut remaining = len;
        while remaining > 0 {
            let n = remaining.min(self.erase_buf.len());
            self.file.write_all(&self.erase_buf[..n]).unwrap();
            remaining -= n;
        }

        self.file.flush().unwrap();
        #[cfg(feature = "durable")]
        self.file.sync_data().unwrap();
    }
}

#[cfg(feature = "std")]
impl ekv::flash::Flash for PageFileFlash {
    type Error = Infallible;

    fn page_count(&self) -> usize {
        self.page_count
    }

    async fn erase(&mut self, page_id: PageID) -> Result<(), Self::Error> {
        // “Erase page” = fill page range with 0xFF
        let start = self.addr(page_id, 0);
        self.write_ff_range(start, self.page_size);
        Ok(())
    }

    async fn read(
        &mut self,
        page_id: PageID,
        offset: usize,
        data: &mut [u8],
    ) -> Result<(), Self::Error> {
        self.ensure_bounds(page_id, offset, data.len());

        let pos = self.addr(page_id, offset);
        self.file.seek(SeekFrom::Start(pos)).unwrap();
        self.file.read_exact(data).unwrap();
        Ok(())
    }

    async fn write(
        &mut self,
        page_id: PageID,
        offset: usize,
        data: &[u8],
    ) -> Result<(), Self::Error> {
        self.ensure_bounds(page_id, offset, data.len());

        #[cfg(feature = "enforce_flash_bits")]
        {
            // Enforce “flash-like” semantics: only 1->0 transitions without erase.
            self.old_buf.resize(data.len(), 0);
            let pos = self.addr(page_id, offset);
            self.file.seek(SeekFrom::Start(pos)).unwrap();
            self.file.read_exact(&mut self.old_buf).unwrap();

            for (i, (&old, &new)) in self.old_buf.iter().zip(data.iter()).enumerate() {
                if (old & new) != new {
                    panic!(
                        "write violates flash bit rules at page {}, off {}+{}: old=0x{:02x}, new=0x{:02x}",
                        page_id.index(),
                        offset,
                        i,
                        old,
                        new
                    );
                }
            }
        }

        let pos = self.addr(page_id, offset);
        self.file.seek(SeekFrom::Start(pos)).unwrap();
        self.file.write_all(data).unwrap();
        self.file.flush().unwrap();
        #[cfg(feature = "durable")]
        self.file.sync_data().unwrap();

        Ok(())
    }
}

