from libpasta import *

class User:
    def auth_user(self):
        pw = read_password("Enter password")
        res = verify_password_update_hash(self.pw_hash, pw)
        if res.tag == HashUpdate.Updated:
            self.pw_hash = res.Updated
            return true
        elif res.tag == HashUpdate.Ok:
            return true
        else:
            return false

def migrate_users(users):
    for user in users:
        res = migrate_hash(user.pw_hash)
        if res.tag == HashUpdate.Updated:
            user.pw_hash = res.updated
