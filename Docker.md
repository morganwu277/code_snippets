## use golang docker image as build engine of go
use `golang:1.9` to build go program 
https://github.com/docker-library/docs/tree/master/golang#compile-your-app-inside-the-docker-container 
```bash
APPNAME=passport
BUILD_PATH=/usr/src/${APPNAME}
GOLANG_IMG="golang:1.9"

docker run --rm -v "$PWD":"${BUILD_PATH}" -w ${BUILD_PATH} -e GOPATH="${BUILD_PATH}" -e GOBIN="${BUILD_PATH}/bin" -e CGO_ENABLED=0 -e GOOS=linux -e GOARCH=amd64 golang:1.9 go get -v && go build -a -installsuffix cgo \
	-ldflags "-s -w" \
	-o "${BUILD_PATH}/${APPNAME}" .
```

## docker selinux security
So `capital Z` is more strict than `lowercase z`, and `capital Z` data can't be shared between containers. 

will execute `chcon -Rt svirt_sandbox_file_t /var/db` automatically: 
```
$ docker run -v /var/db:/var/db:z rhel7 /bin/sh
```
will execute `chcon -Rt svirt_sandbox_file_t -l s0:c1,c2 /var/db` automatically: 
```
$ docker run -v /var/db:/var/db:z rhel7 /bin/sh
```
https://www.projectatomic.io/blog/2015/06/using-volumes-with-docker-can-cause-problems-with-selinux/ 

## docker apparmor 
https://cloud.google.com/container-optimized-os/docs/how-to/secure-apparmor


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
## shrink docker VM of Mac OSX

1. Connect to the VM with screen ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/tty and then login as root by type `su && id`
2. execute `fstrim /var` and then reboot the docker VM. 

## source the script inside a Dockerfile
please use `/bin/bash -c`, or you will get error `sh: 1: source: not found`. 
```
RUN /bin/bash -c "source /usr/local/bin/virtualenvwrapper.sh"
```

## Docker Environment Probing
Via next command result, we can see `vxlan` support is missing. 
```bash
curl -sSL https://raw.githubusercontent.com/docker/docker/master/contrib/check-config.sh | bash
```

```bash
// more is here....... 
- Network Drivers:
  - "overlay":
    - CONFIG_VXLAN: missing
      Optional (for encrypted networks):
      - CONFIG_CRYPTO: enabled
      - CONFIG_CRYPTO_AEAD: enabled
      - CONFIG_CRYPTO_GCM: enabled
      - CONFIG_CRYPTO_SEQIV: enabled
      - CONFIG_CRYPTO_GHASH: enabled
      - CONFIG_XFRM: enabled
      - CONFIG_XFRM_USER: enabled
      - CONFIG_XFRM_ALGO: enabled
      - CONFIG_INET_ESP: enabled
      - CONFIG_INET_XFRM_MODE_TRANSPORT: enabled
// more is here....... 
```

## Clean Dangling Docker Volumes, since sometimes `docker rm -v` doesn't work
```bash
DOCKER="/usr/bin/docker"

LIST=""
count=0
batch_count=20
for i in `$DOCKER volume ls -qf dangling=true`;
do
  LIST="$LIST $i"
  count=$((count+1))
  if [[ "$count" == "$batch_count" ]]; then
    $DOCKER volume rm $LIST
    sleep 0.01
    LIST=""
    count=0
  fi
done
$DOCKER volume prune
```
Installed such script as crontab job `0 5 * * * /root/clean_docker_volume.sh`.
