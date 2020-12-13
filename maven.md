## maven useful commands
###  1. maven plugin help for parameters
```bash
mvn groupId:artifactId:[version]:help -Dgoal=xxx -Ddetail
# or
mvn plugin-prefix:help -Dgoal=xxx -Ddetail
```
or 
```bash
mvn help:describe -Dplugin=groupId:artifactId:[version] -Dgoal=xxx -Ddetail
# or
mvn help:describe -Dplugin=plugin-prefix -Dgoal=xxx -Ddetail
```

eg. 
```bash
mvn docker:help -Dgoal=build -Ddetail
# or
mvn io.fabric8:docker-maven-plugin:help -Dgoal=build -Ddetail
```
or
```
mvn help:describe -Dplugin=docker -Dgoal=build -Ddetail
```

### 2. maven execute with execution ID specified
if not specified execution in pom.xml for a plugin, it will use `default` by default.
```bash
mvn <plugin>:<goal>@<execution>
# or
mvn <plugin-group-id>:<plugin-artifact-id>[:<plugin-version>]:<goal>@<execution>
```
eg.
```
mvn docker:build@buildArtifactory -Pdocker-local
```

### 3. maven final effective pom.xml
will combine with parent pom xml and generate a final pom.xml
```
mvn help:effective-pom > pom-final.xml
```
#### dependent java version
```xml
<project>
  [...]
  <build>
    [...]
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>3.5.1<</version>
        <configuration>
          <!-- or whatever version you use -->
          <source>1.7</source>
          <target>1.7</target>
        </configuration>
      </plugin>
    </plugins>
    [...]
  </build>
  [...]
</project>
```


### copy jars to lib directory
```xml
<?xml version="1.0" encoding="UTF-8"?>

<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
       ...

    <dependencies>
       ...
    </dependencies>

    <build>
        <pluginManagement><!-- lock down plugins versions to avoid using Maven defaults (may be moved to parent pom) -->
            .....
        </pluginManagement>
        <plugins>
            <plugin>
                <artifactId>maven-dependency-plugin</artifactId>
                <executions>
                    <execution>
                        <!--will copy when `mvn package`-->
                        <phase>package</phase> 
                        <goals>
                            <goal>copy-dependencies</goal>
                        </goals>
                        <configuration>
                            <!-- in target/lib directory-->
                            <outputDirectory>${project.build.directory}/lib</outputDirectory> 
                        </configuration>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
</project>
```
