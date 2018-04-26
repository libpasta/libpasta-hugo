require 'libpasta'

class User
    attr_accessor :pw_hash
    @pw_hash = ""


    def auth_user
        pw = Pasta::read_password("Enter password: ")
        res = Pasta::verify_password_update_hash(self.pw_hash, pw)
        case res.tag
        when Pasta::HashUpdate::Updated
            self.pw_hash = res.updated
            return true
        when  Pasta::HashUpdate::Ok
            return true
        else
            return false
        end
    end
end

def migrate_users(users)
    for user in users do
        res = Pasta::migrate_hash(user.pw_hash)
        if res.tag.eql? Pasta::HashUpdate::Updated
            user.pw_hash = res.updated
        end
    end
end

