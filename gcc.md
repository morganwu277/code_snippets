## compile from source, -static linking, and more
```bash
# 1. compile libevent
./configure —prefix=$HOME/local
# 2. compile tmux
CFLAGS+=" -I$HOME/local/include"
PKG_CONFIG_PATH+="$PKG_CONFIG_PATH:$HOME/local/lib"
LDFLAGS+=" -static -L$HOME/local/lib"
./configure --prefix=$HOME/local
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
