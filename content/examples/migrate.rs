extern crate libpasta;
use libpasta::rpassword::*;
use libpasta::{migrate_hash, HashUpdate};

struct User {
    // ...
    password_hash: String,
}

fn migrate_users(users: Vec<&mut User>) {
    // Step 1: Wrap old hash
    for user in users {
        let hash = user.password_hash;
        if let HashUpdate::Verified(Some(new_hash)) = migrate_hash(hash) {
            user.password_hash = new_hash;
        }
    }
}

fn auth_user(user: &mut User) {
    // Step 2: Update algorithm during log in
    let password = prompt_password_stdout("Enter password:").unwrap();

    match libpasta::verify_password_update_hash(&user.password_hash, password) {
        HashUpdate::Verified(res) => {
            if let Some(new_hash) = res {
                user.password_hash = new_hash;
            }
            println!("Password correct, new hash: \n{}", user.password_hash);
        },
        HashUpdate::Failed => {
            println!("Password incorrect, hash unchanged: \n{}", user.password_hash);
        }
    }
}