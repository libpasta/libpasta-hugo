+++
title = "Installation"
toc = true
weight = 6

+++

`libpasta` is designed to be installed as a system library.
Currently, this can be achieved by downloading the repository, compiling it, 
and moving the library to the system library, e.g `/usr/lib`.

```bash
git clone https://github.com/libpasta/libpasta/
cd libpasta

# compiles the library
make libpasta

# installs the library to ${INSTALL_DIR} - defaults to /usr/lib
make install
```

For developing Rust applications, we recommend using it as usual through cargo.

For non-Rust applications, follow the above steps to install the library, and
follow the instructions for [bindings to other languages](../../other-languages).
