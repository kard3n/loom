use crate::model::{Post, Totem, User};
use chrono::{DateTime, Utc};
use heapless::String as HString;
use rusqlite::types::FromSqlError;
use rusqlite::{Connection, Error, Row, params};
use std::string::String;

pub struct Database {
    connection: Connection,
}

impl Database {
    pub fn new(path: String) -> Database {
        let conn = Connection::open(path).unwrap();

        // Create tables

        // users
        conn.execute(
            "CREATE TABLE IF NOT EXISTS users (
            uuid  TEXT PRIMARY KEY,
            username  TEXT NOT NULL,
            status TEXT NOT NULL,
            bio  TEXT NOT NULL,
            profile_picture,
            last_contact TEXT NOT NULL
        )",
            (),
        )
        .expect("Failed to create users table.");

        //totems
        conn.execute(
            "CREATE TABLE IF NOT EXISTS totems (
            uuid  TEXT PRIMARY KEY,
            name  TEXT NOT NULL,
            location  TEXT NOT NULL,
            last_contact TEXT NOT NULL
        )",
            (),
        )
        .expect("Failed to create totems table.");

        //post
        conn.execute(
            "CREATE TABLE IF NOT EXISTS posts (
            uuid  TEXT PRIMARY KEY,
            user_id  TEXT NOT NULL,
            title  TEXT NOT NULL,
            body  TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            image TEXT,
            source_totem TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(uuid),
            FOREIGN KEY (source_totem) REFERENCES totems(uuid)
        )",
            (),
        )
        .expect("Failed to create posts table.");

        Database { connection: conn }
    }

    pub fn create_user(&self, user: &User) {
        self.connection
            .execute(
                "INSERT INTO users (uuid, username, status, bio, profile_picture, last_contact) VALUES (?1, ?2, ?3, ?4, ?5, ?6)",
                (
                    &user.uuid.to_string(),
                    &user.username.to_string(),
                    &user.status.to_string(),
                    &user.bio.to_string(),
                    &user.profile_picture.as_ref().map(|i| i.to_string()),
                    &user.last_contact
                ),
            )
            .expect("Failed to create user.");
    }

    pub fn create_post(&self, post: &Post) {
        self.connection
            .execute(
                "INSERT INTO posts (uuid, user_id, title, body, timestamp, image, source_totem) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)",
                (
                    &post.uuid.to_string(),
                    &post.user_id.to_string(),
                    &post.title.to_string(),
                    &post.body.to_string(),
                    &post.timestamp,
                    post.image.as_ref().map(|i| i.to_string()),
                    &post.source_totem.to_string(),
                ),
            )
            .expect("Failed to create post.");
    }

    pub fn create_totem(&self, totem: &Totem) {
        self.connection
            .execute(
                "INSERT INTO totems (uuid, name, location, last_contact) VALUES (?1, ?2, ?3, ?4)",
                (
                    &totem.uuid.to_string(),
                    &totem.name.to_string(),
                    totem.location.to_string(),
                    &totem.last_contact,
                ),
            )
            .expect("Failed to create totem.");
    }

    /// Returns the IDs of all known posts in the given time range
    pub fn get_post_ids_in_range(&self, start: DateTime<Utc>, end: DateTime<Utc>) -> Vec<String> {
        let mut stmt = self
            .connection
            .prepare("SELECT uuid FROM posts WHERE timestamp >= ?1 AND timestamp <= ?2")
            .expect("Failed to prepare query");

        // 2. Map the rows
        let post_iter = stmt
            .query_map(params![start, end], |row| row.get(0))
            .expect("Failed to execute query");

        let mut post_ids: Vec<String> = Vec::new();

        for id in post_iter {
            post_ids.push(id.unwrap());
        }

        post_ids
    }

    pub fn get_post_by_id(&self, uuid: &str) -> rusqlite::Result<Post> {
        return self.connection.query_row(
            "SELECT uuid, user_id, title, body, timestamp, image, source_totem
                FROM posts
                WHERE uuid = ?1",
            params![uuid],
            |row| {
                Ok(Post {
                    uuid: get_heapless(row, 0)?,
                    user_id: get_heapless(row, 1)?,
                    title: get_heapless(row, 2)?,
                    body: get_heapless(row, 3)?,
                    timestamp: row.get(4)?, // DateTime<Utc> works natively with feature
                    image: row.get::<_, Option<String>>(5)?
                        .map(|s| s.parse().expect("Failed to parse image string")),
                    source_totem: get_heapless(row, 6)?,
                })
            },
        );
    }

    pub fn get_user_by_id(&self, uuid: &str) -> rusqlite::Result<User> {
        return self.connection.query_row(
            "SELECT uuid, username, status, bio, profile_picture, last_contact FROM users WHERE uuid = ?1",
            params![uuid],
            |row| {
                Ok(User {
                    uuid: get_heapless(row, 0)?,
                    username: get_heapless(row, 1)?,
                    status: get_heapless(row, 2)?,
                    bio: get_heapless(row, 3)?,
                    profile_picture: row.get::<_, Option<String>>(4)?
                        .map(|s| s.parse().expect("Failed to parse image string")),
                    last_contact: row.get(5)?,
                })
            },
        );
    }
}

