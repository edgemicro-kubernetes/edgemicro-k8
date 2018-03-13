FROM ubuntu:xenial

RUN apt-get update && apt-get install curl -y
ADD setup.sh /tmp/
RUN chmod +x /tmp/setup.sh

ENTRYPOINT ["/tmp/setup.sh"]
