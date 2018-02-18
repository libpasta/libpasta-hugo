import io.github.libpasta.Bcrypt;
import io.github.libpasta.Config;

public class config {
  public static void main(String[] args) {
    Bcrypt b = new Bcrypt(15);
    Config cfg = Config.with_primitive(b);
    String hash = cfg.hash_password("hunter2");
    System.out.println("The hashed password is: " + hash);
  }
}