Spring实战.md 第4版 第5版

---

# 1. Spring 基础

## 1.1 基础介绍

1. Spring 4个基本策略
- 通过POJO的轻量级和最小侵入性编程
- 通过依赖注入和面向接口编程实现松耦合
- 给予切面和惯例进行声明式编程
- 通过切面和模板减少样板式代码􏰹􏲸􏱅􏲕􏰸􏱄􏱃􏲕􏲆􏱊 (boilerplate code)
Spring所做的任何事情，都可以追溯为上述的一条或多条策略。


2. 依赖注入
关键点是：面向接口编程，先写抽象(接口)，然后写实现，然后让注入自动发生。

注入方式：
- 属性注入(Setter 方法注入)
- 构造器注入（Constructor的参数注入）
- 工厂方法注入
  - 静态工厂
  - 实例工厂（非静态工厂）
- 注解注入（其实就是上述的三种方法，用注解来实现）
  - 相关注解: 
    - Autowired: 自动注入，从spring上下文找到合适的bean注入
    - Resource: 指定名称注入
    - Qualifier: 和 Autowired 配合使用，指定 bean 的名称
    - Component: 泛指，标记类是组件， scan 的时候会标记这些类要生成 bean
    - Service Controller Repository: 不是泛指，详细制定某种类

基于 XML 的配置
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.springframework.org/schema/beans 
      http://www.springframework.org/schema/beans/spring-beans.xsd">
  <!-- 构造器注入 -->
  <bean id="knight" class="sia.knights.BraveKnight">
    <constructor-arg ref="quest" />
  </bean>

  <!-- 构造器注入 EL表达式 -->
  <bean id="quest" class="sia.knights.SlayDragonQuest">
    <constructor-arg value="#{T(System).out}" />
  </bean>

</beans>
```
基于 Java 的配置
```java
@Configuration
public class KnightConfig {

  @Bean
  public Knight knight() {
    return new BraveKnight(quest());
  }
  
  @Bean
  public Quest quest() {
    return new SlayDragonQuest(System.out);
  }

}
```

3. 基于切面进行声明式编程 AOP Aspect-Oriented Programming
AOP: 促使软件系统实现关注点分离的一项技术。
组件分类：
- 核心业务组件：专注完成业务逻辑。
- 核心系统组件: 日志、声明式事务、安全。这些系统服务，常称为，横切关注点 (cross-cutting concerns)，因为会跨越系统多个组件。
AOP 可以使得这些系统组件模块化，并且以“声明式”的方式应用到他们所需要的业务组件中去，而业务组件可以实现更好的内聚性，无需了解系统组件带来的复杂性，保持 POJO 的简单性。
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:aop="http://www.springframework.org/schema/aop"
  xsi:schemaLocation="http://www.springframework.org/schema/aop 
      http://www.springframework.org/schema/aop/spring-aop.xsd
    http://www.springframework.org/schema/beans 
      http://www.springframework.org/schema/beans/spring-beans.xsd">

  <bean id="knight" class="sia.knights.BraveKnight">
    <constructor-arg ref="quest" />
  </bean>

  <bean id="quest" class="sia.knights.SlayDragonQuest">
    <constructor-arg value="#{T(System).out}" />
  </bean>

  <!-- 声明 Minstrel Bean -->
  <bean id="minstrel" class="sia.knights.Minstrel">
    <constructor-arg value="#{T(System).out}" />
  </bean>

  <aop:config>
    <!-- 0. 引用 minstrel bean -->
    <aop:aspect ref="minstrel">
      <!-- 1. 定义切点 AspectJ 的切点表达式语言-->
      <aop:pointcut id="embark" expression="execution(* *.embarkOnQuest(..))"/>
      <!-- 2. 前置通知 before advice -->
      <aop:before pointcut-ref="embark" method="singBeforeQuest"/>
      <!-- 3. 后置通知 after advice -->
      <aop:after pointcut-ref="embark"  method="singAfterQuest"/>
    </aop:aspect>
  </aop:config>
</beans>
```
AspectJ 表达式语言
`execution(* *.embarkOnQuest(..))`:
- `execution`: 匹配方法执行的切入点，后面的方法一般是属于一个`接口`的方法
- `*`: 返回值，表示any类型
- `*.embarkOnQuest`: 表示包名路径，用 * 进行通配，一个或多个都OK
- `(..)`:方法调用参数，多个any类型参数

