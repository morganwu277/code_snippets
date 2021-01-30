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

