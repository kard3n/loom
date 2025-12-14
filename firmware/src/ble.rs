//! BLE GATT server implementation for ESP-IDF
//!
//! This module provides a BLE GATT server with a Totem info service containing
//! read-only characteristics for device identification and WiFi credentials.

use std::sync::{Arc, Mutex};

use enumset::enum_set;
use esp_idf_hal::modem::BluetoothModem;
use esp_idf_svc::bt::ble::gap::{AdvConfiguration, BleGapEvent, EspBleGap};
use esp_idf_svc::bt::ble::gatt::server::{ConnectionId, EspGatts, GattsEvent};
use esp_idf_svc::bt::ble::gatt::{
    AutoResponse, GattCharacteristic, GattId, GattInterface,
    GattServiceId, GattStatus, Handle, Permission, Property,
};
use esp_idf_svc::bt::{BdAddr, Ble, BtDriver, BtStatus, BtUuid};
use esp_idf_svc::hal::peripherals::Peripherals;
use esp_idf_svc::nvs::EspDefaultNvsPartition;
use esp_idf_svc::sys::{EspError, ESP_FAIL};

use log::warn;

/// Configuration for the Totem BLE GATT server
pub struct TotemBleConfig {
    /// BLE advertised device name
    pub device_name: String,
    /// Totem ID characteristic value (max 64 chars)
    pub totem_id: String,
    /// Totem name characteristic value (max 64 chars)
    pub totem_name: String,
    /// WiFi SSID characteristic value (max 64 chars)
    pub wifi_ssid: String,
    /// WiFi password characteristic value (max 64 chars)
    pub wifi_pass: String,
}

/// Initialize and start the BLE GATT server with the given configuration
pub fn init_ble(config: TotemBleConfig, modem: BluetoothModem, nvs: EspDefaultNvsPartition) -> anyhow::Result<TotemServer> {

    let bt = Arc::new(BtDriver::new(modem, Some(nvs))?);

    let server = TotemServer::new(
        Arc::new(EspBleGap::new(bt.clone())?),
        Arc::new(EspGatts::new(bt.clone())?),
        config,
    );

    log::info!("BLE Gap and Gatts initialized");

    let gap_server = server.clone();

    server.gap.subscribe(move |event| {
        gap_server.check_esp_status(gap_server.on_gap_event(event));
    })?;

    let gatts_server = server.clone();

    server.gatts.subscribe(move |(gatt_if, event)| {
        gatts_server.check_esp_status(gatts_server.on_gatts_event(gatt_if, event))
    })?;

    log::info!("BLE Gap and Gatts subscriptions initialized");

    server.gatts.register_app(APP_ID)?;

    log::info!("Gatts BLE app registered");

    Ok(server)
}

const APP_ID: u16 = 0;
const MAX_CONNECTIONS: usize = 2;
const MAX_CHAR_LEN: usize = 64;

/// Totem info service UUID: e5d63081-6e16-427b-8ae3-66fdffafa604
pub const SERVICE_UUID: u128 = 0xe5d630816e16427b8ae366fdffafa604;

/// totem_id characteristic UUID: e5d63082-6e16-427b-8ae3-66fdffafa604
pub const TOTEM_ID_UUID: u128 = 0xe5d630826e16427b8ae366fdffafa604;
/// totem_name characteristic UUID: e5d63083-6e16-427b-8ae3-66fdffafa604
pub const TOTEM_NAME_UUID: u128 = 0xe5d630836e16427b8ae366fdffafa604;
/// totem_wifi_ssid characteristic UUID: e5d63084-6e16-427b-8ae3-66fdffafa604
pub const TOTEM_WIFI_SSID_UUID: u128 = 0xe5d630846e16427b8ae366fdffafa604;
/// totem_wifi_pass characteristic UUID: e5d63085-6e16-427b-8ae3-66fdffafa604
pub const TOTEM_WIFI_PASS_UUID: u128 = 0xe5d630856e16427b8ae366fdffafa604;

type TotemBtDriver = BtDriver<'static, Ble>;
type TotemEspBleGap = Arc<EspBleGap<'static, Ble, Arc<TotemBtDriver>>>;
type TotemEspGatts = Arc<EspGatts<'static, Ble, Arc<TotemBtDriver>>>;

#[derive(Debug, Clone)]
struct Connection {
    peer: BdAddr,
    conn_id: Handle,
    mtu: Option<u16>,
}

