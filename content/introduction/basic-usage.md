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

{{< highlight rust "hl_lines=8">}}
extern crate libpasta;

// We re-export the rpassword crate for CLI password input.
use libpasta::rpassword::*;

fn main() {
    let password = prompt_password_stdout("Please enter your password:").unwrap();
    let password_hash = libpasta::hash_password(password);
    println!("The hashed password is: '{}'", password_hash);
}
{{< /highlight >}}

The above code randomly generates a salt, and outputs the hash in the following format:
`$$argon2i$m=4096,t=3,p=1$P7ckzVebJQZCacmRdOdd1g$NNPTr2du3PQbGWUQF9+ZzAaIZKA/FlwJRR+TQ/h0Pq8`.

Details for how this is serialized can be found in the [technical details chapter](../../technical-details/phc-string-format/). This adheres to libpasta's [strong defaults](../what-is-libpasta#secure-by-default) principle.

However, for using `libpasta` one only needs to know that `hash_password`
outputs a variable-length string.

#### Verifying passwords

Now that you have the hashed output, verifying that an inputted password is correct can be done as follows:


{{< highlight rust "hl_lines=11">}}
extern crate libpasta;
use libpasta::rpassword::*;

struct User {
    // ...
    password_hash: String,
}

fn auth_user(user: &User) {
    let password = prompt_password_stdout("Enter password:").unwrap();
    if libpasta::verify_password(&user.password_hash, password) {
        println!("The password is correct!");
        // ~> Handle correct password
    } else {
        println!("Incorrect password.");
        // ~> Handle incorrect password
    }
}
{{< /highlight >}}

#### Password migration

One of the key features of `libpasta` is the ability to easily migrate passwords
to new algorithms.

Suppose we previously have bcrypt hashes in the following form:
`$2a$10$175ikf/E6E.73e83....`.
This a bcrypt hash, structured as `$<bcrypt identifier>$<cost>$<salthash>`.

`libpasta` includes a simple work flow for migrating passwords to a new
algorithm (or new parameterization of an existing algorithm).  
First, wrap existing hashes in the new algorithm to ensure their 
security immediately. Second, as users log in, update the wrapped hashes to just
use the new algorithm. Wrapping simply takes an existing hash and re-hashes it 
with the new algorithm. 

The following code first wraps an existing hash, and then a move to just using
the new algorithm:

{{< highlight rust "hl_lines=12 19">}}
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
{{< /highlight >}}

In the first step, we do not need the user's password (and can therefore
apply this to all user passwords when desired). However, the password hash is now
comprised of both a bcrypt computation AND an argon2 computation.

In the second step, if the user correctly enters their password, then a new hash
is computed from scratch with a fresh salt using the new algorithm. This
requires updating the stored version of the hash.

More detailed information of password migration can be found
[here](../../advanced/migration).

#### Basic configuration

`libpasta` supports configuration in two ways: directly in code, or using
configuration files.

For example, suppose we wish to use bcrypt with `cost=15` as the default algorithm.

```rust
extern crate libpasta;

use libpasta::primitives::Bcrypt;

fn main() {
    libpasta::config::set_primitive(Bcrypt::new(15));
    let password_hash = libpasta::hash_password("hunter2".to_string());
    println!("The hashed password is: '{}'", password_hash);
    // Prints bcrypt hash
}
```

Note that once the library is in use, the configuration can no longer be
changed.

Additionally, values may be set using a configuration file. Written in YAML,
these look as follows:

```yaml
default_primitive:
  id: scrypt-mcf
  params: 
    log_n: 12
    r: 8
    p: 1
```

This specifies the algorithm to use, in this case, scrypt.

By default, `libpasta` will search the current directory for a file with the name
`.libpasta.yaml`. Alternatively, a specific (relative or absolute) directory
can be supplied by running: `LIBPASTA_CFG=path/to/cfg/ <app-name>`.

`libpasta` will use any parameters set directly, then use any values
specified in configuration files, and finally all remaining variables are set
to defaults.

`libpasta` also has a [parameter selection tool](../../advanced/tuning) which
can optionally output configuration values. 
