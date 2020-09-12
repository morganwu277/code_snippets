
# RPM query commands
Here are some query command examples
```bash
# will list all files that to be installed from next rpm
rpm -qlp gRPC-1.31.0-1.el7.x86_64.rpm
# list all required packages for a package that already installed
rpm -qR gRPC
# will list all files in a package that already installed
rpm -ql gRPC
# list header information defined in the package's SPEC file
rpm -qi gRPC
```
Here is a more thorough query command list:
```bash
# from http://cn.linux.vbird.org/linux_basic/0520rpm_and_srpm.php#rpmmanager_query
[root@www ~]# rpm -qa                              <==已安装软件
[root@www ~]# rpm -q[licdR] 已安装的软件名称          <==已安装软件
[root@www ~]# rpm -qf 存在於系统上面的某个档名          <==已安装软件
[root@www ~]# rpm -qp[licdR] 未安装的某个文件名称      <==查阅RPM文件
选项与参数：
查询已安装软件的资讯：
-q  ：仅查询，后面接的软件名称是否有安装；
-qa ：列出所有的，已经安装在本机 Linux 系统上面的所有软件名称；
-qi ：列出该软件的详细资讯 (information)，包含开发商、版本与说明等；
-ql ：列出该软件所有的文件与目录所在完整档名 (list)；
-qc ：列出该软件的所有配置档 (找出在 /etc/ 底下的档名而已)
-qd ：列出该软件的所有说明档 (找出与 man 有关的文件而已)
-qR ：列出与该软件有关的相依软件所含的文件 (Required 的意思)
-qf ：由后面接的文件名称，找出该文件属於哪一个已安装的软件；
查询某个 RPM 文件内含有的资讯：
-qp[icdlR]：注意 -qp 后面接的所有参数以上面的说明一致。但用途仅在於找出
	    某个 RPM 文件内的资讯，而非已安装的软件资讯！注意！
```

# RPM SPEC Example
First we need to ensure SOURCES and SPECS are created (at least to have SPECS files)
```bash
mkdir ~/rpmbuild/{SOURCES,SPECS}
cd ~/rpmbuild
# wirte SPEC file
vi SPECS/grpc.spec
# build to produce binary RPM ONLY, will create BUILD,BUILDROOT,SRPMS,RPMS directories
rpmbuild -bb SPECS/grpc.spec
# build to produce binary RPM and src RPM
rpmbuild -ba SPECS/grpc.spec
```

Take an example to build grpc RPM. About how to build from scratch, please follow guide here: https://grpc.io/docs/languages/cpp/quickstart/

```
Summary:        gRPC - Google's high performance general RPC framework
Name:           gRPC
Version:        1.31.0
Release:        1.%{?dist}
License:        BSD
Group:          Development/Libraries
URL:            https://github.com/grpc/grpc/
BuildRequires:  automake autoconf libtool pkgconfig zlib-devel curl cmake3

%description
gRPC can use protocol buffers as both its Interface Definition
Language (IDL) and as its underlying message interchange format.

In gRPC, a client application can directly call a method on a server
application on a different machine as if it were a local object,
making it easier for you to create distributed applications and
services. As in many RPC systems, gRPC is based around the idea
of defining a service, specifying the methods that can be called
remotely with their parameters and return types. On the server side,
the server implements this interface and runs a gRPC server to
handle client calls. On the client side, the client has a stub
(referred to as just a client in some languages) that provides
the same methods as the server.

Summary: Protocol Buffers compiler
Group: Development/Libraries

%prep
rm -rf grpc || :
git clone --recurse-submodules -b v%{version} --depth 1 https://github.com/grpc/grpc

%build
cd grpc
rm -rf cmake/build || :
mkdir -p cmake/build
cd cmake/build
# you need to install protobuf, ssl, zlib first checkout https://github.com/morganwu277/code_snippets/blob/master/grpc-build.sh
# see how to install them, but probably you already have ssl and zlib package, cause they are so widely being used.
cmake3 -DCMAKE_BUILD_TYPE=Release \
  -DgRPC_INSTALL=ON \
  -DgRPC_BUILD_TESTS=OFF \
  -DgRPC_CARES_PROVIDER=module \ # using module
  -DgRPC_ABSL_PROVIDER=module \  # using module
  -DgRPC_PROTOBUF_PROVIDER=package \ # using package, since needs to be independent
  -DgRPC_SSL_PROVIDER=package \  # using package, since needs to be independent
  -DgRPC_ZLIB_PROVIDER=package \  # using package, since needs to be independent
  -DCMAKE_INSTALL_PREFIX=/usr \ # install under /usr
  ../..
make -j

%install
cd grpc/cmake/build
rm -rf ${buildroot}
make -j install DESTDIR=%{buildroot}

%post -p /sbin/ldconfig
%postun -p /sbin/ldconfig

%files
%defattr(-, root, root, -)
# better to add *, or will conflict with existing directory
/usr/bin/*
/usr/include/*
/usr/lib/*
/usr/lib64/*
/usr/share/*

%changelog
* Tue Aug 18 2020 Morgan Wu <xue777hua@gmail.com> 1.31.0
- initial spec
```

# Post notes

After you get the above gRPC RPM, you probably install by using `yum install -y gRPC*.rpm`, and then you would like to use [Makefile](https://github.com/grpc/grpc/blob/master/examples/cpp/helloworld/Makefile) here, howevever you could get build error say can't find package from pkg-config search path.

So now you need to update `PKG_CONFIG_PATH` environment values, so `pkg-config --cflags protobuf grpc` can get a correct result.
```bash
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig
cd to examples/helloworld
# now you are happy to use make
make -j
```

Since we install under `/usr` directory, and by default, they should be included into `$LD_LIBRARY_PATH`, but if `$LD_LIBRARY_PATH` is overwritten by some application, you need to include these two directory again by simple export.
```bash
export LD_LIBRARY_PATH=/usr/lib:/usr/lib64:$LD_LIBRARY_PATH
```
