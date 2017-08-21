+++
title = "Overview"
toc = true
weight = 1

+++

Our goal is for `libpasta` to be the clear choice for any developers requiring
secure password storage. We target a number of languages, initially supported
through the use of [SWIG](http://www.swig.org/).

So far, this means we have simple bindings for [C](../c), [Java](../java),
[PHP](../php), [python](../python), and [Ruby](../ruby).

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

These bind to the functions exported by the [libpasta-ffi](#) crate.

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
