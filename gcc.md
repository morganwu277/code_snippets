## compile from source, -static linking, and more
```bash
# 1. compile libevent
# you may need 2.1.12-stable for centos7, or other version, check with libevent
# https://github.com/libevent/libevent/releases/tag/release-2.1.12-stable
# 方法是 查询package 名对应的 el7 的包的版本号 然后去找对应的github的版本进行编译
./configure —prefix=$HOME/local
# 2. compile tmux
export CFLAGS+=" -I$HOME/local/include"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$HOME/local/lib/pkgconfig"
export LDFLAGS+=" -static -L$HOME/local/lib"
./configure --prefix=$HOME/local 
# 3. or compile tmux by using --enable-static
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$HOME/local/lib/pkgconfig"
./configure --prefix=$HOME/local --enable-static
```

## Makefile Sample

```bash
CXX = g++
CXXFLAGS = -g -MMD

EXEC = wlp4gen
OBJECTS = wlp4gen.o typechecker.o codegen.o symboltable.o
DEPENDS = ${OBJECTS:.o=.d}

${EXEC}: ${OBJECTS}
	${CXX} ${CXXFLAGS} ${OBJECTS} -o ${EXEC}

-include ${DEPENDS}

.PHONY: clean

clean:
	rm ${OBJECTS} ${DEPENDS} ${EXEC} 2> /dev/null

```
