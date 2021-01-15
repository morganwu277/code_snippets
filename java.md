### Exception 管理
refer to: reactor `reactor.core.Exceptions#throwIfFatal`

### print stack when debugging
```java
java.utils.Arrays.toString(Thread.currentThread().getStackTrace())
```
### keytool import cert
import `/var/jenkins_home/G2-AC.pem` as `G2-AC-alias`: 
```bash
keytool -import -noprompt -v -trustcacerts -alias G2-AC-alias \
        -file /var/jenkins_home/G2-AC.pem \
        -keystore /usr/local/openjdk-8/jre/lib/security/cacerts \
        -keypass changeit \
        -storepass changeit
```

### jmx monitoring
```bash
-Dcom.sun.management.jmxremote
-Dcom.sun.management.jmxremote.authenticate=false
-Dcom.sun.management.jmxremote.ssl=false
-Dcom.sun.management.jmxremote.local.only=false
-Dcom.sun.management.jmxremote.port=1099
-Dcom.sun.management.jmxremote.rmi.port=1099
-Djava.rmi.server.hostname=127.0.0.1
```


### Jar Operations
1. Create a jar/war file
```bash
cd tmp
jar xvf saml.war   # extrat the war file
# vi xxx, doing some changes
jar cvf saml.war . # create the war file again
mv saml.war ../    # keep the war file
rm -rf tmp         # delete this tmp folder
```
2. Update a jar/war file     
   Must keep the relative path using `WEB-INF/classes/applicationContext.xml`      
   Can't go into `WEB-INF/classes/` and `jar uvf` from there
```bash
jar uvf saml.war ./WEB-INF/classes/applicationContext.xml
```

### Download the jre from bash

```
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/jre.tar.gz http://download.oracle.com/otn-pub/java/jre/8u40-b26/jre-8u40-linux-x64.tar.gz
```

### Download the jdk from bash

```
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/jdk.tar.gz http://download.oracle.com/otn-pub/java/jdk/8u111-b14/jdk-8u111-linux-x64.tar.gz
```

### Automatically install jdk in ubuntu

```bash
apt-add-repository ppa:webupd8team/java
apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
apt-get install oracle-java8-installer -y
java -version
apt-get install oracle-java8-set-default -y
```

For Debian, we need next commands extra: 

```bash
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
apt-get update
apt-get install oracle-java8-installer
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


### jcmd usage
https://docs.oracle.com/javacomponents/jmc-5-4/jfr-runtime-guide/run.htm#JFRUH177
After getting the jfr file, load it into `jmc` (open this command from terminal) 

### Java exception, bad performance
Two causes:    
1. the method `public synchronized native Throwable fillInStackTrace()` which is from Throwable.java, the base class of all Exceptions.   
2. Fills in the execution stack trace.    
Reference: http://www.blogjava.net/stone2083/archive/2010/07/09/325649.html    
What brings:    
Exception object need __4 times more time__ to be created than the normal object.   

### Fork/Join Framework vs. Parallel Streams vs. ExecutorService: The Ultimate Fork/Join Benchmark 
http://blog.takipi.com/forkjoin-framework-vs-parallel-streams-vs-executorservice-the-ultimate-benchmark/ Compare the IO or Non-IO and check out the selections. 

### Print Java GC
Here is a simple combination : `java -Xmx400m -Xms400m -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:/tmp/gc-paper77.log ...` 

- -XX:+PrintGC (or the alias -verbose:gc)

   ```bash
   [GC 246656K->243120K(376320K), 0,0929090 secs]
   [Full GC 243120K->241951K(629760K), 1,5589690 secs]
   ```
- -XX:+PrintGCDetails

   Here is a sample of _Simple GC_
   
   ```bash
   [GC
      [PSYoungGen: 142816K->10752K(142848K)] 246648K->243136K(375296K),
      0,0935090 secs
   ]
   [Times: user=0,55 sys=0,10, real=0,09 secs]
   ```
   Here is a sample of _Full GC_

   ```bash
   [Full GC
      [PSYoungGen: 10752K->9707K(142848K)]
      [ParOldGen: 232384K->232244K(485888K)] 243136K->241951K(628736K)
      [PSPermGen: 3162K->3161K(21504K)],
      1,5265450 secs
   ]
   [Times: user=10,96 sys=0,06, real=1,53 secs]
   ```
- -XX:+PrintGCTimeStamps and -XX:+PrintGCDateStamps

   Here is for _GC Timestamps_
   
   ```bash
   0,185: [GC 66048K->53077K(251392K), 0,0977580 secs]
   0,323: [GC 119125K->114661K(317440K), 0,1448850 secs]
   0,603: [GC 246757K->243133K(375296K), 0,2860800 secs]
   ```
   Here is for _GC DateStamps_
   
   ```bash
   2014-01-03T12:08:38.102-0100: [GC 66048K->53077K(251392K), 0,0959470 secs]
   2014-01-03T12:08:38.239-0100: [GC 119125K->114661K(317440K), 0,1421720 secs]
   2014-01-03T12:08:38.513-0100: [GC 246757K->243133K(375296K), 0,2761000 secs]
   ```

### jstat command result description 

Usually we use `jstat -gcutil <pid> 20000` to check GC activity, flash every 2 seconds!

Observe different memory areas changes!

```bash
[03:32 PM morganwu@v1020-wn-202-109 ~]$ jstat -gc 9235
 S0C    S1C    S0U    S1U      EC       EU        OC         OU       MC     MU    CCSC   CCSU   YGC     YGCT    FGC    FGCT     GCT   
4352.0 4352.0  0.0   4352.0 34944.0  14774.9   103664.0   79205.4   62336.0 57163.3 9132.0 7734.2     19    0.192   4      0.030    0.222
```
__OU,PU,EU,S0U,S1U are the most important__

- S0C  Current survivor space 0 capacity (KB).
- S1C  Current survivor space 1 capacity (KB).
- **S0U  Survivor space 0 utilization (KB).**
- **S1U  Survivor space 1 utilization (KB).**
- EC  Current eden space capacity (KB).
- **EU  Eden space utilization (KB).**
- **OC  Current old space capacity (KB).**
- OU  Old space utilization (KB).
- PC  Current permanent space capacity (KB).
- **PU  Permanent space utilization (KB).**
- YGC  Number of young generation GC Events.
- YGCT  Young generation garbage collection time.
- FGC  Number of full GC events.
- FGCT  Full garbage collection time.
- GCT  Total garbage collection time.


### install jar into local maven repository
```bash
mvn install:install-file -Dfile=./lib/GlobalPayWSClient.jar \
   -DgroupId=westernunion.com.partnerapiwebservice \
   -DartifactId=GlobalPayWSClient \
   -Dversion=1.0 \
   -Dpackaging=jar \
   -DlocalRepositoryPath="$HOME/.m2/repository/"
```


