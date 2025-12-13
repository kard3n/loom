use chrono::{DateTime, Utc};


#[derive(Debug)]
#[derive(PartialEq)]
pub struct User{
    pub uuid: String,
    pub username: String,
    pub status: String,
    pub bio: String,
    pub profile_picture: Option<String>,
    pub last_contact: DateTime<Utc>,
}

#[derive(Debug)]
#[derive(PartialEq)]
pub struct Post{
    pub uuid: String,
    pub user_id: String,
    pub title: String,
    pub body: String,
    pub timestamp: DateTime<Utc>,
    pub image: Option<String>,
    pub source_totem: String,
}

pub struct Totem{
    pub uuid: String,
    pub name: String,
    pub location: String,
    pub last_contact: DateTime<Utc>,
}