格式：
https://blog.csdn.net/buzhimingyue/article/details/106071059
```
// 带?的表示可选
execution(modifiers-pattern? ret-type-pattern declaring-type-pattern?name-pattern(param-pattern) throws-pattern?)
```
- 可选）方法修饰符匹配 modifier-pattern
- 方法返回值匹配 ret-type-pattern
- （可选）类路径匹配 declaring-type-pattern
- 方法名和参数匹配 name-pattern(param-pattern)
- （可选）异常类型匹配 throws-pattern
例:
```java
// 匹配所有方法
execution(* *(..))  
// 匹配 com.bytebeats.spring4.aop.xml.service.UserService 中所有的公有方法
execution(public * com.bytebeats.spring4.aop.xml.service.UserService.*(..))  
// 匹配 com.bytebeats.spring4.aop.xml.service 包及其子包下的所有方法
execution(* com.bytebeats.spring4.aop.xml.service..*.*(..))  
// 匹配 IndexDao 所有第一个入参为String的方法(可以有一个或多个入参，但第一个必须是String)
execution(* com.jiyongjun.spring.core.aop.aspectj.pointcut.IndexDao.*(String, ..))
```

上面是使用 XML 进行声明式定义切面的方法，下面是 Java 注解的方法
```java
// 1. 我们写一个借口 perform() 方法
package concert;
public interface Performance {
  public void perform();
}

// 2. 定义切面类
// 表示这个 POJO 类是一个切面
@Aspect
public class Audience {
  // 定义命名的切点，切点 ID/名称
  // 通过 @Pointcut 注解，我们实际上扩展了切点表达式语言，这样就可以在任意的切点表达式使用 performance() 方法
  // performance()  方法的内容并不重要，只是作为一个标识符，用于给 @Pointcut 注解使用和后期引用
  @Pointcut("execution(** concert.Performance.perform(..))")
  public void performance() {}
  
  // 表演之前
  @Before("performance()")
  public void silienceCellPhones() {
    System.out.println("Silencing cell phones");
  }
  @Before("performance()")
  public void takeSeats() {
    System.out.println("Taking seats");
  }

  // 表演之后
  @AfterReturning("performance()")
  public void applause() {
    System.out.println("CLAP CLAP CLAP");
  }

  // 表演失败之后
  @AfterThrowing("performance()")
  public void demandRefund() {
    System.out.println("Demanding a refund");
  }
}
 
// 3. 装配和使用切面类
package concert;
@Configuration
// 启用 AspectJ 自动代理，从而把上述的 @Aspect 注解和 @Pointcut 和 @Before 等注解进行解析
// 从而将 Audience 转换为切面的代理
@EnableAspectJAutoProxy
@ComponentScan
public class ConcertConfig {
  @Bean
  public Audience audience() {
    return new Audience();
  }
}
```

下面是一个带参数的 Advice 例子
```java
package soundsystem;
@Aspect
public class TrackCounter {
  private Map<Integer, Integer> trackCounts = new HashMap<Integer, Integer>();
  // 通知 playTrack 方法
  // 定义 Pointcut 标识符为 "trackPalyed(trackerNumber)"
  @Pointcut("execution(* soundsystem.CompactDisc.playTrack(int)) "+
             "&& args(trackNumber)" )
  public void trackPalyed(int trackNumber) {}

  @Before("trackPalyed(trackerNumber)")
  public void countTrack(int trackNumber) {
    int currentCount = getPlayCount(trackNumber);
    trackCounts.put(trackNumber, currentCount);
  }
  public int getPlayCount(int trackNumber) {
    // ...
  }
}
```
https://www.javainuse.com/spring/spring-boot-aop
这里有一个 Spring-Boot 的 AOP 的例子



4. 使用模板消除样板式代码
JDBC、JNDI、RESET服务等都会容易产生样板式代码。用模板来消除样板式代码的重复性。比如 Spring 的 JdbcTemplate 操作数据库。 
```java
// 里面使用了 Lambda 的方法，完整的 实际上是定义一个 RowMapper<Employee> 的匿名类，实现 mapRow(ResultSet rs, int rowNum) 方法
jdbcTemplate.queryForObject("SELECT id,firstname,lastname,salary from employee where id=?",
  (rs, rowNum) -> new Employee(rs.getLong("id"),
                               rs.getString("firstname"),
                               rs.getString("lastname"),
                               rs.getBigDecimal("salary")), 
  // 指定查询参数
  id);
```

## 1.2 容纳你的 Bean
1. 使用应用上下文 ApplicationContext 
常用的几个 ApplicationContext: 
- `AnnotationConfigApplicationContext`: 从一个或多个基于Java的配置类加载Spring应用上下文
- `AnnotationConfigWebApplicationContext`: 从一个或多个基于Java的配置类中健在SpringWeb应用上下文
- `ClassPathXmlApplicationContext`: 从classpath下的一个或多个XML配置文件中加载上下文定义
- `FileSystemXmlApplicationContext`: 从文件系统的一个或多个XML配置文件中加载上下文定义
- `XmlWebApplicationContext`: 从Web应用下的一个或多个XML配置文件中加载上下文定义

