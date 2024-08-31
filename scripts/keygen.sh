#!/bin/sh

USER_NAME="pgpuser"
USER_HOME="/home/$USER_NAME"
KEY_NAME="SFTP Key"
KEY_COMMENT="pgpuser@$(hostname)"
KEY_EMAIL="pgpuser@$(hostname)"
KEY_TYPE="RSA"
KEY_LENGTH="4096"
KEY_EXPIRE="1y"
KEY_PASSPHRASE="strong-passphrase"

create_user() {
    if id "$USER_NAME" &>/dev/null; then
        echo "L'utilisateur $USER_NAME existe déjà."
    else
        echo "Création de l'utilisateur $USER_NAME..."
        adduser -D $USER_NAME
    fi
}

generate_pgp_key() {
    echo "Génération de la clé PGP pour l'utilisateur $USER_NAME..."

    sudo -u $USER_NAME gpg --batch --generate-key <<EOF
Key-Type: $KEY_TYPE
Key-Length: $KEY_LENGTH
Name-Real: $KEY_NAME
Name-Comment: $KEY_COMMENT
Name-Email: $KEY_EMAIL
Expire-Date: $KEY_EXPIRE
Passphrase: $KEY_PASSPHRASE
%commit
EOF
}

export_public_key() {
    echo "Exportation de la clé publique..."
    sudo -u $USER_NAME gpg --armor --export "$KEY_EMAIL" > $USER_HOME/public_key.asc
    echo "Clé publique exportée dans $USER_HOME/public_key.asc"
}

create_user
generate_pgp_key
export_public_key

echo "Opération terminée. La clé PGP a été générée et exportée."