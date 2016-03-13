## use alpine as minimal image, alpine best practices
* use `http://nl.alpinelinux.org/alpine/v3.2/main` as mirror repository /etc/apk/respositories
* `RUN apk -U add bind-tools` to make sure dns works correctly under k8s cluster.

## This is a sample Dockerfile containing all the useful points how to build a image
```
 FROM ubuntu:latest
 MAINTAINER xxx "xxx@qq.com"
 
 # 设置root账户为后续命令的执行者
 USER root
 
 # 执行操作
 RUN apt-get update
 RUN apt-get install -y nginx
 RUN ["apt-get", "update"]
 
 # 使用&&拼接命令
 RUN touch test.txt && echo "abc" >> abc.txt
 
 # 对外暴露端口
 EXPOSE 80 8080 1038
 
 # 添加文件，如果ADD压缩文件，会先解压缩，如果是网络文件，会先下载
 ADD abc.txt /opt/
 
 # 添加文件夹
 ADD /webapp /opt/webapp
 
 # 添加网络文件
 ADD https://www.baidu.com/img/bd_log1.png /opt/
 
 # 设置环境变量
 ENV WEBAPP_PORT 9090
 
 # 设置工作目录 
 WORKDIR /opt/
 
 # 设置启动命令, docker run 的参数会拼接到这个后面
 ENTRYPOINT ["ls"]
 
 # 设置启动参数, docker run 的参数会覆盖这个
 CMD ["-a", "-l"]
 
 # 设置卷 挂载点
 VOLUME ["/data", "/var/www"]
 
 # 设置子镜像的触发操作, 在其子镜像中执行
 ONBUILD ADD . /app/src
 ONBUILD RUN echo "on build executed" >> onbuild.txt
```

Best practise:
- Always update $PATH variable


## remove unused containers and images
```bash
docker ps -aqf status=exited | xargs docker rm
docker images -qf dangling=true | xargs docker rmi
```

## single Spring Boot jar, make use of docker cache  
Dockerfile: note that we use `java -cp` to run our app instead of `java -jar app.jar`
```bash
FROM java:8-jre
ADD app/lib/ /app/lib/
ADD app/ /app/
CMD ["java", "-cp", "/app/", "org.springframework.boot.loader.JarLauncher"]
EXPOSE 8080
```
Actually we can run the with the extracted jar files
```bash
$ rm -rf app/ && unzip -q app.jar -d app
$ docker build .
$ # ... here we can make use of the docker cache mechanism
```
But we should use **Spring Boot 1.3.0 or newer** for changes on the timestamps of the extracted jars by prior Spring Boot version.

## use systemctl inside a centos docker container
Start the container with `/usr/sbin/init` command. 
```bash
vagrant@vagrant-ubuntu-trusty-64:~$ docker run -d --privileged centos:7 /usr/sbin/init   
```
