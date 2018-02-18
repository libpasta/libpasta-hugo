from libpasta import *

config = Config.with_primitive(Bcrypt(15))
pw_hash = config.hash_password("hunter2")
print("The hashed password is: ", pw_hash)
