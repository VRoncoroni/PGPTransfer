#!/bin/sh

# Nom de l'utilisateur dédié pour la génération des clés
USER_NAME_PGP="pgpuser"
USER_NAME_SSH="sshuser"
USER_HOME_SSH="/home/$USER_NAME_SSH"
KEY_FILE="/home/$USER_NAME_SSH/public_key_*.asc"
# Vérifie que le fichier de clé existe
if [ ! -e $KEY_FILE ]; then
  echo "Erreur: Aucun fichier de clé trouvé correspondant à '$KEY_FILE'."
  exit 1
fi

sudo -u $USER_NAME_PGP gpg --import $KEY_FILE
if [ $? -ne 0 ]; then
  echo "Erreur: L'importation de la clé a échoué."
  exit 1
fi

sudo -u $USER_NAME_PGP gpg --list-keys
read -p "Entrez l'ID de la clé ou l'adresse email pour la signature et la confiance : " KEY_ID
if [ -z "$KEY_ID" ]; then
  echo "Erreur: Impossible de récupérer l'ID de la clé."
  exit 1
fi

sudo -u $USER_NAME_PGP gpg --sign-key "$KEY_ID"
if [ $? -ne 0 ]; then
    echo "Erreur: La signature de la clé a échoué."
    exit 1
fi
echo "Clé signée avec succès."

echo "trust 5" | sudo -u $USER_NAME_PGP gpg --command-fd 0 --edit-key "$KEY_ID" trust quit
if [ $? -ne 0 ]; then
  echo "Erreur: L'attribution du niveau de confiance a échoué."
  exit 1
fi
echo "Niveau de confiance attribué avec succès."