NOTE: 关于 classpath 加载路径顺序。
1. 如果有多个重复的，则第一个加载的为有效加载
2. 具体加载顺序的策略不一定，由classloader指定。spring-boot可能是按照字母顺序加载jar包。
3. 最好是打印出classpath，这样就容易分辨出加载顺序。程序开始的地方，打印出这个就可以`System.getProperty("java.class.path")` 这个效果和 `jinfo <pid>` 结果一样，但是对于 spring boot 这种 fat jar，则打印出来只有一个单独的jar，并不好用。
4. 对于 spring boot 则可以使用 `-verbose:class` 参数来打印出加载顺序
5. 更多，也可以用 https://github.com/alibaba/arthas 的 `classloader -a` 来查看 或者 
`sc -d org.springframework.web.context.support.XmlWebApplicationContext` 只查看某个单独的 class的加载情况 `Search classes loaded by JVM`
```java
ApplicationContext context = new FileSystemXmlApplicationContext("C:/knight.xml");
ApplicationContext context = new ClassPathXmlApplicationContext("knight.xml");
ApplicationContext context = new AnnotationConfigApplicationContext(com.springinaction.knights.config.KnightConfig.class);
```

2. bean 生命周期
```

-> 实例化
-> 填充属性
-> 调用 BeanNameAware.setBeanName(): 需要 Bean 实现 BeanNameAware 接口
-> 调用 BeanFactoryAware.setBeanFactory(): 需要 Bean 实现 BeanFactoryAware 接口
-> 调用 ApplicationContextAware.setApplicationContext(): 需要 Bean 实现 ApplicationContextAware 接口
-> 调用 BeanPostProcessor 的 postProcessBeforeInitialization(): 需要 Bean 实现 BeanPostProcessor 接口
  -> @Value 是在 BeanPostProcessor 处理的 
  -> 一般用了 @Value 需要注意 顺序，特别是用 @DependsOn 
-> 调用 InitializingBean 的 afterPropertiesSet(): 需要 Bean 实现 InitializingBean 接口。
-> 调用 自定义的初始化方法: 如果 bean 使用 init-method 声明了初始化，也会被调用
-> 调用 BeanPostProcessor 的 postProcessAfterInitialization(): 需要 Bean 实现 BeanPostProcessor 接口
-> Bean可以使用了!
----
-> 容器关闭
-> 调用 DisposableBean 的 destroy(): 需要 Bean 实现 DisposableBean 接口
-> 调用 自定义的销毁方法: 如果 bean 使用 destroy-method 声明了销毁，也会被调用
-> Bean正式结束！
```

3. Spring 模块
核心模块划分为6个主要的大功能：
- 数据库访问与集成: JDBC、Transaction、ORM、OXM、Messaging、JMS
- Web与远程调用: Web、WebMVC、WebMVC Portlet、WebSocket
- 面向切面编程: AOP、Aspects
- Instrumentation: Instrument、Instrument Tomcat
- Spring核心容器: Beans、Core、Context、Expression、Context Support
- 测试: Test

Spring 非核心模块
- Spring Web Flow: 基于流程的会话式 Web 应用（购物车、向导）
- Spring Web Service
- Spring Security
- Spring Integration
- Spring Batch
- Spring Data
- Spring Social
- Spring Mobile: 是 SpringMVC 的新扩展
- Spring for Android: 可以搭配 Spring Social 和 Spring Mobile 使用
- Spring Boot: 简化 Spring 本身自己的开发


## 1.3 装配 Bean
1. 装配 Bean 的三种方式
- XML 显示装配
- Java 显示装配
- 隐式的 bean 发现机制和自动装配
  - 组件扫描: component scanning
  - 自动装配: autowiring

2. 组件扫描+自动装配
- `@Configuration`: 将一个 Java 类声明为配置类
- `@Configuration`+`@ComponentScan`+`@Component`: 默认扫描与 Config 类相同的 package，只要有 `@Component` 注解的 class 都为其创建一个 Bean 
  - 等效于 XML 配置的 `<context:component-scan>`
  - `@ComponentScan(basePackages="")`: 扫描指定 package 的所有类。默认则扫描类当前所属的 package 和子 package。
  - `@ComponentScan(basePackageClasses=XXX.class)`: 扫描该 class 所属的 package 的所有类
- `@Autowired`: 可以用来修饰任何方法，Spring 会尝试对参数进行自动装配

```java
// 在测试开始的时候自动创建 Spring 的应用上下文
@RunWith(SpringJUnit4ClassRunner.class)
// 需要在 CDPlayerConfig 中加载配置
// 因为 CDPlayerConfig 包含了 @ComponentScan 所以最终应用上下文应该包含 CompactDiscbean
@ContextConfiguration(classes=CDPlayerConfig.class)
public class CDPlayerTest {
  @Autowired
  private CompactDisc cd;
  
  @Test
  public void cdShouldNotBeNull() {
    assertNotNull(cd);
  }
}
```

3. 显示 JavaConfig 配置 Bean
需要将第三方库的组件装配到应用中，则需要用 @Bean 的方式，无法使用 @Component 的方式自动装配，除非这些组件自己就已经写过了 @Component 那么可以用 @ComponentScan 来自动装配。
- `@Bean`: 默认情况下，Bean 的 ID 和被注解的方法名一样，如果需要修改则用 `@Bean(name="xxxBean")`

