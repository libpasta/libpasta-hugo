import io.github.libpasta.pasta;

public class verify {
    private String password_hash;

    public void authUser() {
        String password = pasta.read_password("Enter password:");
        if(pasta.verify_password(self.password_hash, password)) {
            System.out.println("The password is correct!");
            // ~> Handle correct password
        } else {
            System.out.println("Incorrect password.");
            // ~> Handle incorrect password
        }
    }
}
