+++
title = "Alternatives"
toc = true
weight = 10

+++

There are currently a few options for password hashing. These vary from
general crypto libraries, to specific password hashing libraries, to
in-built helpers. The functionality, security, ease-of-use and compatibility
of these varies, and we compare them to libpasta here.

The design of libpasta was inspired by libsodium (a cross-platform, cross-
language crypto library), and passlib (a python-based password hashing
library). libpasta is an effort to take the best features of these two libraries
combined into one, and more.

## libsodium

[libsodium](https://download.libsodium.org/doc/) is a well designed cryptography
library, targeting security and ease-of-use. Much of the design of libpasta was
inspired by libsodium.

Furthermore, libsodium includes [password hashing](https://download.libsodium.org/doc/password_hashing/), 
so why choose libpasta over libsodium?

#### Pros

Well-designed, mature library. Available for install on many operating systems, 
and with many bindings for other languages.

#### Cons

No support for migrating from weak hashes -- one of the main needs for libpasta.
While the _coverage_ of supported languages is great, there are [multiple
bindings](https://download.libsodium.org/doc/bindings_for_other_languages/)
for each language, of varying quality.

Furthermore, compare the difficulty of using libsodium:

```C
#define PASSWORD "Correct Horse Battery Staple"

char hashed_password[crypto_pwhash_STRBYTES];

if (crypto_pwhash_str
    (hashed_password, PASSWORD, strlen(PASSWORD),
     crypto_pwhash_OPSLIMIT_SENSITIVE, crypto_pwhash_MEMLIMIT_SENSITIVE) != 0) {
    /* out of memory */
}

if (crypto_pwhash_str_verify
    (hashed_password, PASSWORD, strlen(PASSWORD)) != 0) {
    /* wrong password */
}
```

compared to the equivalent code in libpasta:

```C
#define PASSWORD "Correct Horse Battery Staple"

char *hashed_password;

hashed_password = hash_password(PASSWORD);

if (verify_password(hashed_password, PASSWORD)) {
    /* wrong password */
}
```

#### Summary

libpasta is aiming to be the "libsodium for password hashing" -- a ubiquitous
systems library with wide support. In its early development, libpasta is not at
the same maturity level as libsodium. However, libpasta is specifically
designed for password hashing, has a wider feature set, and a simpler API.

## passlib

[passlib](https://passlib.readthedocs.io/en/stable/) is a password hashing
library for Python 2 & 3. It has a wide feature set, and supports multiple
platforms.

passlib allows configuring a `CryptContext` object to specify a hashing "policy"
(our words). That is, it supports whitelisting/blacklisting hashing algorithms, 
and even supports hash migration. However, this is only the full migration, not
the partial migration libpasta additionally supports. 

#### Pros

Python library, easily supported across mutliple platforms. Good support for
outdated algorithms, and ability to update hashes.

#### Cons

Only for Python. Documentation is not particularly friendly for newbies, and
seems to suggest PBKDF2 is the best algorithm. Scrypt is supported, but not
recommended. Only supports the Argon2i variant.

## Django password hashers

 - (+) Easy-to-use defaults
 - (+) Good alg support
 - (+) Support full/wrapped migrations by hard coded classes
 - (-) Only for Django
 - (-) Uses PBKDF2 by default with 100000 iterations.
 - (-) Requires defining new subclass to configure -- awkward config.

https://docs.djangoproject.com/en/2.0/topics/auth/passwords/ 

## PHP password_hash

As of version 5.5, PHP supports password hashing natively through
[`password_hash`](http://php.net/manual/en/function.password-hash.php).

 - (+) Default bcrypt, supports Argon2i as well.
 - (+) Easy-to-use defaults.
 - (-) PHP only.

## Ruby on Rails - Bcrypt

 - (+) Easy-to-use defaults.
 - (-) Rails only
 - (-) Default bcrypt, cost is just 10.

