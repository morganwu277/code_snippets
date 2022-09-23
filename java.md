### PhantomReferenceTest
1. `System.gc()` doesn't necessarily trigger STW full gc. [JVM相关 - 深入理解 System.gc()](https://zhuanlan.zhihu.com/p/352974252)
2. `System.gc()` will try to add PhantomReference into the related ReferenceQueue
3. and then we need to dequeue from ReferenceQueue and clean ourselves.

So PhantomReference is born for those references that are not exactly sure about how the memory to be freed, eg. DirectByteBuffer. 

```java
public class PhantomReferenceTest {
    public static void main(String[] args) throws InterruptedException {
        // 1. -Xms10m -Xmx10m
        // ref: https://docs.oracle.com/javase/8/docs/api/java/lang/ref/PhantomReference.html
        // Phantom reference objects, which are enqueued
        // after the collector determines that their referents may otherwise be reclaimed.
        ReferenceQueue<byte[]> queue = new ReferenceQueue<>();
        PhantomReference<byte[]> phantomReference = new PhantomReference<>(new byte[1024 * 1024 * 5], queue);
        // null
        System.out.println("phantomReference before gc: " + queue.poll());
        System.gc();
        Thread.sleep(300L);
        // non-null after GC
        System.out.println("phantomReference after gc: " + queue.poll());

        /* will not cause the object to be enqueued
         * or phantomReference == null,
         * and then we are able to have next bytes allocated
         */
        phantomReference.clear();

        byte[] bytes = new byte[1024 * 1024 * 6];
        // 上述 是 PhantomReference 的手动释放。
        // PhantomReference 如何自动释放？
        // 像 https://blog.csdn.net/zbuger/article/details/70508450 的基本思路是：
        // 1. 后台启动一个 Thread 尝试去 refQueue.remove() 而这个 refQueue 只有在 Full GC 之后 才会被 enqueue
        // 2. 一旦 Enqueue 了之后 那么就可以 refQueue.remove() 出来 然后线程自动进行释放
    }
}
```

