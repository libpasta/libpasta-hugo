from libpasta import *

password = read_password("Please enter your password:")
hash =  hash_password(password)
print("The hashed password is: ", hash)
