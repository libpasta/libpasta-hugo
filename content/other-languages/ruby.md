+++
title = "Ruby"
toc = true
weight = 5

+++

In the future Ruby will be supported through a Ruby gem. For now, SWIG generates
a `pasta.so` extension which can be used directly by Ruby:

```ruby
require './pasta.so'

hash = Pasta::hash_password("hello123")
password = Pasta::read_password("Please enter the password (hint: hello123):")
if Pasta::verify_password(hash, password)
    puts "Correct password"
else
    puts "Sorry, that is incorrect"
end
```
