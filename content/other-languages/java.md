+++
title = "Java"
toc = true
weight = 5

+++

There is currently support for the base functionality in Java.

The library can be obtained by following the instruction in the
[repository](https://github.com/libpasta/libpasta-java/). The simplest
being to obtain the precompiled jar file from the
[releases page](https://github.com/libpasta/libpasta-java/releases).

Once obtained a simple example such as the following can be constructed:

```java
import io.github.libpasta.*;

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

```bash
$ javac -cp .:libpasta-java.{version}.jar test.java
$ java -cp .:libpasta.jar test
Please enter the password (hint: hello123):
Correct password
```

If you see the following:
```
SLF4J: Failed to load class "org.slf4j.impl.StaticLoggerBinder".
SLF4J: Defaulting to no-operation (NOP) logger implementation
SLF4J: See http://www.slf4j.org/codes.html#StaticLoggerBinder for further details.
```

Make sure to add a SLF4J logger jar to the classpath. For example, the slf4j-nop
logger, which simply ignores all logging messages, can be run with
```bash
$ java -cp .:libpasta.jar:slf4j-nop-1.7.25.jar test
```