struct State {
    gatt_if: Option<GattInterface>,
    service_handle: Option<Handle>,
    connections: heapless::Vec<Connection, MAX_CONNECTIONS>,
}

impl Default for State {
    fn default() -> Self {
        Self {
            gatt_if: None,
            service_handle: None,
            connections: heapless::Vec::new(),
        }
    }
}

#[derive(Clone)]
pub struct TotemServer {
    gap: TotemEspBleGap,
    gatts: TotemEspGatts,
    state: Arc<Mutex<State>>,
    config: Arc<TotemBleConfig>,
}

impl TotemServer {
    pub fn new(gap: TotemEspBleGap, gatts: TotemEspGatts, config: TotemBleConfig) -> Self {
        Self {
            gap,
            gatts,
            state: Arc::new(Mutex::new(Default::default())),
            config: Arc::new(config),
        }
    }
}

impl TotemServer {
    /// The main event handler for the GAP events
    fn on_gap_event(&self, event: BleGapEvent) -> Result<(), EspError> {
        log::info!("GAP event received");

        if let BleGapEvent::AdvertisingConfigured(status) = event {
            self.check_bt_status(status)?;
            self.gap.start_advertising()?;
        }

        Ok(())
    }

    /// The main event handler for the GATTS events
    fn on_gatts_event(
        &self,
        gatt_if: GattInterface,
        event: GattsEvent,
    ) -> Result<(), EspError> {
        match event {
            GattsEvent::ServiceRegistered { status, app_id } => {
                self.check_gatt_status(status)?;
                if APP_ID == app_id {
                    self.create_service(gatt_if)?;
                }
            }
            GattsEvent::ServiceCreated {
                status,
                service_handle,
                ..
            } => {
                self.check_gatt_status(status)?;
                self.configure_and_start_service(service_handle)?;
            }
            GattsEvent::CharacteristicAdded { status, .. } => {
                self.check_gatt_status(status)?;
            }
            GattsEvent::ServiceDeleted {
                status,
                service_handle,
            } => {
                self.check_gatt_status(status)?;
                self.delete_service(service_handle)?;
            }
            GattsEvent::ServiceUnregistered {
                status,
                service_handle,
                ..
            } => {
                self.check_gatt_status(status)?;
                self.unregister_service(service_handle)?;
            }
            GattsEvent::Mtu { conn_id, mtu } => {
                self.register_conn_mtu(conn_id, mtu)?;
            }
            GattsEvent::PeerConnected { conn_id, addr, .. } => {
                self.create_conn(conn_id, addr)?;
            }
            GattsEvent::PeerDisconnected { addr, .. } => {
                self.delete_conn(addr)?;
            }
            _ => (),
        }

        Ok(())
    }

    /// Set the advertising configuration
    fn set_adv_conf(&self) -> Result<(), EspError> {
        self.gap.set_adv_conf(&AdvConfiguration {
            include_name: true,
            include_txpower: true,
            flag: 2,
            service_uuid: Some(BtUuid::uuid128(SERVICE_UUID)),
            ..Default::default()
        })
    }

    /// Create the service and start advertising
    fn create_service(&self, gatt_if: GattInterface) -> Result<(), EspError> {
        self.state.lock().unwrap().gatt_if = Some(gatt_if);

        self.gap.set_device_name(&self.config.device_name)?;
        self.set_adv_conf()?;
        self.gatts.create_service(
            gatt_if,
            &GattServiceId {
                id: GattId {
                    uuid: BtUuid::uuid128(SERVICE_UUID),
                    inst_id: 0,
                },
                is_primary: true,
            },
            16, // Enough handles for 4 characteristics
        )?;

        Ok(())
    }

    /// Delete the service
    fn delete_service(&self, service_handle: Handle) -> Result<(), EspError> {
        let state = self.state.lock().unwrap();
        if state.service_handle == Some(service_handle) {
            // Service deleted, nothing else to clean up
        }
        Ok(())
    }

    /// Unregister the service
    fn unregister_service(&self, service_handle: Handle) -> Result<(), EspError> {
        let mut state = self.state.lock().unwrap();

        if state.service_handle == Some(service_handle) {
            state.gatt_if = None;
            state.service_handle = None;
        }

        Ok(())
    }

    /// Configure and start the service, adding all characteristics
    fn configure_and_start_service(&self, service_handle: Handle) -> Result<(), EspError> {
        self.state.lock().unwrap().service_handle = Some(service_handle);

        self.gatts.start_service(service_handle)?;
        self.add_characteristics(service_handle)?;

        Ok(())
    }

