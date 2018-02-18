from libpasta import *

class User:
    password_hash = ""

    def auth_user():
        password = read_password("Enter password:")
        if verify_password(self.password_hash, password):
            print("The password is correct!")
            # ~> Handle correct password
        else:
            print("Incorrect password.")
            # ~> Handle incorrect password
