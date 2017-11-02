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
config.add_key(key);

// Construct an HMAC instance and use this as the outer configuration
let keyed_function = Hmac::with_key(&digest::SHA256, key);
config.set_keyed_hash(keyed_function);
```

Using `config.hash_function` will first hash using the default algorithm, and
then afterwards apply the HMAC to the output hash.

On the roadmap: support for alternative key sources.