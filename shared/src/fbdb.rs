use crate::model::{Post, Totem, User};
use std::fs::{self, File, OpenOptions};
use std::io::{self, BufReader, BufWriter, Read, Write};
use std::path::{Path, PathBuf};

/// File-based database that stores structs in append-only files
pub struct FileBasedDB {
    base_path: PathBuf,
}

impl FileBasedDB {
    /// Initialize the file-based database with the given folder path
    /// Creates all necessary directories
    pub fn init<P: AsRef<Path>>(folder_path: P) -> io::Result<Self> {
        let base_path = folder_path.as_ref().to_path_buf();
        fs::create_dir_all(&base_path)?;

        Ok(FileBasedDB { base_path })
    }

    /// Get the file path for a specific model type
    fn get_file_path(&self, filename: &str) -> PathBuf {
        self.base_path.join(filename)
    }

    /// Write a single user to the database
    pub fn write_user(&self, user: &User) -> io::Result<()> {
        self.write_users(&[user])
    }

    /// Write multiple users to the database
    pub fn write_users(&self, users: &[&User]) -> io::Result<()> {
        let path = self.get_file_path("users.bin");
        let file = OpenOptions::new()
            .create(true)
            .append(true)
            .open(path)?;

        let mut writer = BufWriter::new(file);

        for user in users {
            let serialized = postcard::to_allocvec(user)
                .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e))?;

