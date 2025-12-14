//! WiFi Access Point with HTTP Server implementation for ESP-IDF
//!
//! This module provides a WiFi Access Point with an HTTP server.
//! Connect to the AP and go to 192.168.71.1 to access the server.

use core::convert::TryInto;
use std::thread;
use std::time::Duration;
use embedded_svc::{
    http::{Headers, Method},
    io::{Read, Write},
    wifi::{self, AccessPointConfiguration, AuthMethod},
};
use esp_idf_hal::modem::WifiModem;
use esp_idf_hal::sys::EspError;
use esp_idf_svc::hal::modem::Modem;
use esp_idf_svc::{
    eventloop::EspSystemEventLoop,
    http::server::EspHttpServer,
    nvs::EspDefaultNvsPartition,
    wifi::{BlockingWifi, EspWifi},
};

use log::info;

use serde::Deserialize;
use std::fs::{self, File, OpenOptions};
use std::io::{BufReader, BufWriter, Read as StdRead};

/// Wi-Fi channel, between 1 and 11
/// Channel 6 is often a good default as it's commonly used and supported
const CHANNEL: u8 = 6;

/// Max payload length for HTTP requests
const MAX_LEN: usize = 128;

/// Stack size for HTTP server (needs to be large for JSON parsing)
const STACK_SIZE: usize = 10240;

static INDEX_HTML: &str = include_str!("http_server_page.html");

/// Configuration for the WiFi Access Point
pub struct WifiConfig {
    /// SSID for the Access Point
    pub ssid: String,
    /// Password for the Access Point (WPA2)
    pub password: String,
}

#[derive(Deserialize)]
struct FormData<'a> {
    first_name: &'a str,
    age: u32,
    birthplace: &'a str,
}

/// Request structure for /posts/compare endpoint
#[derive(Deserialize)]
struct PostsCompareRequest<'a> {
    time_start: &'a str,  // ISO 8601 timestamp
    time_end: &'a str,    // ISO 8601 timestamp
    user_id: &'a str,     // UUID
    post_uuids: Vec<&'a str>,  // List of UUIDs
}

/// Request structure for /posts endpoint
#[derive(Deserialize)]
struct PostsRequest<'a> {
    posts: Vec<serde_json::Value>,  // List of post objects
}

/// Request structure for /users/last_seen endpoint
#[derive(Deserialize)]
struct UsersLastSeenRequest<'a> {
    user_uuids: Vec<&'a str>,  // List of UUIDs
}

