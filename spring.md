# Spring AOP Example
https://www.baeldung.com/spring-aop-annotation

elements:
0. dependency: `org.springframework.boot:spring-boot-starter-aop`
1. `Annotation`
2. `@Aspect` class definiton, with `@Component` modifer
3. implement pointcut and advice
```java
@Around("@annotation(LogExecutionTime)")
public Object logExecutionTime(ProceedingJoinPoint joinPoint) throws Throwable {
    return joinPoint.proceed();
}
```
4. `@EnableAspectJAutoProxy` anywhere, even in the Aspect class itself.
5. Finally, use customized annotation anywhere.

Example:
```java
@Component
@Aspect
@EnableAspectJAutoProxy(proxyTargetClass = true, exposeProxy = true)
@Slf4j
public class TracingAspect {
    @Autowired
    Tracer tracer;

    @Around("within(org.example..*) && @annotation(org.example.tracing.Traced)")
    public Object aroundAdvice(final ProceedingJoinPoint jp) throws Throwable {
        String class_name = jp.getTarget().getClass().getName();
        String method_name = jp.getSignature().getName();
        log.info("................................................TracingAspect....{}.............................................", class_name + "." + method_name);
        Span span = tracer.buildSpan(class_name + "." + method_name).withTag("class", class_name)
                .withTag("method", method_name).start();
        Object result = jp.proceed();
        span.finish();
        return result;
    }
}
```
