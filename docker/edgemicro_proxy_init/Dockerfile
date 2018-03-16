FROM ubuntu:xenial
RUN apt-get update && apt-get install -y \
    iptables \ 
 && rm -rf /var/lib/apt/lists/* \
 && apt-get -qq update \
 && apt-get -qq -y install curl

ADD prepare_proxy.sh /tmp/
RUN chmod +x /tmp/prepare_proxy.sh
ENTRYPOINT ["/tmp/prepare_proxy.sh"]