/// Initialize WiFi Access Point and HTTP server with the given configuration
pub fn init_wifi(
    config: WifiConfig,
    modem: WifiModem,
    sys_loop: EspSystemEventLoop,
    nvs: EspDefaultNvsPartition,
) -> anyhow::Result<(BlockingWifi<EspWifi<'static>>,EspHttpServer<'static>)> {
    let mut wifi = BlockingWifi::wrap(
        EspWifi::new(modem, sys_loop.clone(), Some(nvs))?,
        sys_loop,
    )?;

    connect_wifi(&mut wifi, &config)?;

    let mut server = create_server()?;

    server.fn_handler("/", Method::Get, |req| {
        req.into_ok_response()?
            .write_all(INDEX_HTML.as_bytes())
            .map(|_| ())
    })?;

    server.fn_handler::<anyhow::Error, _>("/post", Method::Post, |mut req| {
        let len = req.content_len().unwrap_or(0) as usize;

        if len > MAX_LEN {
            req.into_status_response(413)?
                .write_all("Request too big".as_bytes())?;
            return Ok(());
        }

        let mut buf = vec![0; len];
        req.read_exact(&mut buf)?;
        let mut resp = req.into_ok_response()?;

        if let Ok(form) = serde_json::from_slice::<FormData>(&buf) {
            write!(
                resp,
                "Hello, {}-year-old {} from {}!",
                form.age, form.first_name, form.birthplace
            )?;
        } else {
            resp.write_all("JSON error".as_bytes())?;
        }

        Ok(())
    })?;

    // POST /posts/compare - Compare posts in a time range for a user
    server.fn_handler::<anyhow::Error, _>("/posts/compare", Method::Post, |mut req| {
        let len = req.content_len().unwrap_or(0) as usize;

        if len > MAX_LEN {
            req.into_status_response(413)?
                .write_all("Request too big".as_bytes())?;
            return Ok(());
        }

        let mut buf = vec![0; len];
        req.read_exact(&mut buf)?;
        let mut resp = req.into_ok_response()?;

        if let Ok(data) = serde_json::from_slice::<PostsCompareRequest>(&buf) {
            // TODO: Implement posts comparison logic
            // For now, just acknowledge the request
            write!(
                resp,
                "TODO: Compare posts for user {} from {} to {} (count: {})",
                data.user_id, data.time_start, data.time_end, data.post_uuids.len()
            )?;
        } else {
            resp.write_all("JSON error".as_bytes())?;
        }

        Ok(())
    })?;

    // POST /posts - Receive a list of posts
    server.fn_handler::<anyhow::Error, _>("/posts", Method::Post, |mut req| {
        let len = req.content_len().unwrap_or(0) as usize;

        if len > MAX_LEN * 10 {  // Allow larger payload for multiple posts
            req.into_status_response(413)?
                .write_all("Request too big".as_bytes())?;
            return Ok(());
        }

        let mut buf = vec![0; len];
        req.read_exact(&mut buf)?;
        let mut resp = req.into_ok_response()?;

        if let Ok(data) = serde_json::from_slice::<PostsRequest>(&buf) {
            // TODO: Implement posts storage logic
            // For now, just acknowledge the request
            write!(resp, "TODO: Received {} posts", data.posts.len())?;
        } else {
            resp.write_all("JSON error".as_bytes())?;
        }

        Ok(())
    })?;

    // POST /pic/<filename> - Save picture to SD card with streaming
    server.fn_handler::<anyhow::Error, _>("/pic/*", Method::Post, |mut req| {
        // Extract filename from URI path (e.g., /pic/image.jpg -> image.jpg)
        let uri = req.uri();
        let filename = uri.strip_prefix("/pic/").unwrap_or("unknown.jpg");

        // Sanitize filename to prevent path traversal
        let filename = filename.replace("..", "").replace("/", "");
        let filepath = format!("/sd/pics/{}", filename);

        // Ensure pics directory exists
        if let Err(_) = fs::create_dir_all("/sd/pics") {
            req.into_status_response(500)?
                .write_all("Failed to create pics directory".as_bytes())?;
            return Ok(());
        }

        let len = req.content_len().unwrap_or(0) as usize;

        // Stream the file in chunks to avoid loading entire file into RAM
        match File::create(&filepath) {
            Ok(file) => {
                let mut writer = BufWriter::new(file);
                let mut total_written = 0;
                let chunk_size = 1024;  // 1KB chunks
                let mut buf = vec![0u8; chunk_size];

                loop {
                    let to_read = std::cmp::min(chunk_size, len - total_written);
                    if to_read == 0 {
                        break;
                    }

                    match req.read(&mut buf[..to_read]) {
                        Ok(n) if n > 0 => {
                            writer.write_all(&buf[..n])?;
                            total_written += n;
                        }
                        Ok(_) => break,  // EOF
                        Err(e) => {
                            info!("Error reading request: {:?}", e);
                            break;
                        }
                    }
                }

                let mut resp = req.into_ok_response()?;
                write!(resp, "Saved {} bytes to {}", total_written, filepath)?;
            }
            Err(e) => {
                let mut resp = req.into_status_response(500)?;
                write!(resp, "Failed to create file: {:?}", e)?;
            }
        }

        Ok(())
    })?;

    // GET /pic/<filename> - Send picture from SD card with streaming
    server.fn_handler::<anyhow::Error, _>("/pic/*", Method::Get, |req| {
        // Extract filename from URI path
        let uri = req.uri();
        let filename = uri.strip_prefix("/pic/").unwrap_or("");

        if filename.is_empty() {
            req.into_status_response(400)?
                .write_all("Filename required".as_bytes())?;
            return Ok(());
        }

        // Sanitize filename to prevent path traversal
        let filename = filename.replace("..", "").replace("/", "");
        let filepath = format!("/sd/pics/{}", filename);

        // Stream the file in chunks to avoid loading entire file into RAM
        match File::open(&filepath) {
            Ok(file) => {
                let metadata = file.metadata()?;
                let file_size = metadata.len();

                let mut reader = BufReader::new(file);
                let mut resp = req.into_ok_response()?;

                let chunk_size = 1024;  // 1KB chunks
                let mut buf = vec![0u8; chunk_size];
                let mut total_sent = 0;

                loop {
                    match reader.read(&mut buf) {
                        Ok(n) if n > 0 => {
                            resp.write_all(&buf[..n])?;
                            total_sent += n;
                        }
                        Ok(_) => break,  // EOF
                        Err(e) => {
                            info!("Error reading file: {:?}", e);
                            break;
                        }
                    }
                }

                info!("Sent {} bytes of {}", total_sent, filepath);
            }
            Err(_) => {
                req.into_status_response(404)?
                    .write_all("File not found".as_bytes())?;
            }
        }

        Ok(())
    })?;

    // POST /users/last_seen - Update last seen timestamps for users
    server.fn_handler::<anyhow::Error, _>("/users/last_seen", Method::Post, |mut req| {
        let len = req.content_len().unwrap_or(0) as usize;

        if len > MAX_LEN {
            req.into_status_response(413)?
                .write_all("Request too big".as_bytes())?;
            return Ok(());
        }

        let mut buf = vec![0; len];
        req.read_exact(&mut buf)?;
        let mut resp = req.into_ok_response()?;

        if let Ok(data) = serde_json::from_slice::<UsersLastSeenRequest>(&buf) {
            // STUB: Acknowledge the request
            write!(resp, "STUB: Received last_seen for {} users", data.user_uuids.len())?;
        } else {
            resp.write_all("JSON error".as_bytes())?;
        }

        Ok(())
    })?;

    // Keep wifi and the server running beyond when main() returns (forever)
    // Do not call this if you ever want to stop or access them later.
    // core::mem::forget(wifi);
    // core::mem::forget(server);


    Ok((wifi, server))
}

