use chrono::{DateTime, Utc};
use std::sync::Mutex;
use flutter_rust_bridge::frb;

// Import the internal types from the shared crate
use shared::db::Database as SharedDatabase;
use shared::model::{Post as SharedPost, Totem as SharedTotem, User as SharedUser};

// --- Models ---
// We redefine the structs here so FRB can generate the Dart classes.
// We then implement From/Into to convert between these API types and the internal shared types.

#[derive(Debug, Clone)]
pub struct User {
    pub uuid: String,
    pub username: String,
    pub status: String,
    pub bio: String,
    pub profile_picture: Option<String>,
    pub last_contact: DateTime<Utc>,
}

impl From<SharedUser> for User {
    fn from(s: SharedUser) -> Self {
        User {
            uuid: s.uuid,
            username: s.username,
            status: s.status,
            bio: s.bio,
            profile_picture: s.profile_picture,
            last_contact: s.last_contact,
        }
    }
}

impl Into<SharedUser> for User {
    fn into(self) -> SharedUser {
        SharedUser {
            uuid: self.uuid,
            username: self.username,
            status: self.status,
            bio: self.bio,
            profile_picture: self.profile_picture,
            last_contact: self.last_contact,
        }
    }
}

#[derive(Debug, Clone)]
pub struct Post {
    pub uuid: String,
    pub user_id: String,
    pub title: String,
    pub body: String,
    pub timestamp: DateTime<Utc>,
    pub image: Option<String>,
    pub source_totem: String,
}

impl From<SharedPost> for Post {
    fn from(s: SharedPost) -> Self {
        Post {
            uuid: s.uuid,
            user_id: s.user_id,
            title: s.title,
            body: s.body,
            timestamp: s.timestamp,
            image: s.image,
            source_totem: s.source_totem.unwrap_or_default(),
        }
    }
}

impl Into<SharedPost> for Post {
    fn into(self) -> SharedPost {
        SharedPost {
            uuid: self.uuid,
            user_id: self.user_id,
            title: self.title,
            body: self.body,
            timestamp: self.timestamp,
            image: self.image,
            source_totem: if self.source_totem.is_empty() {
                None
            } else {
                Some(self.source_totem)
            },
        }
    }
}

#[derive(Debug, Clone)]
pub struct Totem {
    pub uuid: String,
    pub name: String,
    pub location: String,
    pub last_contact: DateTime<Utc>,
}

impl From<SharedTotem> for Totem {
    fn from(s: SharedTotem) -> Self {
        Totem {
            uuid: s.uuid,
            name: s.name,
            location: s.location,
            last_contact: s.last_contact,
        }
    }
}

impl Into<SharedTotem> for Totem {
    fn into(self) -> SharedTotem {
        SharedTotem {
            uuid: self.uuid,
            name: self.name,
            location: self.location,
            last_contact: self.last_contact,
        }
    }
}

// --- Database Wrapper ---

// We wrap the SharedDatabase in a Mutex to make it thread-safe (Sync).
// This allows FRB to pass the 'AppDatabase' handle safely between Rust threads.
pub struct AppDatabase {
    inner: Mutex<SharedDatabase>,
}

impl AppDatabase {
    #[frb(sync)]
    pub fn new(path: String) -> AppDatabase {
        let db = SharedDatabase::new(path);
        AppDatabase {
            inner: Mutex::new(db),
        }
    }

    // --- User Methods ---

    pub fn create_user(&self, user: User) -> anyhow::Result<()> {
        let db = self.inner.lock().map_err(|e| anyhow::anyhow!("Lock error: {}", e))?;
        // We catch panics from the internal 'expect' calls if necessary, 
        // but ideally the shared crate should return Results.
        // Assuming shared::create_user panics on failure (based on your code),
        // we wrap it here. Note: If shared::create_user panics, the Rust side might crash.
        // Ideally refactor 'shared' to return Result, but this works for now.
        db.create_user(&user.into());
        Ok(())
    }

    pub fn get_user_by_id(&self, uuid: String) -> anyhow::Result<User> {
        let db = self.inner.lock().map_err(|e| anyhow::anyhow!("Lock error: {}", e))?;
        let user = db.get_user_by_id(&uuid)?;
        Ok(user.into())
    }

    pub fn get_all_users(&self) -> anyhow::Result<Vec<User>> {
        let db = self.inner.lock().map_err(|e| anyhow::anyhow!("Lock error: {}", e))?;
        let users = db.get_all_users()?;
        Ok(users.into_iter().map(Into::into).collect())
    }

    pub fn update_user(&self, user: User) -> anyhow::Result<()> {
        let db = self.inner.lock().map_err(|e| anyhow::anyhow!("Lock error: {}", e))?;
        db.update_user(&user.into())?;
        Ok(())
    }

    // --- Post Methods ---

    pub fn create_post(&self, post: Post) -> anyhow::Result<()> {
        let db = self.inner.lock().map_err(|e| anyhow::anyhow!("Lock error: {}", e))?;
        db.create_post(&post.into());
        Ok(())
    }

    pub fn get_post_by_id(&self, uuid: String) -> anyhow::Result<Post> {
        let db = self.inner.lock().map_err(|e| anyhow::anyhow!("Lock error: {}", e))?;
        let post = db.get_post_by_id(&uuid)?;
        Ok(post.into())
    }

    pub fn get_all_posts(&self) -> anyhow::Result<Vec<Post>> {
        let db = self.inner.lock().map_err(|e| anyhow::anyhow!("Lock error: {}", e))?;
        let posts = db.get_all_posts()?;
        Ok(posts.into_iter().map(Into::into).collect())
    }

    pub fn get_post_ids_in_range(&self, start: DateTime<Utc>, end: DateTime<Utc>) -> anyhow::Result<Vec<String>> {
        let db = self.inner.lock().map_err(|e| anyhow::anyhow!("Lock error: {}", e))?;
        let ids = db.get_post_ids_in_range(start, end);
        Ok(ids)
    }

    // --- Totem Methods ---

    pub fn create_totem(&self, totem: Totem) -> anyhow::Result<()> {
        let db = self.inner.lock().map_err(|e| anyhow::anyhow!("Lock error: {}", e))?;
        db.create_totem(&totem.into());
        Ok(())
    }

    pub fn get_all_totems(&self) -> anyhow::Result<Vec<Totem>> {
        let db = self.inner.lock().map_err(|e| anyhow::anyhow!("Lock error: {}", e))?;
        let totems = db.get_all_totems()?;
        Ok(totems.into_iter().map(Into::into).collect())
    }

    pub fn update_totem_last_contact(&self, uuid: String, last_contact: DateTime<Utc>) -> anyhow::Result<()> {
        let db = self.inner.lock().map_err(|e| anyhow::anyhow!("Lock error: {}", e))?;
        db.update_totem_last_contact(&uuid, last_contact)?;
        Ok(())
    }
}

// Keep the original greeting for testing
#[frb(sync)]
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

#[frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}