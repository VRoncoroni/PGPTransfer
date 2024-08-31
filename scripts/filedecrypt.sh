#!/bin/sh

for FILE in /app/depot/*.asc; do
  if [ ! -e "$FILE" ]; then
    echo "Erreur: Aucun fichier trouvé correspondant à '$FILE'."
    exit 1
  fi
  sudo -u pgpuser gpg --decrypt $FILE > ${FILE%.asc}
  sudo -u pgpuser rm $FILE -f
done