            // Write length prefix (4 bytes) followed by data
            let len = serialized.len() as u32;
            writer.write_all(&len.to_le_bytes())?;
            writer.write_all(&serialized)?;
        }

        // Sync at the end
        writer.flush()?;
        writer.get_ref().sync_all()?;

        Ok(())
    }

    /// Write a single post to the database
    pub fn write_post(&self, post: &Post) -> io::Result<()> {
        self.write_posts(&[post])
    }

    /// Write multiple posts to the database
    pub fn write_posts(&self, posts: &[&Post]) -> io::Result<()> {
        let path = self.get_file_path("posts.bin");
        let file = OpenOptions::new()
            .create(true)
            .append(true)
            .open(path)?;

        let mut writer = BufWriter::new(file);

        for post in posts {
            let serialized = postcard::to_allocvec(post)
                .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e))?;

            // Write length prefix (4 bytes) followed by data
            let len = serialized.len() as u32;
            writer.write_all(&len.to_le_bytes())?;
            writer.write_all(&serialized)?;
        }

        // Sync at the end
        writer.flush()?;
        writer.get_ref().sync_all()?;

        Ok(())
    }

    /// Write a single totem to the database
    pub fn write_totem(&self, totem: &Totem) -> io::Result<()> {
        self.write_totems(&[totem])
    }

    /// Write multiple totems to the database
    pub fn write_totems(&self, totems: &[&Totem]) -> io::Result<()> {
        let path = self.get_file_path("totems.bin");
        let file = OpenOptions::new()
            .create(true)
            .append(true)
            .open(path)?;

        let mut writer = BufWriter::new(file);

        for totem in totems {
            let serialized = postcard::to_allocvec(totem)
                .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e))?;

            // Write length prefix (4 bytes) followed by data
            let len = serialized.len() as u32;
            writer.write_all(&len.to_le_bytes())?;
            writer.write_all(&serialized)?;
        }

        // Sync at the end
        writer.flush()?;
        writer.get_ref().sync_all()?;

        Ok(())
    }

    /// Read users from the database with a limit
    pub fn read_users(&self, limit: usize) -> io::Result<Vec<User>> {
        self.read_users_filter_map(limit, |_| true, |user| user)
    }

    /// Read users from the database that match the given predicate
    pub fn read_users_match<F>(&self, limit: usize, matcher: F) -> io::Result<Vec<User>>
    where
        F: Fn(&User) -> bool,
    {
        self.read_users_filter_map(limit, matcher, |user| user)
    }

    /// Read users from the database with filter and map callbacks for memory efficiency
    /// First filters each item, then maps it, then adds to result
    pub fn read_users_filter_map<F, M, R>(&self, limit: usize, filter: F, map: M) -> io::Result<Vec<R>>
    where
        F: Fn(&User) -> bool,
        M: Fn(User) -> R,
    {
        let path = self.get_file_path("users.bin");

        if !path.exists() {
            return Ok(Vec::new());
        }

        let file = File::open(path)?;
        let mut reader = BufReader::new(file);
        let mut results = Vec::new();
        let mut len_buf = [0u8; 4];

        while results.len() < limit {
            // Read length prefix
            match reader.read_exact(&mut len_buf) {
                Ok(_) => {},
                Err(e) if e.kind() == io::ErrorKind::UnexpectedEof => break,
                Err(e) => return Err(e),
            }

            let len = u32::from_le_bytes(len_buf) as usize;
            let mut data_buf = vec![0u8; len];
            reader.read_exact(&mut data_buf)?;

            let user: User = postcard::from_bytes(&data_buf)
                .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e))?;

            // First filter, then map to save RAM
            if filter(&user) {
                let mapped = map(user);
                results.push(mapped);
            }
        }

        Ok(results)
    }

    /// Read posts from the database with a limit
    pub fn read_posts(&self, limit: usize) -> io::Result<Vec<Post>> {
        self.read_posts_filter_map(limit, |_| true, |post| post)
    }

    /// Read posts from the database that match the given predicate
    pub fn read_posts_match<F>(&self, limit: usize, matcher: F) -> io::Result<Vec<Post>>
    where
        F: Fn(&Post) -> bool,
    {
        self.read_posts_filter_map(limit, matcher, |post| post)
    }

    /// Read posts from the database with filter and map callbacks for memory efficiency
    /// First filters each item, then maps it, then adds to result
    pub fn read_posts_filter_map<F, M, R>(&self, limit: usize, filter: F, map: M) -> io::Result<Vec<R>>
    where
        F: Fn(&Post) -> bool,
        M: Fn(Post) -> R,
    {
        let path = self.get_file_path("posts.bin");

        if !path.exists() {
            return Ok(Vec::new());
        }

        let file = File::open(path)?;
        let mut reader = BufReader::new(file);
        let mut results = Vec::new();
        let mut len_buf = [0u8; 4];

        while results.len() < limit {
            // Read length prefix
            match reader.read_exact(&mut len_buf) {
                Ok(_) => {},
                Err(e) if e.kind() == io::ErrorKind::UnexpectedEof => break,
                Err(e) => return Err(e),
            }

            let len = u32::from_le_bytes(len_buf) as usize;
            let mut data_buf = vec![0u8; len];
            reader.read_exact(&mut data_buf)?;

            let post: Post = postcard::from_bytes(&data_buf)
                .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e))?;

            // First filter, then map to save RAM
            if filter(&post) {
                let mapped = map(post);
                results.push(mapped);
            }
        }

        Ok(results)
    }

    /// Read totems from the database with a limit
    pub fn read_totems(&self, limit: usize) -> io::Result<Vec<Totem>> {
        self.read_totems_filter_map(limit, |_| true, |totem| totem)
    }

    /// Read totems from the database that match the given predicate
    pub fn read_totems_match<F>(&self, limit: usize, matcher: F) -> io::Result<Vec<Totem>>
    where
        F: Fn(&Totem) -> bool,
    {
        self.read_totems_filter_map(limit, matcher, |totem| totem)
    }

    /// Read totems from the database with filter and map callbacks for memory efficiency
    /// First filters each item, then maps it, then adds to result
    pub fn read_totems_filter_map<F, M, R>(&self, limit: usize, filter: F, map: M) -> io::Result<Vec<R>>
    where
        F: Fn(&Totem) -> bool,
        M: Fn(Totem) -> R,
    {
        let path = self.get_file_path("totems.bin");

        if !path.exists() {
            return Ok(Vec::new());
        }

        let file = File::open(path)?;
        let mut reader = BufReader::new(file);
        let mut results = Vec::new();
        let mut len_buf = [0u8; 4];

        while results.len() < limit {
            // Read length prefix
            match reader.read_exact(&mut len_buf) {
                Ok(_) => {},
                Err(e) if e.kind() == io::ErrorKind::UnexpectedEof => break,
                Err(e) => return Err(e),
            }

            let len = u32::from_le_bytes(len_buf) as usize;
            let mut data_buf = vec![0u8; len];
            reader.read_exact(&mut data_buf)?;

            let totem: Totem = postcard::from_bytes(&data_buf)
                .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e))?;

            // First filter, then map to save RAM
            if filter(&totem) {
                let mapped = map(totem);
                results.push(mapped);
            }
        }

        Ok(results)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::Utc;

    #[test]
    fn test_write_read_users() {
        let temp_dir = std::env::temp_dir().join("fbdb_test_users");
        let _ = fs::remove_dir_all(&temp_dir);

        let db = FileBasedDB::init(&temp_dir).unwrap();

        let user1 = User {
            uuid: "550e8400-e29b-41d4-a716-446655440000".to_string(),
            username: "alice".to_string(),
            status: "Online".to_string(),
            bio: "Test user 1".to_string(),
            profile_picture: Some("pic1.jpg".to_string()),
            last_contact: Utc::now(),
        };

        let user2 = User {
            uuid: "550e8400-e29b-41d4-a716-446655440001".to_string(),
            username: "bob".to_string(),
            status: "Offline".to_string(),
            bio: "Test user 2".to_string(),
            profile_picture: None,
            last_contact: Utc::now(),
        };

        db.write_user(&user1).unwrap();
        db.write_user(&user2).unwrap();

        let users = db.read_users(10).unwrap();
        assert_eq!(users.len(), 2);
        assert_eq!(users[0].username, "alice");
        assert_eq!(users[1].username, "bob");

        // Test with limit
        let users_limited = db.read_users(1).unwrap();
        assert_eq!(users_limited.len(), 1);
        assert_eq!(users_limited[0].username, "alice");

        // Test with matcher
        let online_users = db.read_users_match(10, |u| u.status == "Online").unwrap();
        assert_eq!(online_users.len(), 1);
        assert_eq!(online_users[0].username, "alice");

        let _ = fs::remove_dir_all(&temp_dir);
    }

    #[test]
    fn test_write_read_posts() {
        let temp_dir = std::env::temp_dir().join("fbdb_test_posts");
        let _ = fs::remove_dir_all(&temp_dir);

        let db = FileBasedDB::init(&temp_dir).unwrap();

        let post1 = Post {
            uuid: "123e4567-e89b-12d3-a456-426614174000".to_string(),
            user_id: "550e8400-e29b-41d4-a716-446655440000".to_string(),
            title: "First Post".to_string(),
            body: "This is the first post".to_string(),
            timestamp: Utc::now(),
            image: None,
            source_totem: None,
        };

        let post2 = Post {
            uuid: "123e4567-e89b-12d3-a456-426614174001".to_string(),
            user_id: "550e8400-e29b-41d4-a716-446655440000".to_string(),
            title: "Second Post".to_string(),
            body: "This is the second post".to_string(),
            timestamp: Utc::now(),
            image: Some("image.jpg".to_string()),
            source_totem: None,
        };

        db.write_posts(&[&post1, &post2]).unwrap();

        let posts = db.read_posts(10).unwrap();
        assert_eq!(posts.len(), 2);
        assert_eq!(posts[0].title, "First Post");
        assert_eq!(posts[1].title, "Second Post");

        // Test with matcher
        let posts_with_image = db.read_posts_match(10, |p| p.image.is_some()).unwrap();
        assert_eq!(posts_with_image.len(), 1);
        assert_eq!(posts_with_image[0].title, "Second Post");

        let _ = fs::remove_dir_all(&temp_dir);
    }

    #[test]
    fn test_write_read_totems() {
        let temp_dir = std::env::temp_dir().join("fbdb_test_totems");
        let _ = fs::remove_dir_all(&temp_dir);

        let db = FileBasedDB::init(&temp_dir).unwrap();

        let totem1 = Totem {
            uuid: "990e8400-e29b-41d4-a716-446655440011".to_string(),
            name: "Totem One".to_string(),
            location: "Location A".to_string(),
            last_contact: Utc::now(),
        };

        let totem2 = Totem {
            uuid: "990e8400-e29b-41d4-a716-446655440012".to_string(),
            name: "Totem Two".to_string(),
            location: "Location B".to_string(),
            last_contact: Utc::now(),
        };

        db.write_totem(&totem1).unwrap();
        db.write_totem(&totem2).unwrap();

        let totems = db.read_totems(10).unwrap();
        assert_eq!(totems.len(), 2);
        assert_eq!(totems[0].name, "Totem One");
        assert_eq!(totems[1].name, "Totem Two");

        let _ = fs::remove_dir_all(&temp_dir);
    }

    #[test]
    fn test_read_users_filter_map() {
        let temp_dir = std::env::temp_dir().join("fbdb_test_users_filter_map");
        let _ = fs::remove_dir_all(&temp_dir);

        let db = FileBasedDB::init(&temp_dir).unwrap();

        let user1 = User {
            uuid: "550e8400-e29b-41d4-a716-446655440000".to_string(),
            username: "alice".to_string(),
            status: "Online".to_string(),
            bio: "Test user 1".to_string(),
            profile_picture: Some("pic1.jpg".to_string()),
            last_contact: Utc::now(),
        };

        let user2 = User {
            uuid: "550e8400-e29b-41d4-a716-446655440001".to_string(),
            username: "bob".to_string(),
            status: "Offline".to_string(),
            bio: "Test user 2".to_string(),
            profile_picture: None,
            last_contact: Utc::now(),
        };

        let user3 = User {
            uuid: "550e8400-e29b-41d4-a716-446655440002".to_string(),
            username: "charlie".to_string(),
            status: "Online".to_string(),
            bio: "Test user 3".to_string(),
            profile_picture: Some("pic3.jpg".to_string()),
            last_contact: Utc::now(),
        };

        db.write_user(&user1).unwrap();
        db.write_user(&user2).unwrap();
        db.write_user(&user3).unwrap();

        // Test filter and map: get usernames of online users
        let online_usernames: Vec<String> = db.read_users_filter_map(
            10,
            |u| u.status == "Online",
            |u| u.username
        ).unwrap();

        assert_eq!(online_usernames.len(), 2);
        assert_eq!(online_usernames[0], "alice");
        assert_eq!(online_usernames[1], "charlie");

        // Test filter and map: get UUIDs of users with profile pictures
        let uuids_with_pics: Vec<String> = db.read_users_filter_map(
            10,
            |u| u.profile_picture.is_some(),
            |u| u.uuid
        ).unwrap();

        assert_eq!(uuids_with_pics.len(), 2);
        assert_eq!(uuids_with_pics[0], "550e8400-e29b-41d4-a716-446655440000");
        assert_eq!(uuids_with_pics[1], "550e8400-e29b-41d4-a716-446655440002");

        // Test map with no filter: extract all bios
        let all_bios: Vec<String> = db.read_users_filter_map(
            10,
            |_| true,
            |u| u.bio
        ).unwrap();

        assert_eq!(all_bios.len(), 3);
        assert_eq!(all_bios[0], "Test user 1");
        assert_eq!(all_bios[1], "Test user 2");
        assert_eq!(all_bios[2], "Test user 3");

        let _ = fs::remove_dir_all(&temp_dir);
    }

    #[test]
    fn test_read_posts_filter_map() {
        let temp_dir = std::env::temp_dir().join("fbdb_test_posts_filter_map");
        let _ = fs::remove_dir_all(&temp_dir);

        let db = FileBasedDB::init(&temp_dir).unwrap();

        let post1 = Post {
            uuid: "123e4567-e89b-12d3-a456-426614174000".to_string(),
            user_id: "550e8400-e29b-41d4-a716-446655440000".to_string(),
            title: "First Post".to_string(),
            body: "This is the first post".to_string(),
            timestamp: Utc::now(),
            image: None,
            source_totem: None,
        };

        let post2 = Post {
            uuid: "123e4567-e89b-12d3-a456-426614174001".to_string(),
            user_id: "550e8400-e29b-41d4-a716-446655440001".to_string(),
            title: "Second Post".to_string(),
            body: "This is the second post".to_string(),
            timestamp: Utc::now(),
            image: Some("image.jpg".to_string()),
            source_totem: None,
        };

        let post3 = Post {
            uuid: "123e4567-e89b-12d3-a456-426614174002".to_string(),
            user_id: "550e8400-e29b-41d4-a716-446655440000".to_string(),
            title: "Third Post".to_string(),
            body: "This is the third post".to_string(),
            timestamp: Utc::now(),
            image: Some("image2.jpg".to_string()),
            source_totem: Some("totem1".to_string()),
        };

        db.write_posts(&[&post1, &post2, &post3]).unwrap();

        // Test filter and map: get titles of posts with images
        let titles_with_images: Vec<String> = db.read_posts_filter_map(
            10,
            |p| p.image.is_some(),
            |p| p.title
        ).unwrap();

        assert_eq!(titles_with_images.len(), 2);
        assert_eq!(titles_with_images[0], "Second Post");
        assert_eq!(titles_with_images[1], "Third Post");

        // Test filter and map: get UUIDs of posts by specific user
        let user1_post_uuids: Vec<String> = db.read_posts_filter_map(
            10,
            |p| p.user_id == "550e8400-e29b-41d4-a716-446655440000",
            |p| p.uuid
        ).unwrap();

        assert_eq!(user1_post_uuids.len(), 2);
        assert_eq!(user1_post_uuids[0], "123e4567-e89b-12d3-a456-426614174000");
        assert_eq!(user1_post_uuids[1], "123e4567-e89b-12d3-a456-426614174002");

        // Test complex map: create tuples of (title, has_image)
        let post_info: Vec<(String, bool)> = db.read_posts_filter_map(
            10,
            |_| true,
            |p| (p.title, p.image.is_some())
        ).unwrap();

        assert_eq!(post_info.len(), 3);
        assert_eq!(post_info[0], ("First Post".to_string(), false));
        assert_eq!(post_info[1], ("Second Post".to_string(), true));
        assert_eq!(post_info[2], ("Third Post".to_string(), true));

        let _ = fs::remove_dir_all(&temp_dir);
    }

    #[test]
    fn test_read_totems_filter_map() {
        let temp_dir = std::env::temp_dir().join("fbdb_test_totems_filter_map");
        let _ = fs::remove_dir_all(&temp_dir);

        let db = FileBasedDB::init(&temp_dir).unwrap();

        let totem1 = Totem {
            uuid: "990e8400-e29b-41d4-a716-446655440011".to_string(),
            name: "Totem One".to_string(),
            location: "Location A".to_string(),
            last_contact: Utc::now(),
        };

        let totem2 = Totem {
            uuid: "990e8400-e29b-41d4-a716-446655440012".to_string(),
            name: "Totem Two".to_string(),
            location: "Location B".to_string(),
            last_contact: Utc::now(),
        };

        let totem3 = Totem {
            uuid: "990e8400-e29b-41d4-a716-446655440013".to_string(),
            name: "Totem Three".to_string(),
            location: "Location A".to_string(),
            last_contact: Utc::now(),
        };

        db.write_totem(&totem1).unwrap();
        db.write_totem(&totem2).unwrap();
        db.write_totem(&totem3).unwrap();

        // Test filter and map: get names of totems in Location A
        let location_a_names: Vec<String> = db.read_totems_filter_map(
            10,
            |t| t.location == "Location A",
            |t| t.name
        ).unwrap();

        assert_eq!(location_a_names.len(), 2);
        assert_eq!(location_a_names[0], "Totem One");
        assert_eq!(location_a_names[1], "Totem Three");

        // Test filter and map: get UUIDs of totems in Location B
        let location_b_uuids: Vec<String> = db.read_totems_filter_map(
            10,
            |t| t.location == "Location B",
            |t| t.uuid
        ).unwrap();

        assert_eq!(location_b_uuids.len(), 1);
        assert_eq!(location_b_uuids[0], "990e8400-e29b-41d4-a716-446655440012");

        // Test map with no filter: create (name, location) tuples
        let totem_info: Vec<(String, String)> = db.read_totems_filter_map(
            10,
            |_| true,
            |t| (t.name, t.location)
        ).unwrap();

        assert_eq!(totem_info.len(), 3);
        assert_eq!(totem_info[0], ("Totem One".to_string(), "Location A".to_string()));
        assert_eq!(totem_info[1], ("Totem Two".to_string(), "Location B".to_string()));
        assert_eq!(totem_info[2], ("Totem Three".to_string(), "Location A".to_string()));

        let _ = fs::remove_dir_all(&temp_dir);
    }
}
