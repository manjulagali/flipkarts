FROM ubuntu:22:04
RUN apt-get update
RUN apt-get install -y openjdk-21-jdk
ENV JAVA_HOME /usr
ADD apache-tomcat-11.0.26.tar.gz /root
COPY target/hello-maven.war /root/apache-tomcat-11.0.26/webapps
ENTRYPOINT /root/apache-tomcat-11.0.26/bin/startup.sh && bash
