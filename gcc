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
