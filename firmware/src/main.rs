mod ble;
mod wifi;
mod util;

use ble::TotemBleConfig;
use esp_idf_hal::gpio::{AnyIOPin, AnyInputPin, AnyOutputPin, IOPin};
use esp_idf_hal::prelude::*;
use esp_idf_hal::sd::spi::SdSpiHostDriver;
use esp_idf_hal::sd::{SdCardConfiguration, SdCardDriver};
use esp_idf_hal::spi::{Dma, SpiDriver, SpiDriverConfig, SPI1, SPI2};
use esp_idf_hal::sys::esp_vfs_fat_sdspi_mount;
use esp_idf_svc::eventloop::EspSystemEventLoop;
use esp_idf_svc::fs::fatfs::Fatfs;
use esp_idf_svc::io::vfs::MountedFatfs;
use esp_idf_svc::nvs::EspDefaultNvsPartition;
use std::fs;
use std::fs::File;
use std::io::Read;
use std::path::Path;
use std::thread::{sleep, Thread};
use std::time::Duration;
use wifi::WifiConfig;
use crate::util::{get_chip_serial, mac_to_id_and_pass};

fn walk_dir_depth_limited(path: &Path, depth: usize, max_depth: usize) {
    if depth > max_depth {
        return;
    }

    let indent = "  ".repeat(depth);
    let read_dir = match fs::read_dir(path) {
        Ok(rd) => rd,
        Err(e) => {
            log::warn!("{}cannot read dir {}: {}", indent, path.display(), e);
            return;
        }
    };

    for entry in read_dir {
        let entry = match entry {
            Ok(e) => e,
            Err(e) => {
                log::warn!(
                    "{}read_dir entry error in {}: {}",
                    indent,
                    path.display(),
                    e
                );
                continue;
            }
        };

        let entry_path = entry.path();
        let file_name = entry.file_name();
        let file_name = file_name.to_string_lossy();

        let is_dir = entry.file_type().map(|t| t.is_dir()).unwrap_or(false);

        if is_dir {
            log::info!("{}[D] {}/", indent, file_name);
            walk_dir_depth_limited(&entry_path, depth + 1, max_depth);
        } else {
            log::info!("{}[F] {}", indent, file_name);
        }
    }
}

fn main() -> anyhow::Result<()> {
    // It is necessary to call this function once. Otherwise, some patches to the runtime
    // implemented by esp-idf-sys might not link properly. See https://github.com/esp-rs/esp-idf-template/issues/71
    esp_idf_svc::sys::link_patches();

    // Bind the log crate to the ESP Logging facilities
    esp_idf_svc::log::EspLogger::initialize_default();

    log::info!("Hello, world!");

    let peripherals = Peripherals::take()?;

    let (wifi_modem, bt_modem) = peripherals.modem.split();


    log::info!("Initializing BLE...");

    let nvs = EspDefaultNvsPartition::take()?;

    let (ssid, pass) = mac_to_id_and_pass(get_chip_serial()?);
    let ssid = format!("Totem-{ssid}");

    let ble_server = ble::init_ble(
        TotemBleConfig {
            device_name: ssid.clone(),
            totem_id: ssid.clone(),
            totem_name: ssid.clone(),
            wifi_ssid: ssid.clone(),
            wifi_pass: pass.clone(),
        },
        bt_modem,
        nvs.clone(),
    )?;


    let sys_loop = EspSystemEventLoop::take()?;

    // Initialize WiFi Access Point and HTTP server
    // Note: BLE and WiFi share the modem - use one or the other
    log::info!("Initializing WiFi AP...");
    let (wifi, server) = wifi::init_wifi(
        WifiConfig {
            ssid,
            password: pass,
        },
        wifi_modem,
        sys_loop.clone(),
        nvs.clone(),
    )?;


    log::info!("Setting up sd card...");
    let spi = peripherals.spi2;

    let sclk = peripherals.pins.gpio4;
    let serial_in = peripherals.pins.gpio5; // SDI
    let serial_out = peripherals.pins.gpio6; // SDO
    let cs = peripherals.pins.gpio7;

    let driver = SpiDriver::new::<SPI2>(
        spi,
        sclk,
        serial_out,
        Some(serial_in),
        &SpiDriverConfig::new().dma(Dma::Auto(4096)),
    )?;
    let sd_spi_host_driver = SdSpiHostDriver::new(
        driver,
        Some(cs),
        None::<AnyIOPin>,
        None::<AnyIOPin>,
        None::<AnyIOPin>,
        None,
    )?;

    log::info!("ckpt1");
    let sd_config = SdCardConfiguration::default();
    log::info!("ckpt2");

    let sd_spi_driver = SdCardDriver::new_spi(sd_spi_host_driver, &sd_config)?;

    let _mounted_fatfs = MountedFatfs::mount(Fatfs::new_sdcard(0, sd_spi_driver)?, "/sd", 4)?;

    log::info!("ckpt3");

    log::info!("inited");
    // Read "/" and walk it to a depth of 2
    log::info!("walking / (depth <= 2) ...");
    walk_dir_depth_limited(Path::new("/sd"), 0, 1);

    {
        let mut file = File::open("/sd/test.txt")?;

        log::info!("File {file:?} opened");

        let mut file_content = String::new();

        file.read_to_string(&mut file_content).expect("Read failed");

        log::info!("File {file:?} read: {file_content}");
    }



    loop {
        sleep(Duration::from_millis(1000));
        // let wifi_up = wifi.is_up()?;
        // log::info!("is wifi up: {wifi_up}");
    }
    Ok(())
}