/// Helper function to fetch text from an SQL result and convert to heapless::String
fn get_heapless<const N: usize>(row: &Row, index: usize) -> rusqlite::Result<HString<N>> {
    // 1. Get reference to string without allocating std::String
    let text_ref = row.get_ref(index)?.as_str()?;

    // 2. Try to convert to heapless (fails if DB string > N)
    text_ref.try_into().map_err(|_| {
        Error::FromSqlConversionFailure(
            index,
            rusqlite::types::Type::Text,
            Box::new(FromSqlError::Other(
                "String too long for heapless buffer".into(),
            )),
        )
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::TimeDelta;
    use std::ops::{Add, Sub};

    #[test]
    fn test_write_read() {
        std::fs::remove_file("test.db".to_string());
        let db = Database::new("test.db".to_string());

        let user = User {
            uuid: "550e8400-e29b-41d4-a716-446655440000".try_into().unwrap(),
            username: "tag".try_into().unwrap(),
            status: "Online".try_into().unwrap(),
            bio: "bio".try_into().unwrap(),
            profile_picture: Some("123e4567-e89b-12d3-a456-426697174000".try_into().unwrap()),
            last_contact: Utc::now(),
        };

        let totem = Totem {
            uuid: "990e8400-e29b-41d4-a716-446655440011".try_into().unwrap(),
            name: "Test Totem".try_into().unwrap(),
            location: "Somewhere".try_into().unwrap(),
            last_contact: Utc::now(),
        };

        let post = Post {
            uuid: "123e4567-e89b-12d3-a456-426614174000".try_into().unwrap(),
            user_id: "550e8400-e29b-41d4-a716-446655440000".try_into().unwrap(),

            title: "First Post from Embedded Rust".try_into().unwrap(),

            body: "This is a test body. We are testing heapless strings inside SQLite. \
           It works great for embedded systems because it avoids fragmentation."
                .try_into()
                .unwrap(),

            timestamp: Utc::now(),

            // Assuming image/totem IDs are also UUIDs or short identifiers
            image: Some("000e8400-e29b-41d4-a716-446655440022".try_into().unwrap()),
            source_totem: "990e8400-e29b-41d4-a716-446655440011".try_into().unwrap(),
        };

        db.create_user(&user);

        db.create_totem(&totem);

        db.create_post(&post);

        assert_eq!(
            db.get_post_ids_in_range(
                post.timestamp.sub(TimeDelta::seconds(5)),
                post.timestamp.add(TimeDelta::seconds(5))
            ),
            Vec::from(["123e4567-e89b-12d3-a456-426614174000"])
        );

        assert_eq!(
            db.get_post_by_id("123e4567-e89b-12d3-a456-426614174000")
                .unwrap(),
            post
        );

        assert_eq!(
            db.get_user_by_id("550e8400-e29b-41d4-a716-446655440000")
                .unwrap(),
            user
        )
    }
}
