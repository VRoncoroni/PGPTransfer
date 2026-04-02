#!/bin/sh

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

if [ $# -lt 1 ]; then
    log "Usage: $0 <PATH_TO_FILE>"
    exit 1
fi

FILE="$1"
if [ ! -e "$FILE" ]; then
    log "Error: No file found at '$FILE'."
    exit 1
fi

log "Starting decryption process for file: $FILE..."

# Extract the base name and extension
BASE_NAME="${FILE%_ENC.*}"
EXTENSION="${FILE##*.}"
DECRYPTED_FILE="${BASE_NAME}.${EXTENSION}"

log "Decrypting file: $FILE"
sudo -u pgpuser gpg --decrypt "$FILE" > "$DECRYPTED_FILE"
if [ $? -ne 0 ]; then
    log "Error: Failed to decrypt file '$FILE'."
    exit 1
fi

log "Removing encrypted file: $FILE"
sudo -u pgpuser rm "$FILE" -f
if [ $? -ne 0 ]; then
    log "Error: Failed to remove file '$FILE'."
    exit 1
fi

log "File '$FILE' decrypted and removed successfully."
log "Decryption process completed."
