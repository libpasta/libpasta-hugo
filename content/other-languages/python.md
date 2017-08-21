+++
title = "Python"
toc = true
weight = 5

+++

In the future `libpasta` will be distributed for python through pypi.
For now, we can use the `_pasta.so` and `pasta.py` files created by SWIG.

```python
from pasta import *

hash = hash_password("hello123")
password = read_password("Please enter the password (hint: hello123):")
if verify_password(hash, password):
    print("Correct password")
else:
    print("Sorry, that is incorrect")
```
