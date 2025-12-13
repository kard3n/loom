use chrono::{DateTime, Utc};
use heapless::String;

pub static UUID_SIZE: usize = 36;

#[derive(Debug)]
#[derive(PartialEq)]
pub struct User{
    pub uuid: String<UUID_SIZE>,
    pub username: String<64>,
    pub status: String<128>,
    pub bio: String<1024>,
    pub profile_picture: Option<String<UUID_SIZE>>,
    pub last_contact: DateTime<Utc>,
}

#[derive(Debug)]
#[derive(PartialEq)]
pub struct Post{
    pub uuid: String<UUID_SIZE>,
    pub user_id: String<UUID_SIZE>,
    pub title: String<256>,
    pub body: String<2048>,
    pub timestamp: DateTime<Utc>,
    pub image: Option<String<UUID_SIZE>>,
    pub source_totem: String<UUID_SIZE>,
}

pub struct Totem{
    pub uuid: String<UUID_SIZE>,
    pub name: String<128>,
    pub location: String<256>,
    pub last_contact: DateTime<Utc>,
}