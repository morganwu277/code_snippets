https://zhuanlan.zhihu.com/p/374586744

https://www.cnkirito.moe/cache-line/#%E4%BC%AA%E5%85%B1%E4%BA%AB

If we have two data using same cacheline and written under different threads, then we are having data contention here.
- Next is an example of CacheLine Padding. Normally a cacheline size is 64Bytes
- We use 8 long var to use as cacheline padding. so ensure our int a and int b can be put into different cores, instead of let them sharing the same core.
- Test result shows as, under GraalVM, with **cacheline padding can be ~2.5x - ~3x faster** than non-cacheline padding one.
- Test is executed under JUnit test and Graavl VM.

Summary: When do we need cacheline optimization?
1. under concurrency scenario
2. two piece of data are placed adjacent and are written by different threads
3. these two piece of data can be filled into one cacheline size block (64 Bytes, or eight long variables)

```java


    interface DataSetter {
        void setA(int a);
        void setB(int b);
    }
    @Setter
    class Data implements DataSetter{
        volatile int a;
        volatile int b;
    }
    @Setter
    class CacheLineData implements DataSetter{
        volatile int a;                     // 4 bytes content
        volatile long x1,x2,x3,x4,x5,x6,x7; // 56 bytes cacheline padding
        volatile int x8;                    // 4 bytes cacheline padding
        volatile int b;
    }

    private void microBenchmark(DataSetter dataSetter) throws InterruptedException {
        final Thread thread1 = new Thread(() -> {
            for (int i = 0; i < 10_000_000; i++) dataSetter.setA(i);
        });
        final Thread thread2 = new Thread(() -> {
            for (int i = 0; i < 10_000_000; i++) dataSetter.setB(i);
        });
        final long start = System.nanoTime();
        thread1.start();thread2.start();
        thread1.join();thread2.join();
        final long duration = System.nanoTime() - start;
        log.info("duration: {} ms", duration/1_000_000);
    }

    @RepeatedTest(200) // no cache line optimization, 2444ms on GraalVM
    public void testWithoutCacheLineOptmization() throws InterruptedException {
        microBenchmark(new Data());
    }

    @RepeatedTest(200) // with cacheline optimization, 936ms on GraalVM, ~2.5x faster
    public void testWithCacheLineOptmization() throws InterruptedException {
        microBenchmark(new CacheLineData());
    }
```
