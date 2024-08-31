#!/bin/sh

if [ $# -lt 2 ]; then
  echo "Usage: $0 <remote_server> <password>"
  exit 1
fi

USER_NAME_SSH="sshuser"
REMOTE_SERVER="$1"
REMOTE_PASSWORD="$2"
REMOTE_PATH="/app/depot/"

sudo -u $USER_NAME_SSH sshpass -p $REMOTE_PASSWORD scp -o StrictHostKeyChecking=no -r /app/depot/*.asc $USER_NAME_SSH@$REMOTE_SERVER:$REMOTE_PATH
# add horodatage to the file in file name and move it to the archive folder
for file in /app/depot/*.asc; do
  sudo -u $USER_NAME_SSH mv "$file" "/app/depot/archive/$(date +%Y%m%d%H%M%S)_$(basename "$file")"
done
