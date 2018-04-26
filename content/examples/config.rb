require 'libpasta'

config = Pasta::Config.with_primitive(Pasta::Bcrypt.new(15))
pw_hash = config.hash_password("hunter2")
puts "The hashed password is: ", pw_hash
