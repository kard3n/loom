use crate::model::{Post, Totem, User};
use std::fs::{self, File, OpenOptions};
use std::io::{self, BufReader, BufWriter, Read, Write};
use std::path::{Path, PathBuf};

/// File-based database that stores structs in append-only files
pub struct FileBasedDB {
    base_path: PathBuf,
}

impl FileBasedDB {
    /// Initialize the file-based database with the given folder path
    /// Creates all necessary directories
    pub fn init<P: AsRef<Path>>(folder_path: P) -> io::Result<Self> {
        let base_path = folder_path.as_ref().to_path_buf();
        fs::create_dir_all(&base_path)?;

        Ok(FileBasedDB { base_path })
    }

    /// Get the file path for a specific model type
    fn get_file_path(&self, filename: &str) -> PathBuf {
        self.base_path.join(filename)
    }

    /// Write a single user to the database
    pub fn write_user(&self, user: &User) -> io::Result<()> {
        self.write_users(&[user])
    }

    /// Write multiple users to the database
    pub fn write_users(&self, users: &[&User]) -> io::Result<()> {
        let path = self.get_file_path("users.bin");
        let file = OpenOptions::new()
            .create(true)
            .append(true)
            .open(path)?;

        let mut writer = BufWriter::new(file);

        for user in users {
            let serialized = postcard::to_allocvec(user)
                .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e))?;

