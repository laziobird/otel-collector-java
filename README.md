<a name="wSh88"></a>
# OpenTelemetry Collector Demo
<a name="XGdFY"></a>
## Introduction
OpenTelemetry Collector+Jaeger+Prometheus的可观测案例

- Gateway ：Nginx
- 前端：Java SpringBoot Web + OpenTelemetry +  Jaeger Trace Exporter  + Prometheus Metric Exporter
- 后端：OpenTelemetry Collector 、Jaeger UI 、Prometheus UI

深入了解可观测体系下Traces、Metrics采集、运行原理<br />演示地址 [http://www.opentelemetry.cool/collector/demo](http://www.opentelemetry.cool/collector/demo)<br />
  - ![Alt Text](./assets/introduce.gif)
## Architecture
![image.png](./assets/arc.png#clientId=u2d91e3eb-f650-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=411&id=u431635f7&margin=%5Bobject%20Object%5D&name=image.png&originHeight=546&originWidth=960&originalType=binary&ratio=1&rotation=0&showTitle=false&size=259252&status=done&style=none&taskId=ud0e6f27d-1853-4f67-ba14-bcc120aff61&title=&width=723)
<a name="cqdhz"></a>
## Tracing 效果图
 ![image.png](./assets/trace.png#clientId=u58d1f88b-2c01-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=310&id=ucb9dec40&margin=%5Bobject%20Object%5D&name=image.png&originHeight=609&originWidth=1439&originalType=binary&ratio=1&rotation=0&showTitle=false&size=356007&status=done&style=none&taskId=uf76b343d-c5d3-4a5f-bb95-3abc4cab5a3&title=&width=732)
## Prometheus 采集Metric
 ![prometheus.jpg](./assets/prometheus.jpg)
## 框架列表
| **Library/Framework** | **Versions** | **备注** |
| --- | --- | --- | 
| opentelemetry-collector-contrib | 0.74.0 | ​<br /> |
| opentelemetry-api | 1.9.1 | ​<br /> |
| opentelemetry-sdk | 1.9.1 | ​<br /> |
| opentelemetry-exporter-jaeger | 1.9.1 | ​<br /> |
| jaegertracing | all-in-one:1.29 | docker镜像 |
| spring-boot | 2.6.2 |  |
<a name="tfZIA"></a>
### Linux
  - Docker 环境，三个服务部署在一台服务器上，网络Host模式
```shell
## down
docker-compose -f /path/docker-compose-collector.yml  down
## start
docker-compose -f /path/docker-compose-collector.yml  up -d
```
<a name="Je6W1"></a>
### Windows
具体看这个Issue： [windows系统无法对docker容器进行端口映射的问题](https://github.com/laziobird/otel-collector-java/issues/1) 
### Mac
Mac 用Docker Host 模式不支持的，请把 OpenTelemetry Collector、Jaeger 端口映射方式部署<br />
[There is no docker0 bridge on the host](https://docs.docker.com/desktop/networking/)<br />
<a name="T6DHp"></a>
## 采样 Sampling
只上报异常链路采样Demo
```yaml
processors:
  batch:
  tail_sampling:
    ##decision_wait: 10s
    ##num_traces: 100
    ##expected_new_traces_per_sec: 100
    policies:
      [
          {
            name: test-policy-5,
            type: status_code,
            status_code: {status_codes: [ERROR]}
          }
      ]
service:
  extensions: [pprof,health_check]
  pipelines:
    traces:
      receivers: [otlp]
      processors: [tail_sampling]
      exporters: [jaeger]
```
### 采样的效果
- 采样前:
  ![image.png](./assets/sampling-pre.png)
- 采样后: Processor 处理器添加了尾部取样 `processors: [tail_sampling]`
  ![image.png](./assets/sampling.png)


### 开启Collector 下的Logging Exporter
- Collector 添加 `Exporter: [logging]`
```yaml
exporters:
 ##设置exporters上报 collector 控制台信息
 logging:
  loglevel: "debug"
  
  pipelines:
    traces:
      receivers: [otlp]
      processors: [tail_sampling]
      exporters: [jaeger,logging]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [prometheus,logging]

```
- 生效后: Collector 的日志控制台打印完整的上报链路结构
  ![span.jpg](./assets/span.jpg)

## 更多Collector 插件的用法
- filterprocessor：[使用案例](./rules/README.md)

### 开启日志 debug 模式
#### Version 0.36 and above:
Set the log level in the config `service::telemetry::logs`
```yaml
service:
  telemetry:
    logs:
      level: "debug"
```
<a name="T6DHp"></a> 

## 重新编译Java 项目
<a name="KDdV7"></a>
### Maven 编译Java 程序
```shell
mvn package -DskipTests=true
```
- target下把对应jar包重命名`java-demo.jar`，放到`Dockerfile`文件同级目录
- Docker默认网络方式是`Host`模式、将Spring Boot 的配置文件`otel-collector-java/src/main/resources/application-test.yml` 的 `host` 设置成你的内网 IP，配置SDK 上报Jaeger服务器地址
```yml
trace:
 sdk:
  exporter:
   host: "127.0.0.1"
   port: "14250"
```
### 区分环境部署
- Dockerfile `ENTRYPOINT` 中添加环境变量
```yaml
"-Dspring.profiles.active=test"
```

## Documentation
[https://github.com/open-telemetry/opentelemetry-java-instrumentation](https://github.com/open-telemetry/opentelemetry-java-instrumentation)<br />[https://www.jaegertracing.io/docs/1.29/getting-started/](https://www.jaegertracing.io/docs/1.29/getting-started/)<br />[https://opentelemetry.io/docs/](https://opentelemetry.io/docs/)<br />[https://github.com/open-telemetry/opentelemetry-java](https://github.com/open-telemetry/opentelemetry-java/blob/main/sdk-extensions/autoconfigure/README.md#otlp-exporter-both-span-and-metric-exporters)<br />[https://github.com/open-telemetry/opentelemetry-collector](https://github.com/open-telemetry/opentelemetry-collector)<br />[opentelemetry-collector tailsamplingprocessor](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/processor/tailsamplingprocessor)
## 联系
如果有什么疑问和建议，欢迎提交issues，我会第一时间回复
