+++
title = "What is libpasta?"
toc = true
weight = 4
+++

Password breaches have become a regular occurance. See: [Yahoo][yahoo] ([twice][yahoo2]),
[LinkedIn][linkedin], [Adobe][adobe], [Ashley Madison][am], and
[a whole lot more][hibp-breaches].

Furthermore, with the exception of Yahoo who _eventually_ migrated to bcrypt in 2013,
the above examples doubles as a list
of "how NOT to do password storage": simple hashing, unsalted values, misuse of
encryption, and failed password migration. (For more information on why these
are bad, see our
[introduction to password hashing theory](../password-hashing-theory)).

There are two possible interpretations here: first, companies do not put
adequate resources in securing passwords; and secondly, getting password hashing
right is hard. Furthermore, even if you have followed previous best practice,
keeping it right is another technical challenge: algorithm choices, security
levels, parameter selection change regularly.

[yahoo]: https://help.yahoo.com/kb/account/SLN27925.html
[yahoo2]: https://help.yahoo.com/kb/account/sln28092.html
[linkedin]: https://motherboard.vice.com/en_us/article/78kk4z/another-day-another-hack-117-million-linkedin-emails-and-password 
[adobe]: https://www.troyhunt.com/adobe-credentials-and-serious/
[am]: http://krebsonsecurity.com/2015/07/online-cheating-site-ashleymadison-hacked/
[hibp-breaches]: https://haveibeenpwned.com/PwnedWebsites

### libpasta - making passwords painless

This library aims to be an all-in-one solution for password storage. In
particular, we aim to provide:

 - Easy-to-use password storage with strong defaults.
 - Tools to provide parameter tuning for different use cases.
 - Automatic migration of passwords to new algorithms.
 - Cross-platform builds and cross-language bindings.

#### Secure by default

`libpasta` is ready to work at a production level straight out of the box. We
hide any unnecessary decisions from the developer. Together with the support for
[migrating passwords](#easy-password-migration), `libpasta` provides a
streamlined, easy, and secure password management solution. 

Currently, the algorithm favoured by `libpasta` is XXX (probably scrypt).
For more details, see [algorithm choice](../../technical-details/algorithm-choice).


#### Easy password migration

Many developers still use insecure password hashing systems, despite it causing
embarrassing and significant vulnerabilities should a leak occur.  
Our aim is to help everyone adopt modern algorithms and
associated best practices. Hence we have designed `libpasta` with 
built-in support for easy password migration.

This allows you to migrate an existing password hash database to
secure algorithms, without inconveniencing users with password resets.
Furthermore, having convenient migration tools makes it easier to keep you
up-to-date with what hashing parameters should be as computer performance
increases.

See [basic usage](../basic-usage#password-migration) for an example of 
migrating passwords, or [advanced usage](../../advanced/migration/) for more 
details.

#### Tunable

Password hashing is relatively slow by design,
and setting parameters (the cost of computing the hash) too low can be a
vulnerability. Of course this has to be balanced against performance of your
`libpasta`-using application.
For times when the default parameters are not sufficient, `libpasta` helps
developers pick good parameters.

The tuning tool measures the performance of your system to suggest parameters,
as well as doing some sanity checks based on the specifications of the system.
The tool will help you avoid setting parameters too aggressively 

See [tuning](../../advanced/tuning) for more details.

#### Cross-platform and cross-language

While the main library is written in Rust, thanks to the C-style ABI that is
exported by Rust libraries, we are able to support many different languages.
Similarly, Rust supports compilation over a number of platforms.

For more information, see [other languages](../../other-languages).
