//! WiFi Access Point with HTTP Server implementation for ESP-IDF
//!
//! This module provides a WiFi Access Point with an HTTP server.
//! Connect to the AP and go to 192.168.71.1 to access the server.

use core::convert::TryInto;
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
use std::{io, thread};
use std::time::Duration;

use log::info;

use serde::{Deserialize, Serialize};
use shared::fbdb::FileBasedDB;
use std::fs::{self, File, OpenOptions};
use std::io::{BufReader, BufWriter, Read as StdRead, Write as StdWrite};
use std::str::FromStr;
use std::sync::{Arc, Mutex};
use shared::model;

/// Wi-Fi channel, between 1 and 11
/// Channel 6 is often a good default as it's commonly used and supported
const CHANNEL: u8 = 6;

/// Max payload length for HTTP requests
const MAX_LEN: usize = 1024;

/// Stack size for HTTP server (needs to be large for JSON parsing)
const STACK_SIZE: usize = 20000; // 10240;

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
    time_start: &'a str,     // ISO 8601 timestamp
    time_end: &'a str,       // ISO 8601 timestamp
    post_uuids: Vec<String>, // List of UUIDs
}

#[derive(Debug, Serialize)]
struct PostsCompareResponse {
    totem_missing: Vec<String>,
    client_missing: Vec<String>,
}

/// Request structure for /users/compare endpoint
#[derive(Deserialize)]
struct UsersCompareRequest {
    user_uuids: Vec<String>, // List of UUIDs
}

#[derive(Serialize)]
struct UsersCompareResponse {
    totem_missing: Vec<String>,
    client_missing: Vec<String>,
}

/// Request structure for /users endpoint (create user)
#[derive(Deserialize)]
struct UserRequest {
    pub uuid: String,
    pub username: String,
    pub status: String,
    pub bio: String,
    pub profile_picture: Option<String>,
    // last_contact will be set to current time on creation
}

/// Request structure for /posts endpoint
#[derive(Deserialize)]
struct PostsRequest {
    pub uuid: String,
    pub user_id: String,
    pub status: String,
    pub bio: String,
    pub image: Option<String>,
    pub last_contact: Option<String>,


}

/// Request structure for /users/last_seen endpoint
#[derive(Deserialize)]
struct UsersLastSeenRequest {
    user_uuids: Vec<heapless::String<32>>, // List of UUIDs
}

