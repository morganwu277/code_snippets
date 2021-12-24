In this post, we gonna create customized appender. Next is just an example of JTextArea.
1. We need a genearal appender class. `append()` method needs to be override and put logs to correct places. In the next it's `GUIClient.log(new String(bytes));`
    ```java
    package com.mycompany.myproject.gui;

    import java.io.Serializable;
    import java.util.concurrent.locks.Lock;
    import java.util.concurrent.locks.ReadWriteLock;
    import java.util.concurrent.locks.ReentrantReadWriteLock;

    import org.apache.logging.log4j.core.Filter;
    import org.apache.logging.log4j.core.Layout;
    import org.apache.logging.log4j.core.LogEvent;
    import org.apache.logging.log4j.core.appender.AbstractAppender;
    import org.apache.logging.log4j.core.appender.AppenderLoggingException;
    import org.apache.logging.log4j.core.config.plugins.Plugin;
    import org.apache.logging.log4j.core.config.plugins.PluginAttribute;
    import org.apache.logging.log4j.core.config.plugins.PluginElement;
    import org.apache.logging.log4j.core.config.plugins.PluginFactory;
    import org.apache.logging.log4j.core.layout.PatternLayout;

    /**
     * Annotation name here should be same as log4j2.xml config file
     */
    @Plugin(name = "TextArea", category = "Core", elementType = "appender", printObject = true)
    public class TextAreaAppender extends AbstractAppender {

        /**
         * @fields serialVersionUID
         */
        private static final long serialVersionUID = -830237775522429777L;
        private final ReadWriteLock rwLock = new ReentrantReadWriteLock();
        private final Lock readLock = rwLock.readLock();

        protected TextAreaAppender(final String name, final Filter filter, final Layout<? extends Serializable> layout,
            final boolean ignoreExceptions) {
            super(name, filter, layout, ignoreExceptions);
        }

        @Override
        public void append(LogEvent event) {
            readLock.lock();
            try {
                final byte[] bytes = getLayout().toByteArray(event);
                // updated the logger text area
                GUIClient.log(new String(bytes));
            }
            catch (Exception ex) {
                if (!ignoreExceptions()) {
                    throw new AppenderLoggingException(ex);
                }
            }
            finally {
                readLock.unlock();
            }
        }

        // receive parameters from log4j2.xml config file and create an Appender
        @PluginFactory
        public static TextAreaAppender createAppender(@PluginAttribute("name") String name,
            @PluginElement("Filter") final Filter filter,
            @PluginElement("Layout") Layout<? extends Serializable> layout,
            @PluginAttribute("ignoreExceptions") boolean ignoreExceptions) {
            if (name == null) {
                LOGGER.error("No name provided for MyCustomAppenderImpl");
                return null;
            }
            if (layout == null) {
                layout = PatternLayout.createDefaultLayout();
            }
            return new TextAreaAppender(name, filter, layout, ignoreExceptions);
        }

    }
    ```
2. In the `GUIClient.log()` implementation we will append updated logs to TextArea.
    ```java
        public static void log(String str) {
            THREADPOOL.submit(() -> {
                SwingUtilities.invokeLater(() -> {
                    synchronized (GUIClient.class) {
                        if (textAreaForLogger != null) {
                            textAreaForLogger.setText(textAreaForLogger.getText() + str);
                        }
                    }
                });
            });
        }
    ```
3. With regular log4j2.xml config file. We must use the exact name `textarea` to match the annotation above.
    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <Configuration strict="true" monitorinterval="30">
        <Properties>
                <Property name="logPath">${sys:java.io.tmpdir}/gui-client.log</Property>
        </Properties>
        <Appenders>
            <Console name="Console">
                <ThresholdFilter level="debug" />
                <PatternLayout pattern="%d{HH:mm:ss.SSS} %5p %c - [%t] %m%n" /> <!-- %d %p %C{1.} [%t] %m%n -->
            </Console>
            <RollingFile name="LogFile" filePattern="${sys:logPath}.%d{yyyyMMdd}.gz" append="false">
                <ThresholdFilter level="debug" />
                <PatternLayout pattern="%d{HH:mm:ss.SSS} %5p %c - [%t] %m%n" />
                <Policies>
                    <TimeBasedTriggeringPolicy />
                </Policies>
            </RollingFile>
            <TextArea name="textarea">
                <PatternLayout pattern="%d{HH:mm:ss.SSS} %5p %c - [%t] %m%n" />
            </TextArea>
        </Appenders>
        <Loggers>
            <Logger name="org.apache" level="INFO" />

            <Root level="DEBUG">
                <AppenderRef ref="Console"/>
                <AppenderRef ref="LogFile" />
                <AppenderRef ref="textarea" />
            </Root>
        </Loggers>
    </Configuration>
    ```

