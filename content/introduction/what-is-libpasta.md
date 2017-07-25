+++
title = "What is libpasta?"
toc = true
weight = 4
+++

#### _Making Passwords Painless_

This library aims to be an all-in-one solution for password storage. In
particular, we aim to provide:

 - Easy-to-use password storage with sane defaults.
 - Tools to provide parameter tuning for different use cases.
 - Automatic migration of passwords to new algorithms.
 - Cross-platform builds and cross-language bindings.


#### Secure by Default

`libpasta` is ready to work at a production level straight out of the box. We
hide any unnecessary decisions from the developer. Together with the support for
[migrating passwords](#easy-password-migration), `libpasta` provides a
streamlined, easy, and secure password management solution. 

Currently, the algorithm favoured by `libpasta` is XXX (probably scrypt).
For more details, see [algorithm choice](../../technical-details/algorithm-choice).


#### Easy password migration

Many developers still use insecure password hashing systems, despite it causing
embarassing and significant vulnerabilities should a leak occur.  
Our aim is to help eveyrone adopt modern algorithms and
associated best practices. Hence we have designed `libpasta` to come with 
built-in support for easy password migration.

This allows you to migrate an existing password hash database to
secure algorithms, without inconveniencing users with password resets.
Furthermore, having convenient migration tools makes it easier to keep you
up-to-date with what hashing parameters should be as computer performance
increases.

See [basic usage](../basic-usage#password-migration) for an example of 
migrating passwords, or [advanced usage](../../advanced/migration/) for more 
details.

#### Tuning tools

Passwording hashing is relatively slow by design,
and setting parameters (the cost of computing the hash) too low can be a
vulnerability. Of course this has to be balanced against performance of your
`libpasta`-using application.
For times when the default parameters are not sufficient, `libpasta` helps
developers pick good parameters.

The tuning tool measures the performance of your system to suggest parameters,
as well as doing some sanity checks based on the specifictions of the system.
The tool will help you avoid setting parameters too aggressively 

See [tuning](../../advanced/tuning) for more details.

#### Cross-platform and cross-language

While the main library is written in Rust, thanks to the C-style ABI that is
exported by Rust libraries, we are able to support many different languages.
Similarly, Rust supports compilation over a number of platforms.

For more information, see [other languages](../../other-languages).
