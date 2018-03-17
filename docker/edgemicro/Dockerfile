FROM centos:centos7
#FROM node:slim

RUN yum install epel-release -y && yum install nodejs -y
RUN groupadd apigee
RUN useradd apigee -g apigee -m -d /opt/apigee
RUN npm install -g edgemicro
RUN su - apigee -c "edgemicro init"

RUN mkdir -p /opt/apigee/logs
VOLUME /opt/apigee/.edgemicro
VOLUME /opt/apigee/logs
RUN chown apigee:apigee /opt/apigee/.edgemicro/*
COPY entrypoint.sh /tmp
COPY proxies.yaml /tmp
RUN chmod +x /tmp/entrypoint.sh
# copy tls files if needed
# COPY key.pem /root/.edgemicro
# COPY cert.pem /root/.edgemicro
EXPOSE 8000
EXPOSE 8443
ENTRYPOINT ["/tmp/entrypoint.sh"]
