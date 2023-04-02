FROM openjdk:8-jdk-alpine

ADD java-demo.jar java-demo.jar
ADD opentelemetry-javaagent.jar opentelemetry-javaagent.jar
# 修改时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# 解决中文乱码
ENV LANG en_US.UTF-8
## 采集通过 otlp
## "-Dspring.profiles.active=test" 区分环境配置
ENTRYPOINT ["java","-javaagent:opentelemetry-javaagent.jar","-Dotel.resource.attributes=service.name=collector-demo","-Dotel.metrics.exporter=otlp","-Dotel.traces.exporter=otlp","-Djava.security.egd=file:/dev/./urandom","-jar","java-demo.jar"]
