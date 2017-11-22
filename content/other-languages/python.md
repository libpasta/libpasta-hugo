+++
title = "Python"
toc = true
weight = 5

+++

We are currently supporting the base libpasta functionality in python.

The library can be obtained by following the instruction in the
[repository](https://github.com/libpasta/libpasta-py/). Or using `pip`
for supported systems (currently 64-bit linux, most python versions).


Once obtained a simple example such as the following can be constructed:

```python
import libpasta

hash = libpasta.hash_password("hello123")
password  = libpasta.read_password("Please enter the password (hint: hello123):");
if libpasta.verify_password(hash, password):
    print("Correct password")
else:
    print("Sorry, that is incorrect")
```
