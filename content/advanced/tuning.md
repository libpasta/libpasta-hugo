+++
title = "Tuning & Parameter Selection"
toc = true
weight = 6
+++

`libpasta` comes with a set of secure default algorithm and parameter choices.
However, there is no single set of parameters which is suitable for all
purposes and we provide tools to help with parameter selection.

These tools also have the benefit of working as a benchmarking platform for the
target system; if the system performs significantly worse than the expected
times, this could result in suboptimal, or even insecure, parameters selected.

Currently, running `tune -h` gives the following output:

```console
$ tune -h
tune 0.0.1
Sam Scott
libpasta tuning tool

USAGE:
    tune [FLAGS] [OPTIONS]

FLAGS:
    -h, --help       Prints help information
    -p, --print      Output the final result in the configuration file format
    -V, --version    Prints version information
    -v, --verbose    Print test information verbosely

OPTIONS:
    -a, --algorithm <algorithm>    Choose the algorithm to tune (default: argon2i) [values: argon2i, bcrypt, scrypt]
    -t, --target <target>          Set the target number of verifications per second to support (defaut: 2)
```

Running simple `tune` will benchmark various parameter choices (for the default
options) until optimal values are found. Configuration options include the
algorithm to target, and the default number of logins per second to be
supported.

Finally, the `-p` flag can be used to produce a libpasta-compatible configuration file.

```console
$ tune -a scrypt -p
CPU speed: 2800
Predicted maximum parameter: 17, with time: 0.437s
logN = 5, parallel = 1, read size = 8 ~> memory = 33 KiB 0.0001 s (estimated: 0.0001 s)
logN = 6, parallel = 1, read size = 8 ~> memory = 65 KiB 0.0002 s (estimated: 0.0002 s)
logN = 7, parallel = 1, read size = 8 ~> memory = 129 KiB 0.0004 s (estimated: 0.0004 s)
...
logN = 16, parallel = 1, read size = 8 ~> memory = 65537 KiB 0.1791 s (estimated: 0.2186 s)
logN = 17, parallel = 1, read size = 8 ~> memory = 131073 KiB 0.3581 s (estimated: 0.4372 s)
logN = 18, parallel = 1, read size = 8 ~> memory = 262145 KiB 0.7151 s (estimated: 0.8743 s)
Maximum amount of memory (capped at 2036080 KiB) to achieve < 0.50 s hash = 131088 KiB
Recommended: SCrypt, N: 131072, r: 8, p: 1
Default:     SCrypt, N: 16384, r: 8, p: 1

Algorithm in configuration format:
---
default: Custom
primitive: 
  id: "scrypt-mcf"
  params: 
    log_n: "17"
    r: "8"
    p: "1"

```

There are a few interesting things to observe from the output. First of all, notice
that the algorithm estimated maximum parameter choice to be 14, taking 0.055s, which
is extremely close to the eventual value. This is a sense-check to ensure the system
does not perform unexpectedly slow, which might indicate there is another process
running which is consuming CPU time and skewing the benchmarks.

We left the target number of logins/second (the `-t` flag) at the default value
of 2. This is the recommended amount for interactive logins, such as for
websites. For offline applications, for example key derivation for disk encryption,
a better value is 1 login every 3 seconds, so `-t 0.33`.