    /// Add all four READ-only characteristics to the service
    fn add_characteristics(&self, service_handle: Handle) -> Result<(), EspError> {
        // totem_id
        self.gatts.add_characteristic(
            service_handle,
            &GattCharacteristic {
                uuid: BtUuid::uuid128(TOTEM_ID_UUID),
                permissions: enum_set!(Permission::Read),
                properties: enum_set!(Property::Read),
                max_len: MAX_CHAR_LEN,
                auto_rsp: AutoResponse::ByGatt,
            },
            self.config.totem_id.as_bytes(),
        )?;

        // totem_name
        self.gatts.add_characteristic(
            service_handle,
            &GattCharacteristic {
                uuid: BtUuid::uuid128(TOTEM_NAME_UUID),
                permissions: enum_set!(Permission::Read),
                properties: enum_set!(Property::Read),
                max_len: MAX_CHAR_LEN,
                auto_rsp: AutoResponse::ByGatt,
            },
            self.config.totem_name.as_bytes(),
        )?;

        // totem_wifi_ssid
        self.gatts.add_characteristic(
            service_handle,
            &GattCharacteristic {
                uuid: BtUuid::uuid128(TOTEM_WIFI_SSID_UUID),
                permissions: enum_set!(Permission::Read),
                properties: enum_set!(Property::Read),
                max_len: MAX_CHAR_LEN,
                auto_rsp: AutoResponse::ByGatt,
            },
            self.config.wifi_ssid.as_bytes(),
        )?;

        // totem_wifi_pass
        self.gatts.add_characteristic(
            service_handle,
            &GattCharacteristic {
                uuid: BtUuid::uuid128(TOTEM_WIFI_PASS_UUID),
                permissions: enum_set!(Permission::Read),
                properties: enum_set!(Property::Read),
                max_len: MAX_CHAR_LEN,
                auto_rsp: AutoResponse::ByGatt,
            },
            self.config.wifi_pass.as_bytes(),
        )?;

        Ok(())
    }

    /// Update connection MTU
    fn register_conn_mtu(&self, conn_id: ConnectionId, mtu: u16) -> Result<(), EspError> {
        let mut state = self.state.lock().unwrap();

        if let Some(conn) = state
            .connections
            .iter_mut()
            .find(|conn| conn.conn_id == conn_id)
        {
            conn.mtu = Some(mtu);
        }

        Ok(())
    }

    /// Create a new connection
    fn create_conn(&self, conn_id: ConnectionId, addr: BdAddr) -> Result<(), EspError> {
        let added = {
            let mut state = self.state.lock().unwrap();

            if state.connections.len() < MAX_CONNECTIONS {
                state
                    .connections
                    .push(Connection {
                        peer: addr,
                        conn_id,
                        mtu: None,
                    })
                    .map_err(|_| ())
                    .unwrap();

                // Restart advertising to allow more connections
                self.set_adv_conf()?;

                true
            } else {
                false
            }
        };

        if added {
            log::info!("Peer connected: {addr}");
            self.gap.set_conn_params_conf(addr, 10, 20, 0, 400)?;
        }

        Ok(())
    }

    /// Delete a connection
    fn delete_conn(&self, addr: BdAddr) -> Result<(), EspError> {
        let mut state = self.state.lock().unwrap();

        if let Some(index) = state
            .connections
            .iter()
            .position(|Connection { peer, .. }| *peer == addr)
        {
            state.connections.swap_remove(index);
            log::info!("Peer disconnected: {addr}");

            // Restart advertising to allow new connections
            self.set_adv_conf()?;
        }

        Ok(())
    }

    fn check_esp_status(&self, status: Result<(), EspError>) {
        if let Err(e) = status {
            warn!("ESP error: {e:?}");
        }
    }

    fn check_bt_status(&self, status: BtStatus) -> Result<(), EspError> {
        if !matches!(status, BtStatus::Success) {
            warn!("BT status: {status:?}");
            Err(EspError::from_infallible::<ESP_FAIL>())
        } else {
            Ok(())
        }
    }

    fn check_gatt_status(&self, status: GattStatus) -> Result<(), EspError> {
        if !matches!(status, GattStatus::Ok) {
            warn!("GATT status: {status:?}");
            Err(EspError::from_infallible::<ESP_FAIL>())
        } else {
            Ok(())
        }
    }
}