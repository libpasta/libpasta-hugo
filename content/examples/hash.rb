require 'libpasta'

password = Pasta::read_password "Please enter your password:"
hash = Pasta::hash_password(password)
puts "The hashed password is: ", hash
