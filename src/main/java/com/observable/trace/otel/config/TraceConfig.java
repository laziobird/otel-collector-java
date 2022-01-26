package com.observable.trace.otel.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * @author liurui
 * @date 2021/12/30
 */
@Component
@ConfigurationProperties(prefix = "trace.exporter")
public class TraceConfig {
    private String host;
    private String port;
    private String uiPort;

    public String getHost() {
        return host;
    }

    public void setHost(String host) {
        this.host = host;
    }

    public String getPort() {
        return port;
    }

    public void setPort(String port) {
        this.port = port;
    }

    public String getUiPort() {
        return uiPort;
    }

    public void setUiPort(String uiPort) {
        this.uiPort = uiPort;
    }
}