4. 通过 XML 装配 Bean
- `<bean id="" class="">` 
- `<constructor-arg ref="">` 
- `<c:cd-ref="compactDisc"`: c-命名空间前缀 cd-构造器参数名 ref-注入bean引用 compactDisc-要注入的 bean ID
- `<c:_0-ref="compactDisc"`: 参数在构造器方法的位置来进行注入
- `<c:_1="The Beatles"`: 直接字面量注入到第 1 个参数
- `<c:_artist="The Beatles"`: 直接字面量注入到 artist 变量
- `<set>` / `<list>`: 装配 Set、List、或者数组，前者去重，后者不去重并且保证顺序

5. 不管使用 JavaConfig 还是 XML 配置，我们通常都会创建一个根配置 Root Configuration

- 会将多个 Config 类进行组装 `@Import`显示装配
- 也可以 `@ComponentScan`进行隐式装配

## 1.4 高级装配
1. `@Profile("dev")` 管理环境。
  - 用 `-Dspring.profiles.active` 和 `-Dspring.profiles.default` 来进行激活
  - 在集成测试类，也可以用 `@ActiveProfiles` 来进行激活

2. `@Conditional()` 条件化创建 Bean。例如：
- 希望 Bean 只在类路径下包含特定的 library 才创建
- 希望 Bean 只在特定的另一个 Bean 声明了之后才创建
- 只有在特定的环境变量设置了之后才创建

```java
@Configuration
public class MagicConfig {
  @Bean
  @Conditional(MagicExistsCondition.class)
  public MagicBean magicBean() {
    return new MagicBean();
  }
}
// 只在环境变量中包含 magic 属性之后才创建 Bean
public class MagicExistsCondition implements Condition {
  @Override
  public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
    Environment env = context.getEnvironment();
    return env.containsProperty("magic");
  }
}
```

`@Profile` 使用了 `@Conditional(ProfileCondition.class)` 来实现。而 `ProfileCondition` 则使用 `metadata.getAllAnnotationAttributes(Profile.class.getName())` 来查找到 `@Profile` 注解的所有属性
```java
class ProfileCondition implements Condition {
  @Override
  public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
    MultiValueMap<String, Object> attrs = metadata.getAllAnnotationAttributes(Profile.class.getName());
    if (attrs != null) {
      for (Object value : attrs.get("value")) {
        if (context.getEnvironment().acceptsProfiles(Profiles.of((String[]) value))) {
          return true;
        }
      }
      return false;
    }
    return true;
  }
}
```

3. `@Qualifier("iceCream")`限定注入的 bean 的 ID。
```java
@Autowired
// 因为系统里面 有三种 Dessert，而这里指定用 iceCream
@Qualifier("iceCream")
public void setDessert(Dessert dessert) {
  this.dessert = dessert;
}
```

4. Bean 的作用域
- 默认情况下 `Singleton` 形式: 无状态 bean
- 有状态 Bean，他们是 mutable 的，所以重用是不安全的。要用 `@Scope` 来进行注解
  - `Prototype`: 每次注入都创建一个新的 instance
  - `Session`: Web 应用中，为每个 session 创建一个 instance
  - `Request`: Web 应用中，为每个请求创建一个 instance

```java
@Component
@Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
public class Notepad {
  // the details of this class are inconsequential to this example
}
```

下面的例子中：
- `StoreService` 是一个单例 bean，在应用上下文加载的时候创建。
- `StoreService` 会注入一个到 `ShoppingCart` 的代理，该代理和 `ShoppingCart` 接口一样。
- 当 `StoreService` 调用 `ShoppingCart` 的方法的时候，则对其进行懒解析，并将调用委托给会话作用域的真正的`ShoppingCart`Bean。
```java
@Component
public class StoreService {
  @Autowired
  public void setShoppingCart(ShoppingCart shoppingCart) {
    this.shoppingCart = shoppingCart;
  }
}

@Bean
@Scope(value=WebApplication.SCOPE_SESSION, 
// 表明这个代理要实现 ShppingCart 接口，并将调用委托给实现 Bean
  proxyMode=ScopedProxyMode.INTERFACES)
public ShppingCart cart() {
  // ...
}
```
总结：通过代理委托机制，延迟注入请求和会话作用域 bean，从而实现单例 Bean 中可以引用会话和请求作用域 bean

