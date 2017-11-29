+++
title = "Algorithm Selection"
toc = true
weight = 5

+++

Currently, we use [scrypt][scrypt] as the default algorithm in `libpasta`.
The default parameters are:
```
N: 2^15
r: 8
p: 1
```

This results in a memory requirement of approximately 32MiB and about 0.1
seconds to compute. For many systems, this can be increased, and we suggest
using the [tuning tools](../../advanced/tuning) to choose suitable parameters.

For more information on the scrypt parameters, see: https://blog.filippo.io/the-scrypt-parameters/

## Why scrypt?

Scrypt was introduced in 2009 as a memory-hard hash function, designed to
reduce the advantage gained by using custom hardware (e.g. ASICs) over general
purpose CPUs. Recently, it was shown in [\[ACPRT16\]][acprt16] that scrypt is in
fact _optimally_ memory-hard, when measured as the cumulative memory
requirement of the algorithm (i.e., the "area" of the memory/time graph).
While this result does not comprehensively thwart ASIC attacks, it is a
definite step in the right direction for scrypt.

Other memory-hard hash functions include [Argon2][argon2], which was the
winner of the recent [password hashing competition][phc]. Argon2 currently
has three modes: data-dependent Argon2d, data-independent Argon2i, and a mix
of the two, Argon2id.

Both scrypt and Argon2 with _decent_ parameter choices are vastly preferable to
using any of the older algorithms, bcrypt, PBKDF2, etc. Therefore we are mostly
interested in addressing Argon2 vs scrypt.

### scrypt vs Argon2

**tl:dr** Argon2 is more modern, with nice features and a higher potential,
but scrypt is the conservative choice.

In detail:

scrypt has been around for longer, giving it more exposure, and more time
to iron out any bugs or kinks. Furthermore, recent theoretical results about
the memory hardness shows scrypt is well-designed and reduces the chance of
a catastrophic failure.

On the other hand, scrypt has two large weaknesses. The algorithm is data-dependent
which means there is the possibility of a side-channel attack (cache
timings across VMs for example). In addition, scrypt has a trivial
time-memory tradeoff attack, which means that ASICs still offer a 
significant speedup.

Argon2 was recently chosen as the password-hashing competition winner. It has
easily tunable parameters, and a number of modes suitable for different
purposes. Argon2d is data-dependent and has a higher (potential) memory
hardness, whereas Argon2i is data-independent and aims to eliminate side-
channel attacks. Argon2id combines the two, attempting to offer the best of
both worlds.

However, Argon2 has only recently been developed/specified/implemented and is
still in draft status with the CFRG. Furthermore, there are some
[recent attacks][a2attacks] which are resulting in tweaking of the recommended
parameter choices. Hence we opt for scrypt as the conservative choice.

Future possibility: support a scrypt-argon2 hybrid mode, e.g.
a few rounds of Argon2i followed by scrypt.	

[acprt16]: https://eprint.iacr.org/2016/989
[scrypt]: https://www.tarsnap.com/scrypt.html
[argon2]: https://www.argon2.com/
[a2attacks]: https://eprint.iacr.org/2016/759
[phc]: https://password-hashing.net/


