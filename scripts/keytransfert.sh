#!/bin/sh

if [ $# -lt 2 ]; then
  echo "Usage: $0 <remote_server> <password>"
  exit 1
fi

USER_NAME_PGP="pgpuser"
USER_NAME_SSH="sshuser"
REMOTE_SERVER="$1"
REMOTE_PASSWORD="$2"
REMOTE_PATH="/home/$USER_NAME_SSH/public_key_$(hostname).asc"

sudo -u pgpuser sshpass -p $REMOTE_PASSWORD scp -o StrictHostKeyChecking=no -r /home/$USER_NAME_PGP/public_key.asc $USER_NAME_SSH@$REMOTE_SERVER:$REMOTE_PATH