## call CPP library from python
Mock.cpp, you need to expose by using `extern "C"`
```cpp
#include <string>
#include <stdio.h>
#include <stdlib.h>
using namespace std;

extern "C" {
    int addVertex(int type, string label);
    int addEdge(int vertex1, int vertex2, int directional, double speed, double length);
    void edgeEvent(int edge, int eventType);
    bool road(int *edges);
    string *trip(int fromVertex, int toVertex);
    int vertex(string point);
}

 int addVertex(int type, string label) {
    return 1;
}

 int addEdge(int vertex1, int vertex2, int directional, double speed, double length) {
    return 2;
}

 void edgeEvent(int edge, int eventType) {
    printf("Edge is %d , eventType is %d", edge, eventType);
}

 bool road(int *edges) {
    return true;
}

 string *trip(int fromVertex, int toVertex) {
    string *str =(string*)malloc(3* sizeof(string));
    return str;
}

 int vertex(string point) {
    return 3;
}
```
Build library by using `g++ Mock.cpp -fPIC -shared -o libMock.so`

test.py, you need load different library 
```py
#!/bin/python
from ctypes import cdll
stdc=cdll.LoadLibrary("libc.so.6")
stdcpp=cdll.LoadLibrary("libstdc++.so.6")
lib = cdll.LoadLibrary("./libMock.so")
vertextType = ["Point of interest", "intersection"]
a = lib.addVertex(1, "V1")
print(a)
```

## call C library from python
same as above, the only difference is that when building library, you need to use `gcc` instead of `g++`

