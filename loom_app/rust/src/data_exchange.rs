// Minimal stub module to satisfy `pub mod data_exchange;`
//
// The Android build was failing because this module file was missing.
// Implement real data-exchange logic here when ready.

pub fn ping() -> String {
    "data_exchange:ok".to_string()
}
