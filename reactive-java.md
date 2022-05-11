# reactor-core
Next code shows how we implement publish-subscribe using reactor-core library, basically it:
1. create publisher (subject) 
2. subscribe to the publisher and consume the messages from it
3. publish two messages, and print it out using log4j
```java
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import reactor.core.publisher.Flux;
import reactor.core.publisher.FluxSink;
import reactor.core.scheduler.Schedulers;

import java.time.Duration;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import java.util.function.Consumer;

@Slf4j
public class ReactiveStreamTest {
    abstract static class AbstractPublisher<T> {
        @Getter
        private Consumer<T> consumer;
        private Runnable completer;

        public synchronized void addConsumer(Consumer<T> consumer) {
            this.consumer = consumer;
        }
        public synchronized void addCompleter(Runnable completer) {
            this.completer = completer;
        }
        public synchronized void removeConsumer() {
            this.consumer = null;
        }
        public void completePublished() {
            this.completer.run();
        }
        public void publish(T msg) {
            if(this.consumer != null) {
                this.consumer.accept(msg);
            } else {
                log.warn("consumer of sink is null, ignoring {}", msg);
            }
        }
    }

    abstract static class ReactiveUtils {
        public static <T> Flux<T> createFluxFromPublisher(AbstractPublisher<T> publisher, boolean multicast) {
            // created serialized sink, which is safe to use in multi-thread case
            // https://github.com/reactor/reactor-core/blob/v3.2.0.RELEASE/reactor-core/src/main/java/reactor/core/publisher/FluxCreate.java#L93
            final Flux<T> flux = Flux.create((FluxSink<T> emitter) -> { // this anonymous function will only be invoked after .subscribe() happen
                emitter.onDispose(publisher::removeConsumer);
                publisher.addConsumer(emitter::next);
                publisher.addCompleter(emitter::complete);
            });
            if (multicast) {
                return flux.share();
            } else {
                return flux;
            }
        }
    }

    static class GeneralMessage {
        private String time;
        public GeneralMessage() {
            time = new Date().toString();
        }
        @Override
        public String toString() {
            return "GeneralMessage: " + time;
        }
    }
    static class GeneralMessagePublisher extends AbstractPublisher<GeneralMessage> {
    }

    /**
     * output:
     * 17:11:26.778 [main] DEBUG reactor.util.Loggers$LoggerFactory - Using Slf4j logging framework
     * 17:11:26.836 [main] INFO reactor.Flux.DelaySubscription.1 - onSubscribe(FluxDelaySubscription.DelaySubscriptionOtherSubscriber)
     * 17:11:26.842 [main] INFO reactor.Flux.DelaySubscription.1 - request(256)
     * 17:11:27.844 [main] INFO reactor.Flux.DelaySubscription.1 - onNext(GeneralMessage: Wed May 11 17:11:27 EDT 2022)
     * 17:11:27.845 [main] INFO reactor.Flux.DelaySubscription.1 - onNext(GeneralMessage: Wed May 11 17:11:27 EDT 2022)
     * 17:11:27.845 [single-1] INFO ReactiveStreamTest - GeneralMessage: Wed May 11 17:11:27 EDT 2022
     * 17:11:27.845 [main] INFO reactor.Flux.DelaySubscription.1 - onNext(GeneralMessage: Wed May 11 17:11:27 EDT 2022)
     * 17:11:27.845 [single-1] INFO ReactiveStreamTest - GeneralMessage: Wed May 11 17:11:27 EDT 2022
     * 17:11:27.845 [single-1] INFO ReactiveStreamTest - GeneralMessage: Wed May 11 17:11:27 EDT 2022
     * 17:11:27.845 [main] INFO reactor.Flux.DelaySubscription.1 - onNext(GeneralMessage: Wed May 11 17:11:27 EDT 2022)
     * 17:11:27.845 [main] INFO reactor.Flux.DelaySubscription.1 - onNext(GeneralMessage: Wed May 11 17:11:27 EDT 2022)
     * 17:11:27.845 [single-1] INFO ReactiveStreamTest - GeneralMessage: Wed May 11 17:11:27 EDT 2022
     * 17:11:27.845 [single-1] INFO ReactiveStreamTest - GeneralMessage: Wed May 11 17:11:27 EDT 2022
     * 17:11:27.846 [main] INFO reactor.Flux.DelaySubscription.1 - onComplete()
     * @throws InterruptedException
     */
    @Test
    public void testFluxOp() throws InterruptedException {
        final AbstractPublisher<GeneralMessage> messagePublisher = new GeneralMessagePublisher();
        final Flux<GeneralMessage> generalMessageFlux = ReactiveUtils.createFluxFromPublisher(messagePublisher, false);
        generalMessageFlux
                .delaySubscription(Duration.of(900, ChronoUnit.MILLIS)) // if longer or close to 1second, will easily miss 2 message below
                .log()
                .publishOn(Schedulers.single())
                .subscribe(msg -> log.info("{}", msg)); // will start to create flux immediately after .subscribe()

        // start to injest message into this this fluxsink
        Thread.sleep(1000);
        messagePublisher.publish(new GeneralMessage());
        messagePublisher.publish(new GeneralMessage());
        messagePublisher.publish(new GeneralMessage());
        messagePublisher.publish(new GeneralMessage());
        messagePublisher.publish(new GeneralMessage());
        messagePublisher.completePublished();
        Thread.sleep(1000);
    }

    @Test
    public void testIntFlux() throws InterruptedException {
        Flux.range(1,3000)
                .log()
                .subscribe(msg -> log.info("{}", msg));
    }
}
```
