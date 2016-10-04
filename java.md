### Download the jre from bash
```
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/jre.tar.gz http://download.oracle.com/otn-pub/java/jdk/8u40-b26/jre-8u40-linux-x64.tar.gz
```

### Download the jdk from bash
```
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/jdk.tar.gz http://download.oracle.com/otn-pub/java/jdk/8u40-b26/jdk-8u40-linux-x64.tar.gz
```

### Convert between Gradle and Maven
1. **Gradle -> Maven**   
   Your build.gradle should be like 
    ```gradle
   apply plugin: 'java'
   apply plugin: 'maven'
    
   group = 'com.bazlur.app'
   // artifactId is taken by default, from folder name
   version = '0.1-SNAPSHOT'
    
   dependencies {
   compile 'commons-lang:commons-lang:2.3'
   }
   ```
   Execute the `./gradlew install` command, after that, you'll get a `pom-default.xml` under your `build/poms` subfolder. 

2. **Maven -> Gradle**   
   Execute the `gradle init` after you installing the Gradle from the official site and you'll get a `setting.gradle` and `build.gradle`, That's all. 

### java -Xprof meaning
Here is an example output: 
```
...............
Flat profile of 19.00 secs (223 total ticks): main
  Interpreted + native Method
  1.3% 1      + 0      java.lang.AbstractStringBuilder.append
  1.3% 1      + 0      java.lang.String.<init>
  2.6% 2      + 0      Total interpreted

  Compiled + native Method
  51.3% 0  + 40     java.lang.AbstractStringBuilder.expandCapacity
  29.5% 23 + 0      java.lang.AbstractStringBuilder.append
  10.3% 8  + 0      java.lang.StringBuilder.toString
  6.4% 0   + 5      java.lang.String.<init>
  97.4% 31 + 45     Total compiled

  Thread-local ticks:
  65.0% 145 Blocked (of total)

Flat profile of 0.01 secs (1 total ticks): DestroyJavaVM
  Thread-local ticks:
  100.0% 1 Blocked (of total)

  Global summary of 19.01 seconds:
  100.0% 929 Received ticks
  74.6%  693 Received GC ticks
  0.8%     7 Other VM operations
```
It says that 51.3% per cent of the computation time was spent in native method expandCapacity and
a further 29.5% was spent in method append, both from class AbstractStringBuilder. This makes it plausible that the culprits are + and += on String, which are compiled into append calls.    
But what is even more significant is the bottom section, which says that 74.6% of the total time was spent in garbage collection, and hence less than 25% was spent in actual computation. This indicates a serious problem with allocation of too much data that almost immediately becomes garbage. 

__Interpreted + native__: This figure shows the ticks used by the JVM while executing interpreted methods. The extra (+native) columns shows the native C methods that were called by these interpreted methods.   
__Compiled + native__: This figure shows the ticks used by the methods that were already parsed by the JIT compiler. After running your program a while, most of your major consumers from the interpreted section should appear as "Compiled" as JIT will compile them.       
__Stubs + native__: This figure is for JNI calls. This will likely to use the "native" column only as JNI is of course executed as a series of native calls.   
__Thread-local ticks__: This is listed as "miscellaneous" other entries and was written somewhere that "should not raise concerns from performance optimization perspective". I am not sure how much we want to trust that, but XProf is really not a documented tool just as you stated above.    


### Java exception, bad performance
Two causes:    
1. the method `public synchronized native Throwable fillInStackTrace()` which is from Throwable.java, the base class of all Exceptions.   
2. Fills in the execution stack trace.    
Reference: http://www.blogjava.net/stone2083/archive/2010/07/09/325649.html    
What brings:    
Exception object need __4 times more time__ to be created than the normal object.   

### Fork/Join Framework vs. Parallel Streams vs. ExecutorService: The Ultimate Fork/Join Benchmark 
http://blog.takipi.com/forkjoin-framework-vs-parallel-streams-vs-executorservice-the-ultimate-benchmark/ Compare the IO or Non-IO and check out the selections. 
