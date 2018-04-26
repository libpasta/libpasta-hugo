require 'libpasta'

class User
    attr_accessor :pw_hash
    @pw_hash = ""

    def auth_user
        password = Pasta::read_password("Enter password: ")
        if Pasta::verify_password(self.pw_hash, password)
            puts "The password is correct!"
            # ~> Handle correct password
        else
            puts "Incorrect password."
            # ~> Handle incorrect password
        end
    end
end
