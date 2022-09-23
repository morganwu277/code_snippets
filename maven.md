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
# or here we can see `docker:buildEcs` is the execution actually, but we have to write full format here, since `:` could have confusion, so we have to keep full format, so it can correctly extract specific fields and meanings 
mvn io.fabric8:docker-maven-plugin:0.23.0:build@docker:buildEcs -Pdocker-ecs,VersionProvider
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


### 4. copy jars to lib directory
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

### 5. differences between `dependencyManagement` and `dependencies`
- dependencyManagement: declare dependency with version/scope.
  - normally used to unify package dependencies version/scope.
- dependencies: introduce dependency, will try to find `version/scope` from `<dependencyManagement>` recursively if no `version/scope` specified.
  - normally be inherited by children maven project.
Ref: https://www.jianshu.com/p/c8666474cf9a

### 6. maven 基础概念梳理

maven 基础概念梳理
https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html#a-build-lifecycle-is-made-up-of-phases

内置 3 类 lifecycle

- clean: 负责 clean
- default: 负责 deployment
- site: 负责生成 project 的网站文档

每个lifecycle 都会包含一些 phase，比如下面是 default 的 lifecycle 的 phase（严格先后执行）

1. validate
2. compile
3. test: 在 package 之前执行单元测试
4. package: 
5. integration-test: process and deploy package
6. verify: 执行验证的过程
7. install: 安装到 local repo ~/.m2
8. deploy: 部署到 remote repo

一个 phase 是由一堆 goals 组成的， 或者说 goal 是绑定到 phase 上的，所以执行 phase 实际上执行的是 goal，如果一个 phase 没有绑定 goal 那么这个 phase 就不会被执行

例子：
  ```xml
  <plugin>
    <groupId>com.mycompany.example</groupId>
    <artifactId>display-maven-plugin</artifactId>
    <version>1.0</version>
    <executions>
      <execution>
        <!-- display-maven-plugin 的 time 的这个 goal 被绑定到 process-test-resource 这个 goal 上-->
        <phase>process-test-resources</phase> 
        <goals>
          <goal>time</goal>
        </goals>
      </execution>
    </executions>
  </plugin>
  ```

具体一个 plugin 都有哪些 goal 可以绑定到哪些 phase 通过执行 `mvn help:describe -Dplugin=io.fabric8:docker-maven-plugin -Ddetail` 可以获得结果，可以看到有些goal 是已经绑定到一些 phase 了，而有些goal 并未绑定，则可以自行绑定，具体看上面的 time 自行绑定的例子。

  ```bash
  [INFO] io.fabric8:docker-maven-plugin:0.34.1

  Name: docker-maven-plugin
  Description: Docker Maven Plugin
  Group Id: io.fabric8
  Artifact Id: docker-maven-plugin
  Version: 0.34.1
  Goal Prefix: docker

  This plugin has 14 goals: # 可以看到一共有 14 个 goal

  docker:build # 这是第一个 goal
    Description: Mojo for building a data image
    Implementation: io.fabric8.maven.docker.BuildMojo
    Language: java
    Bound to phase: install # 绑定到 install 这个 phase
  ```

至于 docker-maven-plugin 的具体配置 见 https://dmp.fabric8.io/#start-wait 

1. 激活 
那么 用 -Dsw.integration.test 就可以激活

或者不用这个 那么直接 -Pintegration-test-only 也能激活
```
  <profiles>
    <profile>
        <id>integration-test-only</id>
        <activation>
            <property>
                <!-- -Dsw.integration.test -->
                <name>sw.integration.test</name>
            </property>
        </activation>
        <properties>
          <box1.net>container:box2</box1.net>
          <box2.net>bridge</box2.net>
        </properties>
        <build>
            <pluginManagement>
                <plugins>
          ...
```
2. ...
