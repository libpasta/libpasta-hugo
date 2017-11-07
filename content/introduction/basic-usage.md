+++
title = "Basic Usage"
toc = true
weight = 5

+++

Here we give an overview of the core functionality of libpasta. Examples can
be viewed in different languages, with the full list of language support
found in [other languages](../../other-languages/).

The full Rust API documentation can be found [here](../../doc/libpasta).
Or will be found on [docs.rs](https://docs.rs/) once v0.1 is published.

### Password Hashes

A common scenario is that a particular user has password, which a service will check on each login to authenticate the user.

<div>
{{% tabs id="hash" titles="Java,Python,Rust" default="Rust" %}}

{{% tab "Java" %}}
{{< highlight java "hl_lines=4">}}
{{< code_snippet "hash.java" >}}
{{< /highlight >}}
{{% /tab %}}

{{% tab "Python" %}}
{{< highlight python "hl_lines=5`">}}
{{< code_snippet "hash.py" >}}
{{< /highlight >}}
{{% /tab %}}

{{% tab "Rust" %}}
{{< highlight rust "hl_lines=8">}}
{{< code_snippet "hash.rs" >}}
{{< /highlight >}}
{{% /tab %}}

{{% /tabs %}}
</div>

The above code randomly generates a salt, and outputs the hash in the following format:
`$$scrypt-mcf$log_n=14,r=8,p=1$pfJFg/hVSthuA5l...`.

Details for how this is serialized can be found in the [technical details chapter](../../technical-details/phc-string-format/). This adheres to libpasta's [strong defaults](../what-is-libpasta#secure-by-default) principle.

However, for using `libpasta` one only needs to know that `hash_password`
outputs a variable-length string.

#### Verifying passwords

Now that you have the hashed output, verifying that an inputted password is correct can be done as follows:

<div>
{{% tabs id="verify" titles="Java,Python,Rust" default="Rust" %}}

{{% tab "Rust" %}}
{{< highlight rust "hl_lines=11">}}
{{< code_snippet "verify.rs" >}}
{{< /highlight >}}
{{% /tab %}}

{{% tab "Python" %}}
{{< highlight python "hl_lines=8`">}}
{{< code_snippet "verify.py" >}}
{{< /highlight >}}
{{% /tab %}}


{{% tab "Java" %}}
{{< highlight java "hl_lines=6">}}
{{< code_snippet "verify.java" >}}
{{< /highlight >}}
{{% /tab %}}
{{% /tabs %}}
</div>


#### Password migration

One of the key features of `libpasta` is the ability to easily migrate passwords
to new algorithms.

Suppose we previously have bcrypt hashes in the following form:
`$2a$10$175ikf/E6E.73e83....`.
This a bcrypt hash, structured as `$<bcrypt identifier>$<cost>$<salthash>`.

`libpasta` includes a simple work flow for migrating passwords to a new
algorithm (or new parameterization of an existing algorithm).  
First, wrap existing hashes in the new algorithm to ensure their 
security immediately. Second, as users log in, update the wrapped hashes to just
use the new algorithm. Wrapping simply takes an existing hash and re-hashes it 
with the new algorithm. 

The following code first wraps an existing hash, and then a move to just using
the new algorithm:

<div>
{{% tabs id="migrate" titles="Rust" default="Rust" %}}

{{% tab "Rust" %}}
{{< highlight rust "hl_lines=12 19">}}
{{% code_snippet "migrate.rs" %}}
{{< /highlight >}}
{{% /tab %}}

{{% tab "Python" %}}
{{% /tab %}}

{{% /tabs %}}
</div>



In the first step, we do not need the user's password (and can therefore
apply this to all user passwords when desired). However, the password hash is now
comprised of both a bcrypt computation AND an argon2 computation.

In the second step, if the user correctly enters their password, then a new hash
is computed from scratch with a fresh salt using the new algorithm. This
requires updating the stored version of the hash.

More detailed information of password migration can be found
[here](../../advanced/migration).

#### Basic configuration

`libpasta` is designed to work out-of-the box with strong defaults. However,
other configurations are supported through use of the `Config` object.
In particular, this is necessary to use [keyed functions](../../advanced/keyed).

This comes with the additional overheard that the config must be explicitly
used.

For example, suppose we wish to use bcrypt with `cost=15` as the default
algorithm.

<div>
{{% tabs id="config" titles="Rust" default="Rust" %}}

{{% tab "Rust" %}}
{{< highlight rust "hl_lines=12 19">}}
{{% code_snippet "config.rs" %}}
{{< /highlight >}}
{{% /tab %}}

{{% tab "Python" %}}
{{% /tab %}}

{{% /tabs %}}
</div>

Additionally, values may be set using a configuration file. Written in YAML,
these look as follows:

```yaml
default: Custom
keyed: ~
primitive: 
  id: "scrypt"
  params: 
    ln: 11
    r: 8
    p: 1

```

This specifies the algorithm to use, in this case, scrypt. Similar to the above,
to use this config use the `Config::from_file` method.

`libpasta` also has a [parameter selection tool](../../advanced/tuning) which
can optionally output configuration values. 
