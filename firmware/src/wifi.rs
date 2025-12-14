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
