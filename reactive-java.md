# reactor-core
Next code shows how we implement publish-subscribe using reactor-core library, basically it:
1. create publisher (subject) which implements `implements Consumer<FluxSink<T>>` interface
2. subscribe to the publisher and consume the messages from it
3. publish several messages, and print it out using log4j
```java
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import reactor.core.publisher.Flux;
import reactor.core.publisher.FluxSink;
import reactor.core.scheduler.Schedulers;

import java.time.Duration;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import java.util.function.Consumer;
import java.util.stream.IntStream;

@Slf4j
public class ReactiveStreamTest2 {
    abstract static class AbstractPublisher<T> implements Consumer<FluxSink<T>> {
        private FluxSink<T> fluxSink;

        @Override
        public void accept(FluxSink<T> fluxSink) {
            this.fluxSink = fluxSink;
        }

        public void publish(T msg) {
            if(this.fluxSink == null) {
                log.warn("consumer of sink is null, ignoring {}", msg);
            } else {
                this.fluxSink.next(msg);
            }
        }

        public void complete() {
            this.fluxSink.complete();
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
     * 00:55:13.752 [main] DEBUG reactor.util.Loggers$LoggerFactory - Using Slf4j logging framework
     * 00:55:13.810 [main] INFO reactor.Flux.DelaySubscription.1 - onSubscribe(FluxDelaySubscription.DelaySubscriptionOtherSubscriber)
     * 00:55:13.818 [main] INFO reactor.Flux.DelaySubscription.1 - request(256)
     * 00:55:14.821 [main] INFO reactor.Flux.DelaySubscription.1 - onNext(GeneralMessage: Tue May 17 00:55:14 EDT 2022)
     * 00:55:14.822 [main] INFO reactor.Flux.DelaySubscription.1 - onNext(GeneralMessage: Tue May 17 00:55:14 EDT 2022)
     * 00:55:14.822 [single-1] INFO ReactiveStreamTest2 - GeneralMessage: Tue May 17 00:55:14 EDT 2022
     * 00:55:14.822 [single-1] INFO ReactiveStreamTest2 - GeneralMessage: Tue May 17 00:55:14 EDT 2022
     * 00:55:14.822 [main] INFO reactor.Flux.DelaySubscription.1 - onNext(GeneralMessage: Tue May 17 00:55:14 EDT 2022)
     * 00:55:14.822 [main] INFO reactor.Flux.DelaySubscription.1 - onNext(GeneralMessage: Tue May 17 00:55:14 EDT 2022)
     * 00:55:14.822 [single-1] INFO ReactiveStreamTest2 - GeneralMessage: Tue May 17 00:55:14 EDT 2022
     * 00:55:14.822 [single-1] INFO ReactiveStreamTest2 - GeneralMessage: Tue May 17 00:55:14 EDT 2022
     * 00:55:14.822 [main] INFO reactor.Flux.DelaySubscription.1 - onComplete()
     *
     * @throws InterruptedException
     */
    @Test
    public void testFluxOp() throws InterruptedException {
        final AbstractPublisher<GeneralMessage> messagePublisher = new GeneralMessagePublisher();
        final Flux<GeneralMessage> generalMessageFlux = Flux.create(messagePublisher);
        generalMessageFlux
                .delaySubscription(Duration.of(900, ChronoUnit.MILLIS)) // if longer or close to 1second, will easily miss 2 message below
                .log()
                .publishOn(Schedulers.single())
                .subscribe(msg -> log.info("{}", msg)); // will start to create flux immediately after .subscribe()

        // start to ingestion message into this this fluxsink
        Thread.sleep(1000L);
        IntStream.range(1, 5).forEach(i -> messagePublisher.publish(new GeneralMessage()));
        messagePublisher.complete();
//        Thread.sleep(1000);
    }
}
```
