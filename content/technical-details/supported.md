+++
title = "Supported Algorithms"
toc = true
weight = 5

+++

This page lists the hash formats currently supported by `libpasta`, and
the algorithms available for use. For any missing formats/algorithms, please
[open an issue](https://github.com/libpasta/libpasta/issues) and/or submit a
pull request.

## Algorithms

Currently, `libpasta` has support for: 

 - [argon2](https://github.com/P-H-C/phc-winner-argon2/)
 - [bcrypt](https://en.wikipedia.org/wiki/Bcrypt)
 - [HMAC](https://en.wikipedia.org/wiki/Hash-based_message_authentication_code)
 - [PBKDF2](https://en.wikipedia.org/wiki/PBKDF2)
 - [scrypt](https://www.tarsnap.com/scrypt.html)

## Formats

The following hash-formats are supported automatically by `libpasta`:

| Name        | Format           | Description  |
| ----------- |-------------     | ------------ |
| bcrypt legacy format               |  `$2[abxy]$<cost>$<salthash>`  | `salthash` is a non-standard base64 encoding |
| [PHC format](../phc-string-format) | `$<id>$<params map>$<salt>$<hash>`      |   Also referred to as modular crypt format |
| `libpasta` specific                | `($!<PHC hash>)*$<PHC hash>`      |  nested MCF hash |