5. 注入 PropertyPlaceholder 的 Value
```java
// 1. 方法1 用PropertySource 注入到 Environment 里去
@Configuration
@PropertySource("classpath:/com/soundsystem/app.properties")
// app.properties 文件内容为:
/*
dist.title=Sgt. Peppers Lonely Hearts Club Band
disc.artist=The Beatles
*/
public class ExpressionConfig {
  @Autowired
  private Environment env;
  @Bean
  public BlankDisk disk() {
    return new BlankDisk(env.getProperty("disc.title"), env.getProperty("dist.artist"));
  }
}

// 2. 方法2 用占位符来获取Value，但需要配置一个 PropertySourcesPlaceholderConfigurer
@Bean
public static PropertySourcesPlaceholderConfigurer placeholderConfigurer() {
  return new PropertySourcesPlaceholderConfigurer();
}
//  然后在代码中可以用 ${xxx.xxx} 来获取 Value
public BlankDisk(@Value("${disc.title}") String title, @Value("${disc.artist}") String artist) {
  this.title = title;
  this.artist = artist;
}
```

6. 使用 SpEL 进行装配，运行时计算得到结果进行装配
https://juejin.cn/post/6844903679984664584
特性:
- 使用 bean 的 ID 引用 bean
- 调用方法和访问对象的属性
- 对值进行算数、关系和逻辑运算
- 正则表达式匹配
- 集合操作

7. 异常处理
https://zhuanlan.zhihu.com/p/67234342
- `checked` 编译器强制检查的异常，一般为应用环境错误（外部错误），如：文件找不到
- `unchecked` 编译器不检查的异常，一般为应用逻辑本身的错误，程序员的错。
- `RuntimeException` 都是 `unchecked` 异常。编译器不会检测，没有 try-catch，方法签名中也没有 throws 关键字声明，如果出现了 RuntimeException，一定是程序员(应用程序的)错。一般异常如果没有 try-catch，方法签名也没用 throws 关键字声明可能抛出的异常，则无法编译通过，这类异常通常为应用环境的错误，即 `外部错误`，而非应用程序（程序员）的本身错误。如：文件找不到。
  - 常见 RuntimeException
    - ClassCastException
    - IndexOutBoundsException
    - NullPointerException
    - ArrayStoreException
    - BufferOverflowException
- `Error` 是 JVM 的错误，无法 recover 的，应用程序应该崩溃，比如：OOM，StackOverflow
- `Exception` 是在应用程序中可以捕获并进行处理和 recover 的

8. 元注解 Annotation
```java
// 表示这个注解目标只能修饰 TYPE 类型和方法 METHOD
@Target({ElementType.TYPE, ElementType.METHOD})
// 表示这个注解在 JVM 会被保留 RetentionPolicy 还有额外两种分别意思是
//  1. SOURCE: 表示只在源码中保留，编译成 class 字节码则删除
//  2. CLASS: 表示只在 CLASS 中保留，运行期 VM 则删除 
//  3. RUNTIME: 表示在 VM 运行期也保留
@Retention(RetentionPolicy.RUNTIME)
//  表示用反射的方式查找被这个注解进行修饰的对象的时候，可以递归向父类进行查找，直到找到为止，
// 否则报错：找不到该 annotation，简单来说：就是注解可继承
@Inherited
// 注解会被 javadoc 等工具进行文档化
@Documented
public @interface Cacheable {
  // ...
}
```

## 1.5 面向切面编程
一句话: 非侵入式的方式对 Bean 进行扩展。
1. 概念
- 通知 advice: 切面的工作被称之为通知，有 5 种类型的通知
  - Before: 目标方法执行前调用
  - After: 目标方法执行后调用
    - After-returning: 目标方法 `成功` 后调用
    - After-throwing: 目标方法 `异常` 后调用
  - Around: 方法执行的前后，自行定义行为
- 切点 pointcut 横切关注点
- 横切关注点可以被模块化为特殊的类，这些类称为切面（Aspect）。切面是通知和切点的结合。通知和切点定义了切面的全部内容: 是什么，在何时、何处完成其功能。
- 织入 Weaving: 把切面应用到目标对象并创建新的代理对象的过程。Weave 的时机有：
  - 编译期间: 切面在目标类编译时被织入，这需要特殊的编译器。AspectJ 的织入编译器就是这种方式织入的。
  - 类加载期间: 切面在目标类加载到 JVM 时被织入。需要特殊的类加载器 ClassLoader，可以在目标类被引入应用之前增强该目标类的字节码。AspectJ 5的 load-time weaving LTW 就支持这种方式
  - 运行期: 切面在应用运行的某个时刻被织入。一般情况下，AOP 容器会为目标对象动态创建一个代理对象。Spring AOP 就是这种方式织入切面的。
```java
// 其中 Security 和 Transaction 类为 Aspect
// A、B、C、D、E、F 为横切点 (point-cut) 或者说横切关注点 cross-cutting concerns
              Security           Transaction
                 | |                 | |
=CourseService===|A|=================|D|===========
                 | |                 | |
=CourseService===|B|=================|E|===========
                 | |                 | |
=CourseService===|C|=================|F|===========
                \| |/               \| |/
                 \ /                 \ /
                  .                   . 
```

