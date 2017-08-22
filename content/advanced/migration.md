+++
title = "Password Migration"
toc = true
weight = 5
+++

One of the core principles underlying `libpasta` is that it should be easy to
use best practice password hashing algorithms. Unfortunately, many people are
currently _not_ using these algorithms, and furthermore, "best practice" seems
to be very hard to pin down. To solve this, we include support for painless
migration, which can even be enabled automatically.

Migrating a password hash is a subtle problem. The whole point of password
storage is that you cannot recover the password. To solve this, `libpasta` uses
the onion approch.

Suppose we have a password hash `H = f(password, salt)`, and wish to migrate from
using algorithm `f` to algorithm `g`. Clearly we cannot compute `H' = g(password, salt)` 
without first knowing the password.

Hence, we instead compute `H' = g(f(password, salt), salt)`, applying the new
hash function on top of the old one.

In `libpasta`, this is represented by a hash of the form:  
`$!$argon2i$m=4096,t=3,p=1$$2y-mcf$cost=12$1hKt7q7c+grVXmLcaTrc1A$kVFouOipYHpVHXKT0vXZJLvvPztokcXuzAWoUT1Pxyg`
Note we have both `argon2i` and `2y-mcf` (bcrypt) in the hash value. This is a
bcrypt hash, with cost 12, which has then been further hashed using Argon2i.

Once the user next successfully logs in, this double-hash can simply be
updated once again to a standard, single hash.

To change hashing algorithms incurs a one-off cost to go through an re-hash
all passwords. Migration tools are coming soon. For example, for Ruby on Rails, 
the following Rake script could be used for password migration:

```ruby
namespace :pasta do
    desc "Updates all passwords to the default password algorithm"
    task migrate_passwords: :environment do
        User.all.each do |user|
            user.password_digest = Pasta::migrate_hash(user.password_digest)
            user.save
        end
    end
end
```
On each subsequent user login, there is an additional overhead incurred:
first the cost of computing `g(f(password))`, which is at worst the cost
of two long hashes, plus an additional computation of `g(password)`. However,
this migration step only need to happen once per customer, providing a
seamless transition experience.

Of course, there is the possibility that a user does not log in for such a long
time that they end up having multiple layers `h4(h3(h2(h1(password))))`, which
could potentially take a long time to migrate, and consume too much storage in
the database. Note that the storage only grows linearly in the length of the
parameters of `h1...h4`, since the salt/hash size is fixed. This additional time
incurred for an infrequent user is a minor tradeoff for security and
convenience.