#!/bin/sh

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

if [ $# -lt 2 ]; then
    log "Usage: $0 <PATH_TO_FILE> <RECIPIENT:EMAIL_REMOTE>"
    exit 1
fi

FILE="$1"
RECIPIENT="$2"
if [ ! -e "$FILE" ]; then
    log "Error: No file found at '$FILE'."
    exit 1
fi

# Extract the base name and extension
BASE_NAME="${FILE%.*}"
EXTENSION="${FILE##*.}"
ENCRYPTED_FILE="${BASE_NAME}_ENC.${EXTENSION}"

log "Starting encryption process for file: $FILE with recipient: $RECIPIENT..."

log "Encrypting file: $FILE"
sudo -u pgpuser gpg --batch --yes --encrypt --armor --recipient "$RECIPIENT" "$FILE" > "$ENCRYPTED_FILE"
if [ $? -ne 0 ]; then
    log "Error: Failed to encrypt file '$FILE'."
    exit 1
fi

log "Removing original file: $FILE"
sudo -u pgpuser rm "$FILE" -f
if [ $? -ne 0 ]; then
    log "Error: Failed to remove file '$FILE'."
    exit 1
fi

log "File '$FILE' encrypted and original file removed successfully."
log "Encryption process completed."
