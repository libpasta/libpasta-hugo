+++
title = "C"
toc = true
weight = 5

+++

We can use the FFI definitions output by Rust directly in C code.
However, unlike with the SWIG bindings, we are required to manually free
the strings after use, as in the following simple example.

```c
### in pasta.h
#include <stdbool.h>

extern char * hash_password(const char *password);
extern bool verify_password(const char* hash, const char *password);
extern void free_string(const char *);
extern char * read_password(const char *prompt);
```

```c
#include "pasta.h"
#include <stdio.h>

int main(void) {
    char *hash, *password;
    hash = hash_password("hello123");
    password = read_password("Please enter the password (hint: hello123):");
    if (verify_password(hash, password)) {
        printf("Correct password\n");
    } else {
        printf("Sorry, that is incorrect\n");
    }
    free_string(hash);
    free_string(password);
    return 0;
}
```

Which is compiled in the usual way:
```bash
$ ls
pasta.h     test.c
$ gcc test.c -lpasta -otest
$ ./test
Please enter the password (hint: hello123):
Correct password
```
