+++
title = "Randomness Problems"
toc = true
weight = 5

+++

One benefit of Rust is that it enforces strict error handling in applications.
Rust has `unwrap` and `expect` methods which are generally used to mean "I have no
idea how to recover from this particular error, please kill the program".

For example, imagine some binary application which is used to count the lines of a file
`cargo run --bin wc some_file.txt`
it seems reasonable to panic if `some_file.txt` is not found, which would
communicate this issue clearly.

Abusing `unwrap` and `expect` leads to faulty software. If a password library
panicked every time it receives a password hash which was too short (perhaps
the database read was truncated for some reason) then it is going to cause 
significant issues down the road for the web application.

In `libpasta`, there are currently two main sources of failures: hash
de/serialization failures, and failure to generate random values. Here we focus
on the latter, the former should be covered by a well-defined serialization
format and thorough testing/fuzzing.

When calling `libpasta::hash_password`, the library will attempt to generate a
random salt for hashing. If this fails, it is not clear that there is any meaningful
strategy which can be performed. Returning this error to the developer significantly
complicates the API, without a good chance they can do anything about it. 
Blocking until randomness is available is also a poor strategy. Hence we look
to provide a reasonably fallback strategy.

On first use `libpasta` initializes a number of configuration options
(see [basic configuration](../../introduction/basic-usage/#basic-configuration)).
At this point, `libpasta` will also test out the default source of randomness
(as configured by [ring](https://briansmith.org/rustdoc/ring/rand/struct.SystemRandom.html)), 
to initialize a seed. This seed is used as the input to a PRNG, which can
deterministically generate salts for new password hashes.
If this seed is never recovered by an adversary, there is no problem, and all the
salts are still pseudorandom. If, however, the current seed is compromised, all
future salts are predictable. However it is still hopefully the case that
salts will be per-user distinct which is the main property we wish to achieve.

Hence, instead of failing, here we provide an acceptable fallback mechanism
which guarantees the system can continue operating even in unexpected
circumstances.