/// Initialize WiFi Access Point and HTTP server with the given configuration
pub fn init_wifi(
    config: WifiConfig,
    modem: WifiModem,
    sys_loop: EspSystemEventLoop,
    nvs: EspDefaultNvsPartition,
    fbdb: Arc<Mutex<FileBasedDB>>,
) -> anyhow::Result<(BlockingWifi<EspWifi<'static>>, EspHttpServer<'static>)> {
    let mut wifi = BlockingWifi::wrap(EspWifi::new(modem, sys_loop.clone(), Some(nvs))?, sys_loop)?;

    connect_wifi(&mut wifi, &config)?;

    let mut server = create_server()?;

    // POST /posts/compare - Compare posts in a time range for a user
    {
        let mut fbdb = Arc::clone(&fbdb);
        server.fn_handler::<anyhow::Error, _>("/posts/compare", Method::Post, move |mut req| {
            let len = req.content_len().unwrap_or(0) as usize;

            if len > MAX_LEN * 10
            /* bigger MAX_LEN for multiple IDs */
            {
                req.into_status_response(413)?
                    .write_all("Request too big".as_bytes())?;
                return Ok(());
            }

            let mut buf = vec![0; len];
            req.read_exact(&mut buf)?;

            let log_str = String::from_utf8_lossy(&buf);
            let log_preview = log_str; // if log_str.len() > 100 { &log_str[..100] } else { &log_str };
            info!("POST /posts/compare - Input: {}", log_preview);


            if let Ok(data) = serde_json::from_slice::<PostsCompareRequest>(&buf) {
                // TODO: Implement posts comparison logic
                // For now, just acknowledge the request

                /*
                write!(
                    resp,
                    "TODO: Compare posts for user {} from {} to {} (count: {})",
                    data.user_id,
                    data.time_start,
                    data.time_end,
                    data.post_uuids.len()
                )?;

                 */

                let res = {
                    let mut db = fbdb.lock().unwrap();

                    firmware::data_exchange::exchange_posts(
                        // THIS explodes if there's no tz
                        &chrono::DateTime::from_str(data.time_start)?,
                        &chrono::DateTime::from_str(data.time_end)?,
                        data.post_uuids,
                        &mut *db,
                    )?
                };

                let res = PostsCompareResponse {
                    totem_missing: res.0,
                    client_missing: res.1,
                };

                info!("{:?}", res);

                req.into_ok_response()?.write_all(
                    serde_json::to_vec(&res)?
                    .as_slice(),
                )?;
            } else {
                req.into_status_response(400)?.write_all("JSON error".as_bytes())?;
            }

            Ok(())
        })?;
    }

    // POST /users/compare - Compare users
    {
        let mut fbdb = Arc::clone(&fbdb);
        server.fn_handler::<anyhow::Error, _>("/users/compare", Method::Post, move |mut req| {
            let len = req.content_len().unwrap_or(0) as usize;

            if len > MAX_LEN * 10
            /* bigger MAX_LEN for multiple IDs */
            {
                req.into_status_response(413)?
                    .write_all("Request too big".as_bytes())?;
                return Ok(());
            }

            let mut buf = vec![0; len];
            req.read_exact(&mut buf)?;

            let log_str = String::from_utf8_lossy(&buf);
            let log_preview = if log_str.len() > 100 { &log_str[..100] } else { &log_str };
            info!("POST /users/compare - Input: {}", log_preview);

            let mut resp = req.into_ok_response()?;

            if let Ok(data) = serde_json::from_slice::<UsersCompareRequest>(&buf) {
                let res = {
                    let mut db = fbdb.lock().unwrap();

                    firmware::data_exchange::exchange_users(
                        data.user_uuids,
                        &mut *db,
                    )?
                };

                resp.write_all(
                    serde_json::to_vec(&UsersCompareResponse {
                        totem_missing: res.0,
                        client_missing: res.1,
                    })?
                    .as_slice(),
                )?;
            } else {
                resp.write_all("JSON error".as_bytes())?;
            }

            Ok(())
        })?;
    }

    // POST /users - Create a new user
    {
        let mut fbdb = Arc::clone(&fbdb);
        server.fn_handler::<anyhow::Error, _>("/users/create", Method::Post, move |mut req| {
            let len = req.content_len().unwrap_or(0) as usize;

            if len > MAX_LEN * 2 {
                // Allow larger payload for user with bio and profile picture
                req.into_status_response(413)?
                    .write_all("Request too big".as_bytes())?;
                return Ok(());
            }

            let mut buf = vec![0; len];
            req.read_exact(&mut buf)?;

            let log_str = String::from_utf8_lossy(&buf);
            let log_preview = if log_str.len() > 100 { &log_str[..100] } else { &log_str };
            info!("POST /users/create - Input: {}", log_preview);

            if let Ok(data) = serde_json::from_slice::<UserRequest>(&buf) {
                let result = {
                    let mut db = fbdb.lock().unwrap();

                    // Create a new user using the complete User model
                    let new_user = shared::model::User {
                        uuid: data.uuid.clone(),
                        username: data.username.clone(),
                        status: data.status.clone(),
                        bio: data.bio.clone(),
                        profile_picture: data.profile_picture.clone(),
                        last_contact: chrono::Utc::now(),
                    };

                    db.write_user(&new_user)
                };

                match result {
                    Ok(_) => {
                        req.into_ok_response()?.write_all(format!("User {} created successfully", data.uuid).as_bytes())?;
                    }
                    Err(e) => {
                        info!("Error creating user: {:?}", e);
                        let mut resp = req.into_status_response(500)?;
                        write!(resp, "Failed to create user: {:?}", e)?;
                    }
                }
            } else {
                req.into_status_response(400)?.write_all("JSON error".as_bytes())?;
            }

            Ok(())
        })?;
    }

    // POST /posts - Receive a list of posts
    {
        let mut fbdb = Arc::clone(&fbdb);
        server.fn_handler::<anyhow::Error, _>("/posts/create", Method::Post, move |mut req| {
            let len = req.content_len().unwrap_or(0) as usize;

            if len > MAX_LEN * 10 {
                // Allow larger payload for multiple posts
                req.into_status_response(413)?
                    .write_all("Request too big".as_bytes())?;
                return Ok(());
            }

            let mut buf = vec![0; len];
            req.read_exact(&mut buf)?;

            let log_str = String::from_utf8_lossy(&buf);
            let log_preview = if log_str.len() > 100 { &log_str[..100] } else { &log_str };
            info!("POST /posts/create - Input: {}", log_preview);

            if let Ok(data) = serde_json::from_slice::<model::Post>(&buf) {
                // TODO: Implement posts storage logic
                // For now, just acknowledge the request
                let db = fbdb.lock().unwrap();
                db.write_post(&data)?;
                write!(req.into_ok_response()?, "Users saved.")?;
            } else {
                req.into_status_response(400)?.write_all("JSON error".as_bytes())?;
            }

            Ok(())
        })?;
    }

    // POST /pic/<filename> - Save picture to SD card with streaming
    server.fn_handler::<anyhow::Error, _>("/pic/*", Method::Post, |mut req| {
        // Extract filename from URI path (e.g., /pic/image.jpg -> image.jpg)
        let uri = req.uri();
        info!("POST /pic/* - URI: {}, Content-Length: {}", uri, req.content_len().unwrap_or(0));
        let filename = uri.strip_prefix("/pic/").unwrap_or("unknown.webp");

        // Sanitize filename to prevent path traversal
        let filename = filename.replace("..", "").replace("/", "");
        let filepath = format!("/sd/pic_{}", filename);
        log::info!("filename: {filename}, filepath: {filepath}");
        log::info!("readdir /sd: {:?}, readdir /sd/pics: {:?}", std::fs::read_dir("/sd"), std::fs::read_dir("/sd/pics"));

        // Ensure pics directory exists
        if let Err(_) = fs::create_dir_all("/sd/pics") {
            req.into_status_response(500)?
                .write_all("Failed to create pics directory".as_bytes())?;
            return Ok(());
        }

        let len = req.content_len().unwrap_or(0) as usize;

        fs::remove_file(&filepath).ok();  // ignore result. it's ok if the file didn't exist in the first place

        let f = File::open(&filepath);
        match f {
            Ok(f) => {
                ()
            }
            Err(_) => {
                info!("file not found");
            }
        }


        // Stream the file in chunks to avoid loading entire file into RAM
        match OpenOptions::new().create(true).write(true).truncate(true).open(&filepath)  {
            Ok(file) => {
                let mut writer = BufWriter::new(file);
                let mut total_written = 0;
                let chunk_size = 1024; // 1KB chunks
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
                        Ok(_) => break, // EOF
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
        info!("GET /pic/* - URI: {}", uri);
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

                let chunk_size = 1024; // 1KB chunks
                let mut buf = vec![0u8; chunk_size];
                let mut total_sent = 0;

                loop {
                    match reader.read(&mut buf) {
                        Ok(n) if n > 0 => {
                            resp.write_all(&buf[..n])?;
                            total_sent += n;
                        }
                        Ok(_) => break, // EOF
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

    // GET /users/<userId> - Get user by ID
    {
        let mut fbdb = Arc::clone(&fbdb);
        server.fn_handler::<anyhow::Error, _>("/users/*", Method::Get, move |req| {
            // Extract userId from URI path
            let uri = req.uri();
            info!("GET /users/* - URI: {}", uri);
            let user_id = uri.strip_prefix("/users/").unwrap_or("");

            if user_id.is_empty() {
                req.into_status_response(400)?
                    .write_all("User ID required".as_bytes())?;
                return Ok(());
            }

            let result = {
                let mut db = fbdb.lock().unwrap();

                // Read user by UUID using the filter_map method
                db.read_users_match(1, |u| u.uuid == user_id)
            };

            match result {
                Ok(users) => {
                    if let Some(user) = users.into_iter().next() {
                        // Return the complete User model as JSON
                        let mut resp = req.into_ok_response()?;
                        resp.write_all(serde_json::to_vec(&user)?.as_slice())?;
                    } else {
                        req.into_status_response(404)?
                            .write_all("User not found".as_bytes())?;
                    }
                }
                Err(e) => {
                    info!("Error reading user: {:?}", e);
                    let mut resp = req.into_status_response(500)?;
                    write!(resp, "Failed to read user: {:?}", e)?;
                }
            }

            Ok(())
        })?;
    }

    // GET /posts/<postId> - Get post by ID
    {
        let mut fbdb = Arc::clone(&fbdb);
        server.fn_handler::<anyhow::Error, _>("/posts/*", Method::Get, move |req| {
            // Extract postId from URI path
            let uri = req.uri();
            info!("GET /posts/* - URI: {}", uri);
            let post_id = uri.strip_prefix("/posts/").unwrap_or("");

            if post_id.is_empty() {
                req.into_status_response(400)?
                    .write_all("Post ID required".as_bytes())?;
                return Ok(());
            }

            let result = {
                let mut db = fbdb.lock().unwrap();

                // Read post by UUID using the filter_map method
                db.read_posts_match(1, |p| p.uuid == post_id)
            };

            match result {
                Ok(posts) => {
                    if let Some(post) = posts.into_iter().next() {
                        // Return the complete Post model as JSON
                        let mut resp = req.into_ok_response()?;
                        resp.write_all(serde_json::to_vec(&post)?.as_slice())?;
                    } else {
                        req.into_status_response(404)?
                            .write_all("Post not found".as_bytes())?;
                    }
                }
                Err(e) => {
                    info!("Error reading post: {:?}", e);
                    let mut resp = req.into_status_response(500)?;
                    write!(resp, "Failed to read post: {:?}", e)?;
                }
            }

            Ok(())
        })?;
    }

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

        let log_str = String::from_utf8_lossy(&buf);
        let log_preview = if log_str.len() > 100 { &log_str[..100] } else { &log_str };
        info!("POST /users/last_seen - Input: {}", log_preview);

        let mut resp = req.into_ok_response()?;

        if let Ok(data) = serde_json::from_slice::<UsersLastSeenRequest>(&buf) {
            // STUB: Acknowledge the request
            write!(
                resp,
                "STUB: Received last_seen for {} users",
                data.user_uuids.len()
            )?;
        } else {
            resp.write_all("JSON error".as_bytes())?;
        }

        Ok(())
    })?;

    // GET /is_totem - Simple endpoint to identify this device as a totem
    server.fn_handler::<anyhow::Error, _>("/is_totem", Method::Get, |req| {
        req.into_ok_response()?.write_all(b"OK")?;
        Ok(())
    })?;

    // Keep wifi and the server running beyond when main() returns (forever)
    // Do not call this if you ever want to stop or access them later.
    // core::mem::forget(wifi);
    // core::mem::forget(server);

    Ok((wifi, server))
}

fn connect_wifi(
    wifi: &mut BlockingWifi<EspWifi<'static>>,
    config: &WifiConfig,
) -> anyhow::Result<()> {
    info!(
        "Configuring WiFi AP with SSID: {}, Channel: {}",
        config.ssid, CHANNEL
    );

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
    unsafe {
        EspError::convert(esp_idf_hal::sys::esp_wifi_set_max_tx_power(
            34, /* 8.5dbm */
        ))?
    };

    wifi.wait_netif_up()?;
    info!("Wifi netif up");

    // Get and log the actual IP address
    let ip_info = wifi.wifi().ap_netif().get_ip_info()?;
    info!("AP IP Address: {}", ip_info.ip);

    info!(
        "Created Wi-Fi AP with SSID `{}` and password `{}`",
        config.ssid, config.password
    );

    Ok(())
}

fn create_server() -> anyhow::Result<EspHttpServer<'static>> {
    let server_configuration = esp_idf_svc::http::server::Configuration {
        stack_size: STACK_SIZE,
        uri_match_wildcard: true,
        ..Default::default()
    };

    Ok(EspHttpServer::new(&server_configuration)?)
}
