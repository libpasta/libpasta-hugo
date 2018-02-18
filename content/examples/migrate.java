import io.github.libpasta.pasta;
import io.github.libpasta.HashUpdate;

class User {
    String pw_hash;

    public boolean auth_user() {
        String pw = pasta.read_password("Enter password:");

        HashUpdate res = pasta.verify_password_update_hash(pw_hash, pw);
        switch (res.getTag()) {
            case Updated:
                pw_hash = res.getUpdated();
            case Ok:
                return true;
        }
        return false;
    }

    public static void migrate_users(User[] users) {
        for(User user : users) {
            HashUpdate res = pasta.migrate_hash(user.pw_hash);
            switch (res.getTag()) {
                case Updated:
                    user.pw_hash = res.getUpdated();
                case Ok:
                    System.out.println("Password correct"); break;
                case Failed:
                    System.out.println("Password incorrect");
            }
        }
    }

}