### BlockHound Usage for Reactor Projects
1. pom.xml dependency
```xml
        <dependency>
            <groupId>io.projectreactor.tools</groupId>
            <artifactId>blockhound</artifactId>
            <version>1.0.6.RELEASE</version>
            <scope>compile</scope>
        </dependency>
```
2. add next code into Spring `main()` fuction, just before `SpringApplication.run(AuthApplication.class, args);` line
```java
    if (StringUtils.isNotEmpty(System.getenv("BLOCK_HOUND_DEBUG"))) {
      // under dev env
      BlockHound.install(
              builder -> {
                builder.allowBlockingCallsInside("org.apache.logging.log4j.core.config.LoggerConfig", "callAppenders");
		// won't exit app when getting blocking calls.
                builder.blockingMethodCallback(
                  method -> log.error("BlockHoundException", new RuntimeException("Blocking Call !!! On method: " + method.toString()))
                );
              }
      );
    }
```
3. setup `-Djdk.attach.allowAttachSelf=true` [params](https://github.com/raphw/byte-buddy/issues/612#issuecomment-463618016) in your target JVM. 

and then all your blocking calls will be printed with ERROR logs when you have `BLOCK_HOUND_DEBUG` environment values.


### log4j slf4j , minimal configuration
- log4j.properties
```
# Root logger option
log4j.rootLogger=INFO, stdout

# Direct log messages to stdout
log4j.appender.stdout=org.apache.log4j.ConsoleAppender
log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
log4j.appender.stdout.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss} %-5p %c{1} - %m%n
```
- dependencies: next three as the very minimal requirements
```
    implementation 'log4j:log4j:1.2.17' // log4j
    implementation 'org.slf4j:slf4j-log4j12:1.7.31' // connect log4j and slf4j
    implementation 'org.slf4j:slf4j-api:1.7.31' //slf4j
```


### TrustStore & KeyStore
1. Redis TLS usage in JVM application, knowledge/commands would be useful for other JVM TLS application as well
	```sh
	### 1 GENERATE EMPTY JKS FILE
	# 1.1 generate a JKS file with teiid entry
	keytool -genkey -alias teiid -keyalg RSA -validity 365 -keystore server.keystore -storetype JKS -storepass MyPass123
	# 1.2 delete the teiid entry 
	keytool -delete -alias teiid -keystore server.keystore -storepass MyPass123
	# 1.3 list the entries
	keytool -list -keystore server.keystore -storepass MyPass123


	### 2 IMPORT CRT/KEY/CA INTO JKS
	# 2.1 package private and public crt/key into one single p12 file format
	openssl pkcs12 -export -in tls/redis.crt -inkey tls/redis.key -name redis-pkcs12 -out redis-pkcs12.p12
	> Export Password: MyPass123
	# 2.2 import single file p12 format into JKS
	keytool -importkeystore -deststorepass MyPass123 -destkeystore server.keystore -srckeystore redis-pkcs12.p12 -srcstoretype PKCS12
	# 2.3 also import CA into JKS
	keytool -import -alias redis-root-ca -trustcacerts -file tls/ca.crt -keystore server.keystore

	### 3. CONNECT 
	redis-cli --tls --cert ./redis.crt --key redis.key --cacert ca.crt -p 6443 -a redis2secure

	### OR See Other Java Library usage, eg. Redisson
	```

2. put key/crt/pem into keystore

https://gist.github.com/eransharv/9de8e94faae5bde70dfcdfa7d8e6157b#gistcomment-2123071 

Download the certificates through the UI. The zip contains 3 files:

garantia_ca.pem
garantia_user.crt
garantia_user_private.key

Create p12 file, using the crt file and the private key file ( can be used as keyStore):
> `openssl pkcs12 -export -in garantia_user.crt -inkey garantia_user_private.key -out JedisSSL.p12`

Create the jks file, using the pem file ( can be used as trustStore ):
> `keytool -import -alias bundle -trustcacerts -file garantia_ca.pem -keystore keystore.jks`

eg. Here we have redisson client to be used:
```java
Config config = new Config(); 
config.useSingleServer() 
.setAddress("rediss://redis-10928.c10.us-east-1-3.ec2.cloud.redislabs.com:10928") 
.setSslEnableEndpointIdentification(false);
.setSslKeystore(URI.create("file:/C:/Devel/projects/redisson/JedisSSL.p12"))  // client crt/key
.setSslKeystorePassword("test1234") 
.setSslTruststore(URI.create("file:/C:/Devel/projects/redisson/keystore.jks")) // root CA
.setSslTruststorePassword("test1234"); 

RedissonClient redisson = Redisson.create(config); 
RBucket<String> bucket = redisson.getBucket("foo"); 
bucket.set("1"); 
System.out.println("bucket " + bucket.get());
```

3. extract key/crt/pem from keystore

https://serverfault.com/a/715841

- export the .crt
```
keytool -export -alias mydomain -file mydomain.der -keystore mycert.jks
```
- convert the cert to PEM
```
openssl x509 -inform der -in mydomain.der -out certificate.pem
```
- export the key
```
keytool -importkeystore -srckeystore mycert.jks -destkeystore keystore.p12 -deststoretype PKCS12
```
- concert PKCS12 key to unencrypted PEM
```
openssl pkcs12 -in keystore.p12  -nodes -nocerts -out mydomain.key
```

### garbage collection log analysis
using `-XX:+UseSerialGC` with params:
```
-XX:+PrintGCDetails
-XX:+PrintGCDateStamps
-XX:+PrintGCTimeStamps
```
log sample ( 1 time on Young Gen, 1 time on all heap ) 
```
2015-05-26T14:45:37.987-0200: 151.126: 
  [GC (Allocation Failure) 151.126:
    [DefNew: 629119K->69888K(629120K), 0.0584157 secs]
    1619346K->1273247K(2027264K), 0.0585007 secs] 
  [Times: user=0.06 sys=0.00, real=0.06 secs]

2015-05-26T14:45:59.690-0200: 172.829: 
  [GC (Allocation Failure) 172.829: 
    [DefNew: 629120K->629120K(629120K), 0.0000372 secs]
    172.829: [Tenured: 1203359K->755802K(1398144K), 0.1855567 secs]
    1832479K->755802K(2027264K),
    [Metaspace: 6741K->6741K(1056768K)], 0.1856954 secs]
  [Times: user=0.18 sys=0.00, real=0.18 secs]
```
Ref:
https://blog.csdn.net/renfufei/article/details/49230943

### tomcat start and processing phase
Acceptor -> Poller -> Worker

http-nio-8080-Acceptor-0 -> http-nio-8080-ClientPoller-0 -> http-nio-8080-exec-0

ref: https://zhuanlan.zhihu.com/p/85448047


### Exception management
refer to: reactor `reactor.core.Exceptions#throwIfFatal`
```java
	/**
	 * Throws a particular {@code Throwable} only if it belongs to a set of "fatal" error
	 * varieties. These varieties are as follows: <ul>
	 *     <li>{@code BubblingException} (as detectable by {@link #isBubbling(Throwable)})</li>
	 *     <li>{@code ErrorCallbackNotImplemented} (as detectable by {@link #isErrorCallbackNotImplemented(Throwable)})</li>
	 *     <li>{@link VirtualMachineError}</li> <li>{@link ThreadDeath}</li> <li>{@link LinkageError}</li> </ul>
	 *
	 * @param t the exception to evaluate
	 */
	public static void throwIfFatal(@Nullable Throwable t) {
		if (t instanceof BubblingException) {
			throw (BubblingException) t;
		}
		if (t instanceof ErrorCallbackNotImplemented) {
			throw (ErrorCallbackNotImplemented) t;
		}
		throwIfJvmFatal(t);
	}

	/**
	 * Throws a particular {@code Throwable} only if it belongs to a set of "fatal" error
	 * varieties native to the JVM. These varieties are as follows:
	 * <ul> <li>{@link VirtualMachineError}</li> <li>{@link ThreadDeath}</li>
	 * <li>{@link LinkageError}</li> </ul>
	 *
	 * @param t the exception to evaluate
	 */
	public static void throwIfJvmFatal(@Nullable Throwable t) {
		if (t instanceof VirtualMachineError) {
			throw (VirtualMachineError) t;
		}
		if (t instanceof ThreadDeath) {
			throw (ThreadDeath) t;
		}
		if (t instanceof LinkageError) {
			throw (LinkageError) t;
		}
	}
```

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

### Lettuce Spring Redis Factory Bean
```java
    // 2 connections
    // 2094.5514 RPS
    @Bean
    public RedisConnectionFactory redisConnectionFactory() {
        ClientResources res = DefaultClientResources.builder()
                .ioThreadPoolSize(64)
                .computationThreadPoolSize(64)
                .build();
        LettuceClientConfiguration clientConfig = LettucePoolingClientConfiguration.builder()
                .clientResources(res)
                .build();
        RedisClusterConfiguration clusterConfiguration = new RedisClusterConfiguration()
                .clusterNode("redis-cluster-0.redis-cluster-headless", 6379);
        clusterConfiguration.setPassword("redis2secure");
        RedisStandaloneConfiguration standaloneConfiguration = new RedisStandaloneConfiguration();
        standaloneConfiguration.setHostName("10.5.5.5");
        standaloneConfiguration.setPort(32768);
        return new LettuceConnectionFactory(standaloneConfiguration, clientConfig);
    }
```

### mock static java method
1. ensure `mockito` version > 3.4
2. add mvn dependency
```
        <dependency>
            <groupId>org.mockito</groupId>
            <artifactId>mockito-inline</artifactId>
            <version>3.8.0</version>
            <scope>test</scope>
        </dependency>
```

Next is sample code on static method with chain calls:
```
    @Test
    public void testMock() {
        // ref: https://www.baeldung.com/mockito-mock-static-methods
        final MockedStatic<RIP> ripMockedStatic = Mockito.mockStatic(RIP.class);
        // this is for cascading mock on chain calls
        final Local mockLocal = Mockito.mock(Local.class, RETURNS_DEEP_STUBS);
        // this is for static method mock
        ripMockedStatic.when(RIP::local).thenReturn(mockLocal);
        final String mockString = "this is my region name";
        Mockito.when(mockLocal.region(Mockito.anyString()).name()).thenReturn(mockString);
        final String returnString = RIP.local().region("xxx").name();
        Assertions.assertEquals(returnString, mockString);
    }

    static class RIP {
        public static Local local(){
            return new Local();
        }
    }
    static class Local{
        public Region region(String a){
            return new Region();
        }
    }
    static class Region {
        public String name(){
            return "region";
        }
    }
```
