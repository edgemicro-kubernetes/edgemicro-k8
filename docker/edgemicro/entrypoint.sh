#!/bin/bash

echo "Started entry point" >> /tmp/entrypoint.log

echo $EDGEMICRO_ORG >> /tmp/test.txt
echo $EDGEMICRO_ENV >> /tmp/test.txt
echo $EDGEMICRO_KEY >> /tmp/test.txt
echo $EDGEMICRO_SECRET >> /tmp/test.txt

if [ ${EDGEMICRO_CONFIG} != "" ]; then
	echo ${EDGEMICRO_CONFIG} >> /tmp/test.txt
	echo ${EDGEMICRO_CONFIG} | base64 --decode > /home/microgateway/.edgemicro/$EDGEMICRO_ORG-$EDGEMICRO_ENV-config.yaml
	chown microgateway:microgateway /home/microgateway/.edgemicro/*
fi

su - microgateway -m -c "cd /home/microgateway && edgemicro start -c /home/microgateway/.edgemicro &" 

# SIGUSR1-handler
my_handler() {
  echo "my_handler" >> /tmp/entrypoint.log
  su - microgateway -m -c "cd /home/microgateway && edgemicro stop"
}

# SIGTERM-handler
term_handler() {
  echo "term_handler" >> /tmp/entrypoint.log
  su - microgateway -m -c "cd /home/microgateway && edgemicro stop"
  exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'kill ${!}; my_handler' SIGUSR1
trap 'kill ${!}; term_handler' SIGTERM

while true
do
        tail -f /dev/null & wait ${!}
done

