use chrono::{DateTime, Utc};
use shared::fbdb::FileBasedDB;
use shared::model::User;

/// Exchanges data with a remote device
fn exchange_users(
    remote_known_user_ids: Vec<String>,
    fbdb: &mut FileBasedDB,
) -> anyhow::Result<(Vec<String>, Vec<String>)> {
    let known_users_local = fbdb.read_users_filter_map(100, |_u| true, |u| u.uuid)?; // todo

    let users_not_known_to_local: Vec<String> = remote_known_user_ids
        .iter()
        .filter(|item| !known_users_local.contains(item))
        .cloned()
        .collect();

    let users_not_known_to_remote: Vec<String> = known_users_local
        .into_iter()
        .filter(|item| !remote_known_user_ids.contains(item))
        .collect();

    /*
    for item in users_not_known_to_local {
        //db.create_user()
    }
     */

    Ok((users_not_known_to_local, users_not_known_to_remote))
}

fn exchange_posts(
    start_date: &DateTime<Utc>,
    end_date: &DateTime<Utc>,
    remote_known_post_ids: Vec<String>,
    fbdb: &mut FileBasedDB,
) -> anyhow::Result<((Vec<String>, Vec<String>))> {
    // Synchronize posts
    let known_posts_local = fbdb.read_posts_filter_map(
        100,
        |p| start_date <= &p.timestamp && &p.timestamp <= end_date,
        |p| p.uuid,
    )?; //db.get_post_ids_in_range();

    let posts_not_known_to_remote: Vec<String> = known_posts_local
        .iter()
        .filter(|item| !remote_known_post_ids.contains(item))
        .cloned()
        .collect();

    let posts_not_known_to_local: Vec<String> = remote_known_post_ids
        .into_iter()
        .filter(|item| !known_posts_local.contains(item))
        .collect();


    Ok((posts_not_known_to_local, posts_not_known_to_remote))
}
