### Download the jre from bash
```
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/jre.tar.gz http://download.oracle.com/otn-pub/java/jdk/8u40-b26/jre-8u40-linux-x64.tar.gz
```

### Download the jdk from bash
```
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/jdk.tar.gz http://download.oracle.com/otn-pub/java/jdk/8u40-b26/jdk-8u40-linux-x64.tar.gz
```

### Convert between Gradle and Maven
1. Gradle -> Maven
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

2. Maven -> Gradle
   Execute the `gradle init` after you installing the Gradle from the official site and you'll get a `setting.gradle` and `build.gradle`, That's all. 
