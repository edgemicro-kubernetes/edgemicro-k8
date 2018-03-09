#!/bin/bash

echo "Started entry point" >> /tmp/entrypoint.log

su - microgateway -m -c "cd /home/microgateway && edgemicro start" 

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

