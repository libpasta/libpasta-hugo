+++
title = "Java"
toc = true
weight = 5

+++

SWIG generates a number of helper files for Java, and a JNI library for use.
For convenience, we have packaged these in a `.jar` file, which can be compiled
from scratch using the `make install_java` command.

Hence, we need the following files: `libpasta.so`, `libpasta_jni.so`, and 
`libpasta.jar`. Then, the following is sufficient to use the pasta functions:

```java
public class test {
  public static void main(String argv[]) {
    String hash = pasta.hash_password("hello123");
    String password  = pasta.read_password("Please enter the password (hint: hello123):");
    if (pasta.verify_password(hash, password)) {
        System.out.println("Correct password\n");
    } else {
        System.out.println("Sorry, that is incorrect\n");
    }
  }
}

```
And building the example with:

```c
    $ javac -cp .:../../libpasta.jar test.java
    $ java -cp .:../../libpasta.jar test
    Please enter the password (hint: hello123):
    Correct password
```