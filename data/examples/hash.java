public class test {
  public static void main(String argv[]) {
    String password  = pasta.read_password("Please enter your password:");
    String hash = pasta.hash_password(password);
    System.out.println("The hashed password is: " + hash);
  }
}