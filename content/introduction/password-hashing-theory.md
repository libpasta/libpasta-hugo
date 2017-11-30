+++
title = "Password hashing theory"
toc = true
weight = 9

+++

## Why hash passwords?

Let's start with the most common use of passwords: user authentication.

The general setting is that an individual has a username and a password, 
e.g. `username: alice` and `password: hunter2`.

When Alice first registers on a website, a new account is created, and the
password is stored in the database, so that Alice can prove she is indeed Alice

```C
id | username | password | creation-date | ...
------------------------------------------------
1  | alice    | hunter2  | 2017-07-14    | ...
```

However, if somebody gains access to this database with malicious intent -
whether external hackers, or internal such as a database admin - Alice's
password is sitting in the open.

This is bad, since Alice is a typical user who likes to re-use the same
password across multiple services. Unfortunately, service providers do
not have the luxury of assuming all users have unique, high-entropy passwords.

Hence we want to apply a [one-way function][owf] `f` to the password, so that
nobody can reverse the function `f(password)` and work out the password, but
given a password `other-password` it is easy to check whether 
`f(password) == f(other-password)`.

From the wikipedia page, we learn that SHA256 is a candidate one-way function, 
so we go ahead and use this as our hash function.

Now, our database might look something like this:

```C
id | username | password    | creation-date | ...
--------------------------------------------------
1  | alice    | f52fbd32... | 2017-07-14    | ...
```

This looks better, now the password isn't revealed in the clear. However, this
is actually not much better than the cleartext version.

**Plain cryptographic hash functions are not suitable for password hashing functions.**

Not SHA256, not SHA512, and no, not MD5.

## Brute force attacks

In the previous example, we simply applied SHA256 to attempt to hide the
password.

The reason for this is due to one of the fundamental requirements of password
hashing algorithms: computing many outputs should be _slow_.

As in the previous example, suppose the attacker has access to the entire
password database, with usernames and SHA256 hashes of passwords.

The attacker can take a list of [common password][leaked pws] and simply test
every single value against the database. Looking at [some commodity hardware][mining hw], 
we see that (at the time of writing), $2,400 USD can get you a machine which computes
14,000,000,000,000 hashes per _second_.

To put that in perspective, that can compute _every_ 7 character password made up of `a-zA-Z0-9` in [less than once second](https://www.wolframalpha.com/input/?i=(26%2B26%2B10)%5E7%2F14000000000000).

Thus we have the great dichotomy of password hashing:

**Computing one password hash should be fast, computing many should be slow**

## Password hashing algorithms

To be resistant to a brute-force attack, password hashing algorithms are
intentionally made to be slow. As a simple example of this, we have
[PBKDF2](https://en.wikipedia.org/wiki/PBKDF2), which is effectively "take a
cryptographic hash function, and repeat it N times".

Password hashing algorithms allow you to choose parameters to slow down the 
hash function. For interactive logins (think: website login), choosing
parameters such that login takes half a second is reasonable.

If it takes half a second to compute a single password hash, then guessing a
7 character password as before would take [over 55 thousand years](https://www.wolframalpha.com/input/?i=(26%2B26%2B10)%5E7%2F2+seconds).

However, in practice attackers will be using the list of [common passwords][leaked pws]
we mentioned before. Even checking the top 10,000 most passwords will only take
about an hour and a half.

Are these password doomed to be recovered that easily?


## Salting password hashes

Before, we saw that many password could be recovered in just an hour and a half.
It was implicitly assumed that for any given password, the value stored in the 
database would be the same for any user. Suppose Alice and Charlie happen to share
the same common password:

```C
id | username | password    | creation-date | ...
--------------------------------------------------
1  | alice    | cXmBfX44... | 2017-07-14    | ...
2  | bob      | BlEi9jKX... | 2017-07-10    | ...
3  | charlie  | cXmBfX44... | 2017-07-01    | ...

```
Therefore, we typically add what is called a "salt" as an input to a password
hash. This is a per-user unique value. So we get `hash = f(password, salt)`.

Since the salt is unique for each user, any brute force attack would need to
be mounted on a _per-user_ basis. This is a huge improvement when the attacker
is simply interested in recovering as many passwords as possible, but is not
necessarily interested in a specific user.

## Keyed hashes

People familiar with the basics of cryptography might be wondering why
we are not using encryption to protect the password hashes. Indeed, without the
key, an encrypted hash is worthless to an attacker.

Since we do not need decryption algorithms, we can use keyed hash functions such
as [HMAC](https://en.wikipedia.org/wiki/Hash-based_message_authentication_code)
instead. This has the same effect, without the key `k` it will be impossible to
compute `f_k(password, salt)`, and thus an attacker would not be able to check
whether their password guess is correct.

Properly protecting the key `k` is a difficult problem, and compromise
of `k` renders it useless. One effective way is to store `k` in  specialised
hardware such as an
[HSM](https://en.wikipedia.org/wiki/Hardware_security_module).
However, there exist [solutions (warning: PDF)][pythia] which can help in making
keyed solutions more accessible.

Another option is to involve a key in the storage mechanism to encrypt the
password hash after hashing. While this has a number of drawbacks compared to
using HMAC, one benefit is that it becomes possible to perform key rotation. In
the event that the password storage is compromised, but not the encryption key,
the key used to store passwords can be updated, rendering the leaked passwords
useless.

We discuss how to use keys in `libpasta` in [Keyed Hashes](../../advanced/keyed).


## Memory hard password hashes

In recent times, such as in the [password hashing competition][phc], 
memory hard password hashing has been emphasised as an important part of the
design criteria.

The main concept here is that it can be significantly cheaper to perform
computation on custom hardware (e.g. ASICs), than on a general purpose CPU.

Before, we discussed the requirement that it should be fast to compute a single 
output, but slow to compute many. In order to make this as balanced as possible, 
we need to ensure that an adversary computing many hashes on custom hardware should
not have an advantage over the innocent party using general-purpose hardware.

As a potential solution to this, memory-hard hashing functions have been
proposed. Reading and writing to memory is an operation which is approximately
equally expensive on custom hardware, and the cost to produce ASICs capable of
handling more memory is significantly higher. Therefore, the advantage of these
custom solutions is reduced.

## Summary

Password hashing is essential to protect passwords from being leaked after a
data breach. However, it is far from straightforward given the many
considerations in play, such as: salting, security-parameters choices, key
management, and memory-hardness.

Hence, we created libpasta to help accomodate the needs of the majority of
use cases, providing an easy-to-use API which removes the necessity for the
technical knowledge to choose appopriate algorithms and parameters.


[owf]: https://en.wikipedia.org/wiki/One-way_function
[leaked pws]: https://wiki.skullsecurity.org/Passwords
[mining hw]: https://en.bitcoin.it/wiki/Mining_hardware_comparison
[phc]: https://password-hashing.net/
[pythia]: https://www.usenix.org/system/files/conference/usenixsecurity15/sec15-paper-everspaugh.pdf
