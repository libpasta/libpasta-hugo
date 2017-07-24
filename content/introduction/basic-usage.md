+++
title = "Basic Usage"
toc = true
weight = 5

+++

The following examples are for the core library written in Rust. See [other languages](../../other-languages/)
for language bindings and examples. Where possible, the APIs exported by libpasta are
identical to those used in the Rust library.

### Password Hashes

A common scenario is that a particular user has password, which a service will check on each login to authenticate the user.

```rust
extern crate libpasta;

// We re-export the rpassword crate for CLI password input.
use libpasta::rpassword::*;

fn main() {
    println!("Please enter your password:");
    let password = read_password().unwrap();
    let password_hash = libpasta::hash_password(password);
    println!("The hashed password is: '{}'", password_hash);
}

```

The above code randomly generates a salt, and outputs the hash in the following format:
`$$argon2i$m=4096,t=3,p=1$P7ckzVebJQZCacmRdOdd1g$NNPTr2du3PQbGWUQF9+ZzAaIZKA/FlwJRR+TQ/h0Pq8`.

Details for how this is serialized can be found in the [technical details chapter](../../technical-details/phc-string-format/). This adheres to libpasta's [strong defaults](../what-is-libpasta#secure-by-default) principle. 

#### Verifying passwords

Now that you have the hashed output, verifying that an inputted password is correct can be done as follows:


```rust
extern crate libpasta;

// We re-export the rpassword crate for CLI password input.
use libpasta::rpassword::*;

const PASSWORD_HASH: &'static str = "$$argon2i$m=4096,t=3,p=1$P7ckzVebJQZCacmRdOdd1g$NNPTr2du3PQbGWUQF9+ZzAaIZKA/FlwJRR+TQ/h0Pq8";

fn main() {
    println!("Please re-enter your password:");
    let password = read_password().unwrap();
    let is_correct = libpasta::verify_password(PASSWORD_HASH, password);
    if is_correct {
        println!("The inputted password is correct!");
    } else {
        println!("Incorrect password.");
    }
}

```

#### Password migration

One of the key features of `libpasta` is the ability to easily migrate passwords
to new algorithms.

Suppose we previously have bcrypt hashes in the following form:
`$2a$10$175ikf/E6E.73e83.fJRbODnYWBwmfS0ENdzUBZbedUNGO.99wJfa`.
This a bcrypt hash, structured as `$<bcrypt identifier>$<cost>$<salthash>`.

`libpasta` includes a simple work flow for migrating passwords to a new
algorithm (or new parameterization of an existing algorithm).  
First, wrap existing hashes in the new algorithm to ensure their 
security immediately. Second, as users log in, update the wrapped hashes to just
use the new algorithm. Wrapping simply takes an existing hash and re-hashes it 
with the new algorithm. 

The following code first wraps an existing hash, and then a move to just using
the new algorithm:

```rust
extern crate libpasta;

// We re-export the rpassword crate for CLI password input.
use libpasta::rpassword::*;

const OLD_PASSWORD_HASH: &'static str = "$2a$10$LhQ7vr/pnBdDprTRX7JaJesx.qd7qAYdJryEt5z2VM7EUsbNNnoIi";

fn main() {
    // Step 1: Wrap old hash
    let mut hash = OLD_PASSWORD_HASH.to_string();
    libpasta::migrate_hash(&mut hash);
    println!("Wrapped. New hash: \n{}\n", hash);
    // Outputs:
    // $!$argon2i$m=4096,t=3,p=1$$2y-mcf$cost=10$NjS9xtBrpDfFrtVTZ9LcLg$ull3Vk89hE7vkrX5FJ4zM4foaCJP61EBuaxJMOVuLDw

    // Step 2: Update algorithm during log in
    let mut hash = OLD_PASSWORD_HASH.to_string();
    println!("Please enter your password:");
    let password = read_password().unwrap();
    if libpasta::verify_password_update_hash(&mut hash, password) {
        println!("Password correct, new hash: \n{}", hash);
        // Outputs:
        // $2a$10$LhQ7vr/pnBdDprTRX7JaJesx.qd7qAYdJryEt5z2VM7EUsbNNnoIi
    } else {
        println!("Password incorrect, hash unchanged: \n{}", hash);
        // Outputs:
        // $$argon2i$m=4096,t=3,p=1$hd2k5vRVJMK1aimiWP4moQ$NIN4COvpn4oEkirg+eeJ7/Vp5YbAXG+3sUVXHc/ttWg
    }
}
```



In the first step, we do not need the user's password (and can therefore
apply this to all user passwords when desired). However, the password hash is now
comprised of both a bcrypt computation AND an argon2 computation. Notice the
`libpasta`-specific password hash, `$!` denoting a nested hash value.

In the second step, if the user correctly enters their password, then a new hash
is computed from scratch with a fresh salt using the new algorithm. This
requires updating the stored version of the hash.

#### Basic configuration

`libpasta` supports runtime configuration by using config files, either 
found in default directories or specified by environment variables.

Accepted formats are YAML and TOML. An example config files looks like:

```yaml
algorithm:
  scrypt-mcf:
    log_n: 16
    r: 8
    p: 1

force-migration: true
```

This specifies the algorithm to use, in this case, scrypt.

By default, `libpasta` will search the current directory for a file with the name
`.libpasta.{yaml,toml}`. Alternatively, a specific (relative or absolute) path
can be supplied by running: `LIBPASTA_CFG=path/to/file.yaml <app-name>`.