通过切面，不仅可以分离关注点，更可以在被引入接口的方法调用的时候，用代理把方法调用委托给新接口的某个其他对象。实际上，在此刻，一个 bean 的实现甚至被拆分到了多个类中。
```java
package concert;
// Encore 的意思是演唱会结束后的应观众要求进行返场表演
public interface Encoreable {
  void performance();
}
@Aspect
public class EncoreableIntroducer {
  // @DeclareParents 注解所标注的静态属性指明了要引入的接口。这里我们引入 Encoreable 接口
  @DeclareParents(
      // 指定哪种类型的 bean 要引入该接口。这是实现了 concert.Performance 接口的类型。后面的+表示是 Performance 的所有子类型，而非 Performance 本身
      value="concert.Performance+",
      // 制定了为引入功能提供实现的类
      defaultImpl=DefaultEncoreable.class
  )
  public static Encoreable encoreable;
}
```

但是面向注解的切面声明编程有一个明显的劣势，你必须能够为通知类添加注解。为了做到这一点，必须有源码。
所以：
- 要么是通知类已经有了 `@Aspect` 注解，即，本身就支持 AOP
- 要么我们自己用基于 XML 的配置来声明切面，用 `<aop:xxx>` 的命名空间元素来实现


# 2. Spring 杂谈
## 1. SpringMVC 简介
1. 定义 Controller
```java
  // 一般用 @RequestParam 来捕获参数
  @RequestMapping(method=RequestMethod.GET)
  public List<Spittle> spittles(
      @RequestParam(value="max", defaultValue=MAX_LONG_AS_STRING) long max,
      @RequestParam(value="count", defaultValue="20") int count) {
    return spittleRepository.findSpittles(max, count);
  }
  // {username} 是一个占位符，后面用 @PathVariable 来进行捕获
  @RequestMapping(value="/{username}", method=GET)
  public String showSpitterProfile(@PathVariable String username, Model model) {
    Spitter spitter = spitterRepository.findByUsername(username);
    model.addAttribute(spitter);
    return "profile";
  }
```
2. 创建 RESTAPI (第四版 16 章)
关于 REST的首字母拆分，是什么？
- 表述性 Representational: REST 资源实际上可以用各种形式进行表述，包括 XML、JSON、HTML 等
- 状态 State: 当使用 REST 的时候，我们更关注资源的状态，而非对资源采取的行为
- 转移 Transfer: REST 涉及到转移资源数据，以某种表述性形式，从一个应用转移到另一个应用

更简洁的说：
- REST 就是将资源以最适合客户端或服务端的形式从服务端转移到客户端（或者反过来）
- 在 REST 中，资源通过 URL 进行识别和定位
- REST 中，关注的核心是实物（资源），而不是行为，请更强调 REST 面向资源的本质
- REST 中的行为通过 HTTP 方法来定义，也就是 GET、POST、PUT、DELETE、PATCH 构成 REST 的动作




## 2. Spring Security 简介
1. 基于 2 个原理进行保护
- 使用 Servlet 规范中的 Filter 保护 Web 请求并且限制 URL 级别的访问
- 使用 Spring AOP保护方法级别的调用——借助于对象代理和使用通知，能够确保只有具备适当权限的用户才能访问安全保护的方法

2. URL级别防护
```java
@Configuration
@EnableWebMvcSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {
  
  @Override
  protected void configure(HttpSecurity http) throws Exception {
    http
      .formLogin()
        .loginPage("/login")
      .and()
        .logout()
          .logoutSuccessUrl("/")
      .and()
      .rememberMe()
        .tokenRepository(new InMemoryTokenRepositoryImpl())
        .tokenValiditySeconds(2419200)
        .key("spittrKey")
      .and()
       .httpBasic()
         .realmName("Spittr")
      .and()
      .authorizeRequests()
        .antMatchers("/").authenticated()
        .antMatchers("/spitter/me").authenticated()
        .antMatchers(HttpMethod.POST, "/spittles").authenticated()
        .anyRequest().permitAll();
  }
  
  @Override
  protected void configure(AuthenticationManagerBuilder auth) throws Exception {
    auth
      .inMemoryAuthentication()
        .withUser("user").password("password").roles("USER");
  }
}
```

3. 基于 Spring AOP 对方法级别进行保护
https://www.baeldung.com/spring-security-method-security
（第四版的 14 章）
Spring Security 提供了 3 种不同的安全注解:
- Spring Security 自带的 @Secured 注解
- JSR-250 的 @RolesAllowed 注解
- 表达式驱动的注解，包括 @PreAuthorize、 @PostAuthorize、 @PreFilter 和 @PostFilter



## 3. 缓存数据
```java
// 1. 启用注解驱动缓存的支持
@Configuration
// 启用缓存，工作方式：创建一个切面，并触发 Spring 的 @Cacheable/@CacheEvict 等缓存注解的切点
@EnableCaching
public class CachingConfig {
  @Bean
  public CacheManager cacheManager() {
    return new ConcurrentMapCacheManager();
  }
}
```


