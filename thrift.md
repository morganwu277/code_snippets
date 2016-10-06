
1. **Thrift Client is not thread-safe**. [http://www.360doc.com/content/16/0627/20/1317564_571207512.shtml]

2. **Thrift Servers comparation**. [https://github.com/m1ch1/mapkeeper/wiki/Thrift-Java-Servers-Compared] Here is all the source code: [https://github.com/m1ch1/mapkeeper/blob/master/stubjava/StubServer.java]
  - use TThreadedSelectorServer first. 
  - if you know how many clients will be, then use the TThreadPoolServer 
  
3. **The Missing Thrift Specification**
 https://erikvanoosten.github.io/thrift-missing-specification/
