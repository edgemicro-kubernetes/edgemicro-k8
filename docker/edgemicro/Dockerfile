FROM node:slim

RUN groupadd microgateway
RUN useradd microgateway -g microgateway -m -d /home/microgateway
RUN npm install -g edgemicro
RUN su - microgateway -c "edgemicro init"

VOLUME /home/microgateway/.edgemicro/
RUN chown microgateway:microgateway /home/microgateway/.edgemicro/*
COPY entrypoint.sh /tmp
RUN chmod +x /tmp/entrypoint.sh
# copy tls files if needed
# COPY key.pem /root/.edgemicro
# COPY cert.pem /root/.edgemicro
EXPOSE 8000
EXPOSE 8443
ENTRYPOINT ["/tmp/entrypoint.sh"]
