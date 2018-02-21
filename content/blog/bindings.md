+++
title = "Rust for Cross-Language System Libraries"
toc = false
date = "2018-02-21"
+++

We have been building libpasta as a simple, usable solution to password hashing
and migration. The goal for libpasta is to be a cross-platform, cross-language
system library.

libpasta is written in Rust, exports a C-style API, and builds to a
static/shared library. Most languages support calling external libraries through 
foreign function interfaces (FFIs), and the end result can be
seen in [the documentation](https://libpasta.github.io/introduction/basic-usage/#password-hashes)
where each language has access to the libpasta functionality.

This post is about how we use Rust + [cbindgen][cbindgen] + [Swig][swig] to
automate the process of creating bindings in each language which should feel
like a natively-written library.

This does not necessarily apply to existing systems libraries which are
rewritten in Rust, since bindings may already exist in multiple languages and
the Rust library will have to export identically defined functions as expected
by the library users.

Along the way, we cover some of the sharp edges you may encounter when using
FFI.

## Step 1. From Rust to C

Consider the most basic function in libpasta:
```rust
pub fn hash_password(password: &str) -> String {
    ...
}
```
which takes in a reference to a string and returns a new `String`.

Such a simple function should be easy to export as a C function, right?
But a `String` is basically just a vector of bytes `Vec<u8>`, whereas a C
string would be an array of `char`s terminated in a null byte `\0`.

Luckily, the [std::ffi](https://doc.rust-lang.org/std/ffi/) module contains a 
lot of the details necessary to [make this conversion work](https://doc.rust-lang.org/std/ffi/index.html#overview).
We can go from a pointer `*const char` to a borrowed [`&Cstr`](https://doc.rust-lang.org/std/ffi/struct.CStr.html),
and call [`to_str`](https://doc.rust-lang.org/std/ffi/struct.CStr.html#method.to_str) on that
to (maybe) get a `&str` (it checks whether the input is indeed a legitimate UTF-8 string).

Similarly, given a Rust `String`, this can be converted to a `CString` and converted
into a raw pointer of type `*mut c_char`.

All this information and much more can be found in the
[FFI omnibus][ffi-omni], a fantastic resource
for using Rust + FFI. Using all of this, it becomes easy enough to build
the extern version of `hash_password`, perhaps ending up with something like[^1]:
```rust
#[no_mangle]
pub extern fn hash_password(password: *const c_char) -> *mut c_char {
    let password = unsafe {
        if password.is_null() { return }
        CString::from_raw(password)
    };
    let hash = libpasta::hash_password(password);
    CString::new(hash).unwrap().into_raw()
}
```

Until you read these lines from the Omnibus:

> Returning an allocated string via FFI is complicated for the same reason that
> returning an object is: the Rust allocator can be different from the allocator
> on the other side of the FFI boundary.

...

> Ownership of the string is transferred to the caller, but the caller must
> return the string to Rust in order to properly deallocate the memory.

This is a huge pain. For something as simple as "input a string, return a string"
we now require the caller to call `free_string(s)` on every `s` returned by
this function.

Manually calling free on everything might be standard practice in C, but most
other languages will find this cumbersome. Leaving this around feels like
a particularly sharp edge for users to deal with, and does not mesh well with
the ease-of-use goal for libpasta.

We will show how Swig solves this in [step 3](#step-3-language-bindings-with-swig), but first, a quick look
at how cbdingen makes using these extern definitions easier.

## Step 2. Static libs and using cbindgen

Currently, we leave the `libpasta` crate as the pure-Rust crate, and define a
new crate `libpasta-capi` to contain all of the extern functions we create in
step 1.

By adding the lines:
```toml
[lib]
crate-type = ["cdylib", "staticlib"]
```
to our `Cargo.toml` file, cargo will now build shared/dynamic (e.g. *.so) and
static (e.g. *.a) versions of the library.
[More about crate types in the book](https://doc.rust-lang.org/reference/linkage.html).
The long-term goal is for `libpasta.so`, or windows-equivalent,
to be installable from `libpasta-capi` as a shared library for re-use.
In the shorter term, to help with testing, the static version is useful.

Now any language which can call out to libraries can access these functions. For
example, in C we just need to define a header file and link to the library.
[cbindgen][cbindgen] is a Rust tool to help with this process. It can either be
used as a CLI tool, or added to `build.rs` as part of the build process, and
generates a C or C++ header file from any extern function definitions.

Running `cargo build` with cbindgen in our `build.rs` results in:

```rust
char *hash_password(const char *password);
```

Automating the conversion of Rust extern functions to a C header file is a nice
thing to have, resulting in one fewer place where changes need to be made
when modifying the exported functions. cbindgen also has a bunch of nice features,
and handles structs and enums well It also makes for a reasonably effective
sense-check. For example, for a regular enum, 
cbindgen will just consider it an opaque struct, whereas using `#[repr(C)]`
will produce an actual C enum definition.

## Step 3. Language bindings with SWIG

[SWIG][swig] is a tool for generating wrapper code for C/C++ code. It takes in
a header definition file, and outputs language-specific interfaces.

It is difficult to convey adequately here just how much heavy lifting Swig is
doing. But consider all the caveats from step 1 when going Rust <-> C, and
imagine handling all of these for _many_ languages automatically.

As opposed to simply running Swig on a header file, it is more common to use 
a special `.i` interface file. This file is used to help guide the behaviour
of Swig, and define additional functionality.

With Swig, we can efficiently solve the annoying `String` deallocation problem
from earlier! The line `%newobject hash_password` tells Swig that the return
object from `hash_password` should be owned, and therefore needs to be cleaned
up by the native code. Next, the annotation `%typemap(newfree) char *
"free_string($1);";`, tells Swig _how_ to delete a `char *` - by calling
`free_string` on that value.

For example, in the case of python, you get code like this (wrapper code is C++):
```cpp
result = (char *)hash_password((char const *)arg1);
resultobj = SWIG_FromCharPtr((const char *)result);
if (alloc1 == SWIG_NEWOBJ) delete[] buf1;
free_string(result);
return resultobj;
```
That is, the wrapper code calls `hash_password`, and attempts to create a native
python string from the `char*` pointer. On a success, the original Rust string
is deallocated using `free_string`.

## Putting it all together

Suppose we now add the functionality to verify password hashes in libpasta:

```rust
pub fn verify_password(hash: &str, password: &str) -> bool {
    ...
}
```

First we write the libpasta-capi version:

```rust
#[no_mangle]
pub extern fn verify_password(hash: *const c_char, pw: *const c_char) -> bool {
    ...
}
```

Building with cargo automatically gives us the compiled libraries, and a header
file including:

```c
#include <stdbool.h>

bool verify_password(const char *hash, const char *password);
```

Note that cbindgen has included `stdbool.h` for us, we might have missed that
otherwise.

And running Swig over the new header file will give us `verify_password`
definitions in all our target languages.

```python
>>> h1 = libpasta.hash_password("hunter2")
>>> libpasta.verify_password(h1, "hunter2")
True
```

With very little work we have a Python function returning Python booleans, and
not just an integer which we may need to check the value.

## Taking it further: Structs and functions

Up to this point we are still dealing with very simple functions which requires
little interaction with the Rust code itself. The setup is just "thing goes in, 
Rust does computation, thing comes out". So the filler code we have is mostly
just type conversions.

However, libpasta supports configuration using the `Config` struct, which
impls the same functions, for example:

```rust
impl Config {
    fn new() -> Self {
        ...
    }

    fn hash_password(&self, password: &str) -> String {
        ...
    }
}
```
After consulting with the [FFI Omnibus][ffi-omni] again, we realise `Config`
needs to be used as an opaque pointer. Any methods of `Config` need to be
exposed as a new function (effectively turning `config.hash_password(pw)` into
`Config::hash_password(config, pw)`).
Following the same steps as before, we try to define the extern variant
as:

```rust

#[no_mangle]
pub extern fn config_new() -> *mut Config {
    ...
}


#[no_mangle]
pub extern fn config_hash_password(config: *const Config, pw: *const c_char)
    -> *mut c_char
{
    ...
}

#[no_mangle]
pub extern  fn config_free(config: *mut Config) {
    ..
}

```

cbindgen will happily oblige to turn `Config` into a opaque pointer by
defining

```C
struct Config;
```

and wrapping the other methods as usual.

However, this is where things get a bit more difficult. We cannot use the
`%newobject` trick in Swig from before, since we aren't able to clone
`Config` to anything meaningful in the target language. But we still don't
want to force the user to perform freeing manually.

We could follow the advice from the [FFI Omnibus](http://jakegoulding.com/rust-ffi-omnibus/objects/)
in each language to turn these into structs/classes/objects or whatever each
language offers, but this defeats the purpose of using Swig.

Instead, we create a new C++ class in our Swig interface file, which will be inlined in the wrapper code,
(using namespacing to avoid naming clashes but Swig will flatten namespaces by default). Since Swig
supports C++, these classes will be converted into the appropriate object in
the target languages.

```cpp
namespace libpasta {
    class Config {
        ffi::Config *self;

        public:
            Config() {
                self = config_new();
            };
            ~Config() {
                config_free(self);
                self = NULL;
            };
            char *hash_password(const char *password) {
                return config_hash_password(self, password);
            };
    };
}
```

Now Swig will do the work to convert these to proper, native methods. Which
can be used like:

```python
>>> import libpasta
>>> cfg = libpasta.Config()
>>> cfg
<libpasta.Config; proxy of <Swig Object of type 'libpasta::Config *' at 0x7fae3bb85b70> >
>>> cfg.hash_password("hunter2")
'$$scrypt$ln=14,r=8,p=1$6MFy2ynsD3eZcp8FCZcunw$zrdE1fOrCIZYFO0xHGopxBUnody4AZ4LQ640LkRXU9A'
```

Which in my opinion is pretty cool.

After creating these bindings, there is still the task of packaging each
language binding in each of the unique packaging methodologies... But that's an
orthogonal problem which exists in either case.

## What if

This is a pretty effective setup. We can write our Rust code as idiomatic as
we want, write a few standard extern functions to access the main methods,
and Swig mostly does the rest.

However, the whole Rust -> C -> C++ -> Swig process is really one, if not two,
hops too many. The C++ classes we are exposing are really the same Rust structs
we would like to expose. It would be interesting to know whether wrapper C++
code could be written for Rust, which would effectively do the same as cbindgen.

_Even better_ would be perhaps procedural macros for Rust structs and functions
which automatically derives these wrapper functions and builds the corresponding
header files. It would be interesting to know the potential pitfalls of this
approach.

## A few closing remarks

 * Some languages have projects dedicated to interacting with Rust. E.g.
   [ruru](https://github.com/d-unseductable/ruru) for Ruby <-> Rust. These
   potential perform better, or create better bindings, or have more features. I
   haven't investigated yet and would be interested to know. In the future
   individual bindings could be improved this way. 
 * I haven't _yet_ benchmarked the overhead of all of this. However, since
   password hashing is intentionally slow (0.1-0.5s for example), this overhead
   should hopefully be a negligible amount. But for other libraries this might
   not be acceptable.
 * Are there any obvious Rust patterns which are going to be a nightmare to wrap
   in C++? I haven't yet tried to wrap error handling yet, but Swig has support
   for this. Also, cbindgen will happily convert a sum type/tagged union enum
   into a similar C++ struct using `union`, but Swig doesn't yet support those,
   so they have to be handled a bit more manually.
 * For long-term projects, it's less likely that the API will be changing
   drastically, potentially reducing the value in doing any of the above. But
   its still useful (in my opinion) for the initial work.

Thanks for reading! Happy to respond to any comments on the [reddit thread](https://www.reddit.com/r/rust/comments/7z7pml/rust_for_crosslanguage_system_libraries_libpasta/), or reach out to me on 
[twitter](https://twitter.com/sam_js_).

[cbindgen]: https://github.com/eqrion/cbindgen
[ffi-omni]: http://jakegoulding.com/rust-ffi-omnibus/
[swig]: http://www.swig.org/

[^1]: This does have the unfortunate `unwrap`, which panics in case there is a
      `\0` byte in the string, which is permitted in Rust `String`s. In the case
      of libpasta, everything is usually base64 encoded so should not happen.