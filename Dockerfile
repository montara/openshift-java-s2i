FROM openshift/base-centos7
MAINTAINER Chakradhar Rao Jonagam (9chakri@gmail.com)

ENV BUILDER_VERSION 1.1

RUN yum -y update; \
    yum install wget -y; \
    yum install tar -y; \
    yum install unzip -y; \
    yum install ca-certificates -y;\
    yum install sudo -y;\
    yum clean all -y

ENV JDK_VERSION 7u79
ENV JBOSS_VERSION 6.4.9
ENV CATALINA_HOME /tomcat

# Install jdk
RUN yum install http://artifact.abcfinancial.net/artifactory/abc-yum-local/jdk-$JDK_VERSION-linux-x64.rpm -y && \
    yum clean all -y && \
    rm -rf /var/lib/apt/lists/*

# INSTALL JBOSS
WORKDIR /

RUN groupadd -g 1502 jboss
RUN groupadd -g 510 jbossgrp
RUN useradd -u 501 -g jbossgrp -m -d /home/jbossusr -s /bin/bash jbossusr

RUN mkdir -m 00755 -p /logs /logs/jboss /logs/jboss/service /etc/jboss
RUN for dir in /logs /logs/jboss /logs/jboss/service /etc/jboss; do chown jbossusr:jbossgrp $dir; done

RUN wget -q -e use_proxy=yes http://artifact.abcfinancial.net/artifactory/abc-yum-local/jboss-eap-$JBOSS_VERSION.tar.gz" && \
    tar -zxf jboss-eap-$JBOSS_VERSION.tar.gz &&\
    rm -f jboss-eap-$JBOSS_VERSION.tar.gz && \
    mv jboss-eap-$JBOSS_VERSION jboss

RUN cd /jboss && \
    wget -q -e use_proxy=yes http://artifact.abcfinancial.net/artifactory/generic-local/modules.tar.gz" && \
    tar -zxf modules.tar.gz &&\
    rm -f modules.tar.gz

RUN chown -R jbossusr.jbossgrp /jboss

COPY ./.s2i/bin/ /usr/libexec/s2i

USER 501

EXPOSE 8080

CMD $STI_SCRIPTS_PATH/usage
