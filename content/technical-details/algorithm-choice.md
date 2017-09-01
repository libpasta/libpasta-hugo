+++
title = "Algorithm Selection"
toc = true
weight = 5

+++

Currently, we use [scrypt][scrypt] as the default algorithm in `libpasta`.
The default parameters are:
```
N: 2^14
r: 8
p: 1
```

This results in a memory requirement of approximately 16MiB and about 0.01 - 0.1
seconds to compute. For many systems, this can be increased, and we suggest
using the [tuning tools](../../advanced/tuning) to choose suitable parameters.

[scrypt]: https://www.tarsnap.com/scrypt.html