extern crate libpasta;

use libpasta::primitives::Bcrypt;
use libpasta::config::Config;

fn main() {
    let config = Config::with_primitive(Bcrypt::new(15));
    let password_hash = config.hash_password("hunter2");
    println!("The hashed password is: '{}'", password_hash);
    // Prints bcrypt hash
}