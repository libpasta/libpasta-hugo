+++
title = "Keyed Hashes"
toc = true
weight = 5
+++

We are currently developing support for keyed hashes: whether through HMAC or
encrypted values. For now, keys are generated and stored _locally in memory_ in
the running instance, which means that any passwords which are stored while the
application is running will be useless if the application terminates and
destroys the keys.

The goal is for this structure to be flexible to any kinds of environments with
different sources.

For example, the following code configures a key for use in libpasta and
sets up HMAC to be used as a wrapping function:

```rust
use libpasta::primitives::hmac::Hmac;
use libpasta::config::Config;

let mut config = Config::default();

// Some proper way of getting a key
let key = b"yellow submarine";
// The key source used by config is responsible for the key identifier
let key_id = config.add_key(key);

// Construct an HMAC instance and use this as the outer configuration
let keyed_function = Hmac::with_key_id(&digest::SHA256, &key_id);
config.set_keyed_hash(keyed_function);
```

Using `config.hash_function` will first hash using the default algorithm, and
then afterwards apply the HMAC to the output hash.

Alternate key sources can be specified by implementing the `key::Store` trait.
In the following example, we create a (bad!) key store, which uses a static key
for any identifier passed to it.

```rust
extern crate libpasta;
extern crate ring;

use libpasta::key;
use ring::digest;

#[derive(Debug)]
struct StaticSource(&'static [u8; 16]);
static STATIC_SOURCE: StaticSource = StaticSource(b"ThisIsAStaticKey");

impl key::Store for StaticSource {
    /// Insert a new key into the `Store`.
    fn insert(&self, _key: &[u8]) -> String {
        "StaticKey".to_string()
    }

    /// Get a key from the `Store`.
    fn get_key(&self, _id: &str) -> Option<Vec<u8>> {
        Some(self.0.to_vec())
    }
}

fn main() {
    let mut config = libpasta::Config::default();
    config.set_key_source(&STATIC_SOURCE);

    // Construct an HMAC instance and use this as the outer configuration
    let keyed_function = libpasta::primitives::Hmac::with_key_id(&digest::SHA256, "key");
    config.set_keyed_hash(keyed_function);

    let hash = config.hash_password("hunter2".to_string());
    println!("Computed hash: {:?}", hash);
}
```