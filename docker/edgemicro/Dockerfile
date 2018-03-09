FROM node:slim
ARG ORG=someorg
ARG ENV=someenv
#uncomment these if you're not using k8s secrets
#ARG KEY=somekey
#ARG SECRET=somesecret
#ENV EDGEMICRO_ORG=$ORG
#ENV EDGEMICRO_ENV=$ENV
#ENV EDGEMICRO_KEY=$KEY
#ENV EDGEMICRO_SECRET=$SECRET

RUN groupadd microgateway
RUN useradd microgateway -g microgateway -m -d /home/microgateway
RUN npm install -g edgemicro
RUN su - microgateway -c "edgemicro init"
COPY $ORG-$ENV-config.yaml /home/microgateway/.edgemicro
RUN chown microgateway:microgateway /home/microgateway/.edgemicro/*
COPY entrypoint.sh /tmp
RUN chmod +x /tmp/entrypoint.sh
# copy tls files if needed
# COPY key.pem /root/.edgemicro
# COPY cert.pem /root/.edgemicro
EXPOSE 8000
EXPOSE 8443
ENTRYPOINT ["/tmp/entrypoint.sh"]
CMD [""]