fn connect_wifi(wifi: &mut BlockingWifi<EspWifi<'static>>, config: &WifiConfig) -> anyhow::Result<()> {
    info!("Configuring WiFi AP with SSID: {}, Channel: {}", config.ssid, CHANNEL);
    
    let wifi_configuration = wifi::Configuration::AccessPoint(AccessPointConfiguration {
        ssid: config.ssid.as_str().try_into().unwrap(),
        ssid_hidden: false,
        auth_method: AuthMethod::WPA2Personal,
        password: config.password.as_str().try_into().unwrap(),
        channel: CHANNEL,
        ..Default::default()
    });

    wifi.set_configuration(&wifi_configuration)?;
    info!("WiFi configuration set successfully");

    wifi.start()?;
    info!("Wifi started");

    info!("setting max tx power to 34 (8.5dbm)");
    unsafe { EspError::convert(esp_idf_hal::sys::esp_wifi_set_max_tx_power(34 /* 8.5dbm */ ))? };

    wifi.wait_netif_up()?;
    info!("Wifi netif up");

    // Get and log the actual IP address
    let ip_info = wifi.wifi().ap_netif().get_ip_info()?;
    info!("AP IP Address: {}", ip_info.ip);

    info!("Created Wi-Fi AP with SSID `{}` and password `{}`", config.ssid, config.password);

    Ok(())
}

fn create_server() -> anyhow::Result<EspHttpServer<'static>> {
    let server_configuration = esp_idf_svc::http::server::Configuration {
        stack_size: STACK_SIZE,
        ..Default::default()
    };

    Ok(EspHttpServer::new(&server_configuration)?)
}
