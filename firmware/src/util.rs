use hmac::{Hmac, Mac};
use sha2::Sha256;
use base64::Engine;
use esp_idf_hal::sys::{esp_efuse_mac_get_default, esp_err_t, EspError, ESP_OK};

type HmacSha256 = Hmac<Sha256>;

const FLEET_SECRET: &[u8] = b"replace-with-real-secret";

pub fn get_chip_serial() -> anyhow::Result<[u8; 6]> {
    let mut mac = [0u8; 6];
    EspError::convert(unsafe { esp_efuse_mac_get_default(mac.as_mut_ptr()) })?;
    Ok(mac)
    
}

fn hmac_bytes(mac: &[u8; 6], purpose: &[u8]) -> [u8; 32] {
    let mut h = HmacSha256::new_from_slice(FLEET_SECRET).unwrap();
    h.update(purpose);
    h.update(&[0u8]);
    h.update(mac);
    h.finalize().into_bytes().into()
}

pub fn mac_to_id_and_pass(mac: [u8; 6]) -> (String, String) {
    // ----- ID: 8 chars -----
    let id_digest = hmac_bytes(&mac, b"id");
    let id_full = base32::encode(
        base32::Alphabet::Crockford,
        &id_digest,
    );
    let id = id_full[..8].to_string();

    // ----- PASS: 12 chars -----
    let pw_digest = hmac_bytes(&mac, b"pw");
    let pw_full = base64::engine::general_purpose::URL_SAFE_NO_PAD.encode(pw_digest);
    let pass = pw_full[..12].to_string();

    (id, pass)
}