# 3. Spring Reactor 
https://potoyang.gitbook.io/spring-in-action-v5/
1. 响应流的 4 个接口规范：
- Publisher
```java
public interface Publisher<T> {
    // Subscriber 可以订阅 Publisher
    void subscribe(Subscriber<? super T> subscriber);
}
```
- Subscriber
```java
// 通过 Subscriber 接口从 Publisher 中接收消息
public interface Subscriber<T> {
    // 当 Publisher 调用 onSubscribe()，则通过一个 Subscription 对象将消息传输给 Subscriber
    void onSubscribe(Subscription sub);
    // 每个 Publisher 发布出来的 item 都会走 onNext() 方法传给 Subscriber
    void onNext(T item);
    // 异常处理
    void onError(Throwable ex);
    // Publisher 没有更多的数据要发送了
    void onComplete();
}
```
- Subscription
```java
// Subscriber 可以管理他自己的订阅内容
public interface Subscription {
    // Subscriber 可以调用 request() 去请求被发送了的数据
    void request(long n);
    // Subscriber 可以调用 cancel() 取消订阅
    void cancel();
}
```
- Processor
```java
// 连接 Subscriber 和 Publisher
// 1. 从 Publisher 接受数据（此时作为 Subscriber）
// 2. 发送给 Subscriber（此时作为 Publisher）
public interface Processor<T, R> extends Subscriber<T>, Publisher<R> {}
```

2. Mono and Flux
https://blog.51cto.com/liukang/2094073
https://blog.csdn.net/zyc88888/article/details/103679605
https://blog.csdn.net/get_set/article/details/79610895
- Flux: 返回 >=0 个（可以是无限个）数据项，包含 0 到 N 个元素的异步序列。类似于“流式计算”。
  - Flux<T>是一个标准Publisher<T>，表示0到N个发射项的异步序列。`可选地`以完成信号或错误或终止。
  - 与 Reactive Streams 规范中一样，这三种类型的信号转换为对下游订阅者的 onNext 、 onComplete 或 onError 方法的调用。
  - 因为三个方法是可选的，所以存在 onComplete()，意味着这是一个有限序列
  - 可是移除 onComplete 一般情况下，并没有特别有用
  - `Flux.interval(Duration delay, Duration period)` 产生一个无限序列，一般也就是测试 cancel 用到。
- Mono: 返回 <=1个数据项，包含 0 或者 1 个元素的异步序列。类似于“请求-响应”。
  - Mono<T>是一个专门的Publisher<T>，它最多发出一个项，然后 `可选的` 以 onComplete 信号或者 onError 信号结束掉
  - `Mono#concatWith(Publisher)` 返回一个 Flux， `Mono#then(Mono)` 则返回另一个 Mono
  - Mono 可以用于表示只有完成概念（类似 Runnable）的无值异步进程。如果要创建一个，可以用 Mono<Void>
- 综合：
  - 把两个 Mono 序列合并到一起，得到的是一个 Flux 对象
  - 对一个 Flux 序列进行 Count 操作，得到的是一个 Mono 对象

一个 Mono 的例子: 
注意: `只有subscribe()方法调用的时候才会触发数据流。所以，订阅前什么都不会发生。`
```java
Mono.just("Craig")                  // 产生一个 Mono
    .map(n -> n.toUpperCase())      // 经过 map 操作，产生第二个 Mono
    .map(cn -> "Hello, " + cn + "!")// 经过 map 操作，产生第三个 Mono
    .subscribe(System.out::println);// subscribe() 接受数据，并且打印
                                    // 实际上是 System.out::println 订阅了 前面的 Mono
```
从上面可以看出:
- 产生的 Mono 是 Publisher 角色
- System.out.println 是 Subscriber 角色
- System.out.println 订阅了 产生的 Mono

3. Flux/Mono 的基本操作
500 多种操作可以分为四大类：
- 创建操作
- 联合操作
- 传输操作
- 逻辑处理操作
例： flatMap() 操作: 将每个对象映射到一个新的 Mono 或 Flux，然后将其结果`压`成一个新的 Flux。
当与 subscribeOn() 一起使用时，flatMap() 可以释放 Reactor 类型的异步能力。
调用 subscribeOn() 来指示每个订阅应该在一个并行线程中进行。
因此，可以异步和并行地执行多个传入 String 对象的映射操作。
```java
@Test
public void flatMap() {
    Flux<Player> playerFlux = Flux
        .just("Michael Jordan", "Scottie Pippen", "Steve Kerr")
        .flatMap(n -> Mono.just(n)
                          .map(p -> {
                                      String[] split = p.split("\\s");
                                      return new Player(split[0], split[1]);
                                    })
                          // subscribeOn() 指示每个订阅应该在一个并行线程中进行
                          .subscribeOn(Schedulers.parallel())
                );
    
    List<Player> playerList = Arrays.asList(
        new Player("Michael", "Jordan"),
        new Player("Scottie", "Pippen"),
        new Player("Steve", "Kerr"));
    
    StepVerifier.create(playerFlux)
        .expectNextMatches(p -> playerList.contains(p))
        .expectNextMatches(p -> playerList.contains(p))
        .expectNextMatches(p -> playerList.contains(p))
        .verifyComplete();
}
```

