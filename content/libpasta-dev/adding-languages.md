+++
title = "Adding Languages"
toc = true
weight = 2
+++


Our initial support for other languages is through the use of
[SWIG](http://www.swig.org/).

So far, this means we have simple bindings for [C](../../other-languages/c), [Java](../../other-languages/java),
[PHP](../../other-languages/php), [python](../../other-languages/python), and [Ruby](../../other-languages/ruby).

If you want to add new language bindings, this is a good place to start.

The SWIG specification for `libpasta` reveals the simplicity of the API, 
and a few important caveats:

```c
# in pasta.h

#include <stdbool.h>
extern char * hash_password(const char *password);
extern bool verify_password(const char* hash, const char *password);
extern void free_string(const char *);
extern char * read_password(const char *prompt);

```

These bind to the functions exported by the [libpasta-ffi](https://github.com/libpasta/libpasta-ffi) crate.

```swig
# in pasta.i

%module pasta
%{
#include <pasta.h>
%}

%typemap(newfree) char * "free_string($1);";
%newobject hash_password;
%newobject read_password;


%pragma(java) jniclasscode=%{
  static {
    try {
        System.loadLibrary("pasta_jni");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. \n" + e);
      System.exit(1);
    }
  }
%}

#include <pasta.h>
```

An important caveat, and reason why these bindings should be preferred, 
is that the values returned by `hash_password` and `read_password` are
technically still Rust `CString`s. Although these are in the correct layout
to be read as string pointers in C, we must take care to return the pointer
to Rust so that it can handle freeing the `CString`. Otherwise we are left
with a memory leak.

Notice that the SWIG bindings have handled this: on returning a `CString`, 
the bindings create a new object, and then call `free_string` on the pointer.
