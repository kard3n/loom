use chrono::{DateTime, Utc};

/// Exchanges data with a remote device
fn exchange_users(remote_known_user_ids: Vec<String>) {
    // TODO: add db

    let known_users_local = todo!(); // db.get_all_user_ids();

    let users_not_known_to_local: Vec<String> = remote_known_user_ids
        .clone()
        .into_iter()
        .filter(|item| !known_users_local.contains(item))
        .collect();

    let users_not_known_to_remote: Vec<String> = known_users_local
        .into_iter()
        .filter(|item| !remote_known_user_ids.contains(item))
        .collect();

    for item in users_not_known_to_local {
        // TODO get from remote and add to db
        //db.create_user()
    }

    for item in users_not_known_to_remote {
        // TODO send to remote
    }
}

fn exchange_posts(start_date: &DateTime<Utc>, end_date: &DateTime<Utc>, remote_known_post_ids: Vec<String>) {
    // TODO: add db

    // Synchronize posts
    let known_posts_local = todo!(); //db.get_post_ids_in_range();

    let posts_not_known_to_local: Vec<String> = remote_known_post_ids
        .clone()
        .into_iter()
        .filter(|item| !known_posts_local.contains(item))
        .collect();

    let users_not_known_to_remote: Vec<String> = known_posts_local
        .into_iter()
        .filter(|item| !remote_known_post_ids.contains(item))
        .collect();

    for item in posts_not_known_to_local {
        // TODO get from remote
    }

    for item in users_not_known_to_remote {
        // TODO send to remote
    }
}
