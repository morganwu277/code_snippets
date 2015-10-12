This is a sample Dockerfile containing all the useful points how to build a image
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
 
 # 添加文件，如果ADD压缩文件，会先解压缩，如果是挽留过文件，会先下载
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
