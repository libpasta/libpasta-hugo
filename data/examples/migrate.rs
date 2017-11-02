extern crate libpasta;
use libpasta::rpassword::*;

struct User {
    // ...
    password_hash: String,
}

fn migrate_users(users: Vec<&mut User>) {
    // Step 1: Wrap old hash
    for user in users {
        libpasta::migrate_hash(&mut user.password_hash);
    }
}

fn auth_user(user: &mut User) {
    // Step 2: Update algorithm during log in
    let password = prompt_password_stdout("Enter password:").unwrap();
    if libpasta::verify_password_update_hash(&mut user.password_hash, password) {
        println!("Password correct, new hash: \n{}", user.password_hash);
    } else {
        println!("Password incorrect, hash unchanged: \n{}", user.password_hash);
    }
}