4. 测试 Reactor 代码
使用 StepVerifier 可以对序列中包含的元素进行逐一验证。
```java
StepVerifier.create(Flux.just("a", "b"))
        .expectNext("a")
        .expectNext("b")
        .verifyComplete();
```

测试操作时间，使用 `StepVerifier.withVirtualTime()` 
```java
// 需要验证的流中包含两个产生间隔为一天的元素，并且第一个元素的产生延迟是 4 个小时。
StepVerifier.withVirtualTime(() ->  
    Flux.interval(Duration.ofHours(4), Duration.ofDays(1)).take(2)
      )
        .expectSubscription()
        // 前面 4 个小时是 delay 无元素产生
        .expectNoEvent(Duration.ofHours(4))
        .expectNext(0L)
        // 因为 period 是 1day 所以 1day 之后产生 2nd 元素
        .thenAwait(Duration.ofDays(1))
        .expectNext(1L)
        .verifyComplete();
```

5. 调试代码
- 启用调试模式输出 operator stack trace
在程序开始的地方，加上下面的代码，启用调试模式。所有操作符都在执行的时候，保存额外的与执行链相关的信息。出现错误时，这些信息被作为 异常堆栈信息的一部分输出。
```java
Hooks.onOperator(providedHook -> providedHook.operatorStacktrace());
```
- 启用检查点 checkpoint
通过 checkpoint 操作符来对`特定的`流处理链来启用调试模式。
```java
Flux.just(1, 0).map(x -> 1 / x)
    // 添加了一个名为 test 的检查点，当出现错误的时候，检查点名称会出现在异常堆栈信息中
    // 在关键位置上启用检查点，来帮助定位可能存在的问题
    .checkpoint("test")
    .subscribe(System.out::println);
```
- 通过添加 log 操作符来记录流相关的事件
```java
Flux.range(1, 2).log("RangeX").subscribe(System.out::println);
```
上述产生下面的日志
```java
13:07:56.735 [main] DEBUG reactor.util.Loggers$LoggerFactory - Using Slf4j logging framework
13:07:56.751 [main] INFO RangeX - | onSubscribe([Synchronous Fuseable] FluxRange.RangeSubscription)
13:07:56.753 [main] INFO RangeX - | request(unbounded)
13:07:56.754 [main] INFO RangeX - | onNext(1)
1
13:07:56.754 [main] INFO RangeX - | onNext(2)
2
13:07:56.754 [main] INFO RangeX - | onComplete()
```

6. 冷、热序列
- 冷序列: 不论订阅者在何时订阅该序列，总是能收到序列中产生的全部消息。
- 热序列: 则是在持续不断地产生消息，订阅者只能获取到在其订阅之后产生的消息。
下面是一个热序列的例子:
```java
final Flux<Long> source = Flux.intervalMillis(1000)
        .take(10)
        // 把 Flux 对象转换为 ConnectableFlux 对象
        .publish()
        // 当 ConnectableFlux 对象有一个订阅者的时候，就开始产生消息
        .autoConnect();
// 订阅该 ConnectableFlux 对象，此时已经开始产生消息
source.subscribe();
// 当前线程睡眠 5 秒
Thread.sleep(5000);
// 因为前面已经产生了 5 秒消息，此时是第二个 Subscriber,
// 那么只能读取到 5 秒之后的消息，所以看到的元素就是 5-9
source.toStream().forEach(System.out::println);
```

7. 切换执行的调度器，从而可以把 sync 方法转换为异步方法
通过 publishOn()和 subscribeOn()方法可以切换执行操作的调度器。
- publishOn()方法切换的是操作符的执行方式，在这一个特定的位置，这一刻，切换调度器。
- subscribeOn()方法切换的是产生流中元素时的执行方式。从源头影响，从源头开始切换到不同的调度器。
- publishOn 影响在其之后的operator 执行的线程池，而 subscribeOn 则会从源头影响整个执行过程
- 所以， publishOn 的影响范围和它的位置有关，而 subscribeOn 的影响范围则和位置无关，从源头开始影响

```java
// 方法 1. 创建 Mono 然后 publishOn 在异步线程上
return Mono.just("")
        // 我们借助elastic调度器将其变为异步
        .publishOn(Schedulers.elastic())
        .map( s -> helloWorldService.helloWorld(id));
```

```java
// 方法 2. 创建 Mono 然后订阅到 elastic scheduler
// 只要有人订阅了，那么这个序列流就在 elastic scheduler 执行了，而且是从头开始执行
return Mono
        .fromCallable(()->helloWorldService.helloWorld(id))
        .subscribeOn(Schedulers.elastic());
```


    
    
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
