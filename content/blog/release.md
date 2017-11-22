+++
title = "Announcing libpasta"
toc = false
date = "2017-11-22"
draft = false
+++

Today we are announcing the **alpha release of libpasta!**

libpasta is intended to be an cross-language, cross-platform, **easy-to-use**
password hashing library for developers. In particular, libpasta offers a
**simple API**, which uses sane defaults, offering a relatively high security
level with zero configuration or parameter choice for the developer.
Storing/verifying a password is as simple as `libpasta.hash_password(pw)` and
`libpasta.verify_password(hash, pw)`.

Furthermore, libpasta is built to handle **migrating from old hashes**, finally
allowing developers to move away from old, outdated algorithms and parameters.
Once libpasta is in place, it will happily 

Our vision for libpasta, is to be available across many platforms, offering
accessible password storage functionality to all applications. The core of
libpasta is written in Rust, and we have already written a number of bindings
for different languages.

To find out more, dive into some of the menu items on the left covering
more about [what is libpasta](../../introduction/what-is-libpasta), 
[password hashing theory](../../introduction/password-hashing-theory),
or [getting started with libpasta](../../introduction/basic-usage).

#### Current status

libpasta is still in its early stages. The main functionality is written in
Rust, with support for other languages following close behind. However, the core
code needs to be audited/optimised.

**We are currently looking for testing and feedback on the library.**

#### Roadmap

 * Implement more hashing algorithms (for migration compatibility).
 * Support for more platforms - OSX, 32-bit Linux, Windows
 * Support for more languages - Ruby, JavaScript.
 * More tools! We have built a basic [tuning tool](https://github.com/libpasta/pasta-tools)
in Rust to generate optimal parameter sets, and can expand this out.

#### Who we are

So far, libpasta is being developed by [samjs](https://twitter.com/sam_js_/)
as part of a NSF-funded project at Cornell Tech. We are actively looking for
new contributors, with the possibility of offering part and full-time
positions to continue the work.