            // Write length prefix (4 bytes) followed by data
            let len = serialized.len() as u32;
            writer.write_all(&len.to_le_bytes())?;
            writer.write_all(&serialized)?;
        }

        // Sync at the end
        writer.flush()?;
        writer.get_ref().sync_all()?;

        Ok(())
    }

    /// Write a single post to the database
    pub fn write_post(&self, post: &Post) -> io::Result<()> {
        self.write_posts(&[post])
    }

    /// Write multiple posts to the database
    pub fn write_posts(&self, posts: &[&Post]) -> io::Result<()> {
        let path = self.get_file_path("posts.bin");
        let file = OpenOptions::new()
            .create(true)
            .append(true)
            .open(path)?;

        let mut writer = BufWriter::new(file);

        for post in posts {
            let serialized = postcard::to_allocvec(post)
                .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e))?;

            // Write length prefix (4 bytes) followed by data
            let len = serialized.len() as u32;
            writer.write_all(&len.to_le_bytes())?;
            writer.write_all(&serialized)?;
        }

        // Sync at the end
        writer.flush()?;
        writer.get_ref().sync_all()?;

        Ok(())
    }

    /// Write a single totem to the database
    pub fn write_totem(&self, totem: &Totem) -> io::Result<()> {
        self.write_totems(&[totem])
    }

    /// Write multiple totems to the database
    pub fn write_totems(&self, totems: &[&Totem]) -> io::Result<()> {
        let path = self.get_file_path("totems.bin");
        let file = OpenOptions::new()
            .create(true)
            .append(true)
            .open(path)?;

        let mut writer = BufWriter::new(file);

        for totem in totems {
            let serialized = postcard::to_allocvec(totem)
                .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e))?;

            // Write length prefix (4 bytes) followed by data
            let len = serialized.len() as u32;
            writer.write_all(&len.to_le_bytes())?;
            writer.write_all(&serialized)?;
        }

        // Sync at the end
        writer.flush()?;
        writer.get_ref().sync_all()?;

        Ok(())
    }

    /// Read users from the database with a limit
    pub fn read_users(&self, limit: usize) -> io::Result<Vec<User>> {
        self.read_users_match(limit, |_| true)
    }

    /// Read users from the database that match the given predicate
    pub fn read_users_match<F>(&self, limit: usize, matcher: F) -> io::Result<Vec<User>>
    where
        F: Fn(&User) -> bool,
    {
        let path = self.get_file_path("users.bin");

        if !path.exists() {
            return Ok(Vec::new());
        }

        let file = File::open(path)?;
        let mut reader = BufReader::new(file);
        let mut results = Vec::new();
        let mut len_buf = [0u8; 4];

        while results.len() < limit {
            // Read length prefix
            match reader.read_exact(&mut len_buf) {
                Ok(_) => {},
                Err(e) if e.kind() == io::ErrorKind::UnexpectedEof => break,
                Err(e) => return Err(e),
            }

            let len = u32::from_le_bytes(len_buf) as usize;
            let mut data_buf = vec![0u8; len];
            reader.read_exact(&mut data_buf)?;

            let user: User = postcard::from_bytes(&data_buf)
                .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e))?;

            if matcher(&user) {
                results.push(user);
            }
        }

        Ok(results)
    }

    /// Read posts from the database with a limit
    pub fn read_posts(&self, limit: usize) -> io::Result<Vec<Post>> {
        self.read_posts_match(limit, |_| true)
    }

    /// Read posts from the database that match the given predicate
    pub fn read_posts_match<F>(&self, limit: usize, matcher: F) -> io::Result<Vec<Post>>
    where
        F: Fn(&Post) -> bool,
    {
        let path = self.get_file_path("posts.bin");

        if !path.exists() {
            return Ok(Vec::new());
        }

        let file = File::open(path)?;
        let mut reader = BufReader::new(file);
        let mut results = Vec::new();
        let mut len_buf = [0u8; 4];

        while results.len() < limit {
            // Read length prefix
            match reader.read_exact(&mut len_buf) {
                Ok(_) => {},
                Err(e) if e.kind() == io::ErrorKind::UnexpectedEof => break,
                Err(e) => return Err(e),
            }

            let len = u32::from_le_bytes(len_buf) as usize;
            let mut data_buf = vec![0u8; len];
            reader.read_exact(&mut data_buf)?;

            let post: Post = postcard::from_bytes(&data_buf)
                .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e))?;

            if matcher(&post) {
                results.push(post);
            }
        }

        Ok(results)
    }

    /// Read totems from the database with a limit
    pub fn read_totems(&self, limit: usize) -> io::Result<Vec<Totem>> {
        self.read_totems_match(limit, |_| true)
    }

    /// Read totems from the database that match the given predicate
    pub fn read_totems_match<F>(&self, limit: usize, matcher: F) -> io::Result<Vec<Totem>>
    where
        F: Fn(&Totem) -> bool,
    {
        let path = self.get_file_path("totems.bin");

        if !path.exists() {
            return Ok(Vec::new());
        }

        let file = File::open(path)?;
        let mut reader = BufReader::new(file);
        let mut results = Vec::new();
        let mut len_buf = [0u8; 4];

        while results.len() < limit {
            // Read length prefix
            match reader.read_exact(&mut len_buf) {
                Ok(_) => {},
                Err(e) if e.kind() == io::ErrorKind::UnexpectedEof => break,
                Err(e) => return Err(e),
            }

            let len = u32::from_le_bytes(len_buf) as usize;
            let mut data_buf = vec![0u8; len];
            reader.read_exact(&mut data_buf)?;

            let totem: Totem = postcard::from_bytes(&data_buf)
                .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e))?;

            if matcher(&totem) {
                results.push(totem);
            }
        }

        Ok(results)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::Utc;

    #[test]
    fn test_write_read_users() {
        let temp_dir = std::env::temp_dir().join("fbdb_test_users");
        let _ = fs::remove_dir_all(&temp_dir);

        let db = FileBasedDB::init(&temp_dir).unwrap();

        let user1 = User {
            uuid: "550e8400-e29b-41d4-a716-446655440000".to_string(),
            username: "alice".to_string(),
            status: "Online".to_string(),
            bio: "Test user 1".to_string(),
            profile_picture: Some("pic1.jpg".to_string()),
            last_contact: Utc::now(),
        };

        let user2 = User {
            uuid: "550e8400-e29b-41d4-a716-446655440001".to_string(),
            username: "bob".to_string(),
            status: "Offline".to_string(),
            bio: "Test user 2".to_string(),
            profile_picture: None,
            last_contact: Utc::now(),
        };

        db.write_user(&user1).unwrap();
        db.write_user(&user2).unwrap();

        let users = db.read_users(10).unwrap();
        assert_eq!(users.len(), 2);
        assert_eq!(users[0].username, "alice");
        assert_eq!(users[1].username, "bob");

        // Test with limit
        let users_limited = db.read_users(1).unwrap();
        assert_eq!(users_limited.len(), 1);
        assert_eq!(users_limited[0].username, "alice");

        // Test with matcher
        let online_users = db.read_users_match(10, |u| u.status == "Online").unwrap();
        assert_eq!(online_users.len(), 1);
        assert_eq!(online_users[0].username, "alice");

        let _ = fs::remove_dir_all(&temp_dir);
    }

    #[test]
    fn test_write_read_posts() {
        let temp_dir = std::env::temp_dir().join("fbdb_test_posts");
        let _ = fs::remove_dir_all(&temp_dir);

        let db = FileBasedDB::init(&temp_dir).unwrap();

        let post1 = Post {
            uuid: "123e4567-e89b-12d3-a456-426614174000".to_string(),
            user_id: "550e8400-e29b-41d4-a716-446655440000".to_string(),
            title: "First Post".to_string(),
            body: "This is the first post".to_string(),
            timestamp: Utc::now(),
            image: None,
            source_totem: None,
        };

        let post2 = Post {
            uuid: "123e4567-e89b-12d3-a456-426614174001".to_string(),
            user_id: "550e8400-e29b-41d4-a716-446655440000".to_string(),
            title: "Second Post".to_string(),
            body: "This is the second post".to_string(),
            timestamp: Utc::now(),
            image: Some("image.jpg".to_string()),
            source_totem: None,
        };

        db.write_posts(&[&post1, &post2]).unwrap();

        let posts = db.read_posts(10).unwrap();
        assert_eq!(posts.len(), 2);
        assert_eq!(posts[0].title, "First Post");
        assert_eq!(posts[1].title, "Second Post");

        // Test with matcher
        let posts_with_image = db.read_posts_match(10, |p| p.image.is_some()).unwrap();
        assert_eq!(posts_with_image.len(), 1);
        assert_eq!(posts_with_image[0].title, "Second Post");

        let _ = fs::remove_dir_all(&temp_dir);
    }

    #[test]
    fn test_write_read_totems() {
        let temp_dir = std::env::temp_dir().join("fbdb_test_totems");
        let _ = fs::remove_dir_all(&temp_dir);

        let db = FileBasedDB::init(&temp_dir).unwrap();

        let totem1 = Totem {
            uuid: "990e8400-e29b-41d4-a716-446655440011".to_string(),
            name: "Totem One".to_string(),
            location: "Location A".to_string(),
            last_contact: Utc::now(),
        };

        let totem2 = Totem {
            uuid: "990e8400-e29b-41d4-a716-446655440012".to_string(),
            name: "Totem Two".to_string(),
            location: "Location B".to_string(),
            last_contact: Utc::now(),
        };

        db.write_totem(&totem1).unwrap();
        db.write_totem(&totem2).unwrap();

        let totems = db.read_totems(10).unwrap();
        assert_eq!(totems.len(), 2);
        assert_eq!(totems[0].name, "Totem One");
        assert_eq!(totems[1].name, "Totem Two");

        let _ = fs::remove_dir_all(&temp_dir);
    }
}
