# reactor-core
Next code shows how we implement publish-subscribe using reactor-core library, basically it:
1. create publisher (subject) 
2. subscribe to the publisher and consume the messages from it
3. publish two messages, and print it out using log4j
```java
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import reactor.core.publisher.Flux;
import reactor.core.publisher.FluxSink;

import java.time.Duration;
import java.time.temporal.ChronoUnit;
import java.util.Date;

@Slf4j
public class ReactiveStreamTest {
    abstract static class AbstractPublisher<T> {
        private volatile FluxSink<T> sink;
        public AbstractPublisher() {}
        public AbstractPublisher(FluxSink<T> sink) { this.sink = sink; }
        public void setSink(FluxSink<T> sink) { this.sink = sink; }
        public void publish(T msg) {
            if(this.sink != null) {
                this.sink.next(msg);
            } else {
                log.warn("sink is null, ignoring {}", msg);
            }
        }
    }

    abstract static class ReactiveUtils {
        public static <T> Flux<T> createFluxFromPublisher(AbstractPublisher<T> publisher, boolean multicast) {
            // created serialiezd sink, which is safe to use in multi-thread case
            // https://github.com/reactor/reactor-core/blob/v3.2.0.RELEASE/reactor-core/src/main/java/reactor/core/publisher/FluxCreate.java#L93
            final Flux<T> flux = Flux.create((FluxSink<T> fluxSink) -> { // this anonymous function will only be invoked after .subscribe() happen
                fluxSink.onDispose(() -> publisher.setSink(null));
                publisher.setSink(fluxSink);
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
    static class GeneralMessagePublisher extends AbstractPublisher<GeneralMessage> {}

    /**
     * output:
     * 01:16:44.577 [main] INFO ReactiveStreamTest - GeneralMessage: Wed May 04 01:16:44 EDT 2022
     * 01:16:44.577 [main] INFO ReactiveStreamTest - GeneralMessage: Wed May 04 01:16:44 EDT 2022
     * @throws InterruptedException
     */
    @Test
    public void testFluxOp() throws InterruptedException {
        final AbstractPublisher<GeneralMessage> messagePublisher = new GeneralMessagePublisher();
        final Flux<GeneralMessage> generalMessageFlux = ReactiveUtils.createFluxFromPublisher(messagePublisher, false);
        generalMessageFlux
                .delaySubscription(Duration.of(990, ChronoUnit.MILLIS)) // if longer or close to 1second, will easily miss 2 message below
                .subscribe(msg -> log.info("{}", msg));// will start to create flux immediately after .subscribe()
        Thread.sleep(1000);
        messagePublisher.publish(new GeneralMessage());
        messagePublisher.publish(new GeneralMessage());
    }
}
```