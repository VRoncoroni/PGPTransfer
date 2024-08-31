#!/bin/sh
if [ $# -lt 1 ]; then
  echo "Usage: $0 <RECIPIENT:EMAIL_REMOTE>"
  exit 1
fi

RECIPIENT="$1"

for FILE in /app/depot/*.txt; do
  if [ ! -e "$FILE" ]; then
    echo "Erreur: Aucun fichier trouvé correspondant à '$FILE'."
    exit 1
  fi
  sudo -u pgpuser gpg --batch --yes --encrypt --armor --recipient "$RECIPIENT" $FILE
  sudo -u pgpuser rm $FILE -f
done


