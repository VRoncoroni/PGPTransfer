# PGPTransfer
Description of setting up a bidirectional multi-file transfer between two docker containers with encryption via PGP key

## Prerequisites

* Docker
* Docker-compose

## Architecture

The architecture of this project consists of two Docker containers based on the latest version of the ALPINE image. These containers are on the same virtual Docker network.

Using the ```dockerfile``` the ALPINE image was modified to suit our needs:

* Updating default packages
* Adding :
    * **gnupg** for PGP key creation, file encryption, and decryption
    * **openssh-client/openssh-server** to enable file transfers
    * **zip/unzip** for file compression if needed (not used)
    * **sudo** for executing commands as different users
    * **openrc** for service management (SSHD)
    * **sshpass** to pass SSH passwords as parameters
        _Note: The use of sshpass is discouraged for security reasons. However, in our use case, we need to pass the SSH password as a parameter for the connection between the two containers. It is advised not to use this method in production and to use SSH keys instead._
_
    * **vim** for editing configuration files
* Creating a  **pgpuser** user for managing PGP keys
* Creating a **sshuser** user for SSH connections between the two containers
* Creating a **depot** group for managing permissions on the file deposit area
* Creating a **depot** directory for the file deposit area, with permission management

## Configuration

It is possible to modify:
* The password for the **sshuser** user in the ```dockerfile```. This value could be stored in an Ansible vault.

* The PGP key information in the ```/script/keygen.sh``` file:
    * USER_NAME
    * USER_HOME
    * KEY_NAME
    * KEY_COMMENT
    * KEY_EMAIL
    * KEY_TYPE
    * KEY_LENGTH
    * KEY_EXPIRE
    * KEY_PASSPHRASE

## Usage

To build the two containers, run the following command:

```bash
docker build -t alpine_server .
```

To start and stop the two containers, simply run the following commands:

```bash
docker-compose -f compose.yml up -d
docker-compose -f compose.yml down
```

To connect to the **server1** container :
```bash
docker exec -it server1 /bin/sh
```

To connect to the **server2** container :
```bash
docker exec -it server2 /bin/sh
```

You also need to start the SSHD service on both containers:
```bash
rc-status
rc-service sshd start
```
_This step could have been automated during container startup._

## Initialization
### Server 1

1. Generate PGP keys on the **server1** container by running the script ```/script/keygen.sh```. This script makes the public key available at the following location: ```$USER_HOME/public_key.asc```, which corresponds to ```/home/pgpuser/public_key.asc``` by default.

Example :
```bash
sh /app/scripts/keygen.sh
```

2. Copy the public key from the **server1** container to the **server2** container using the script ```/script/keytransfert.sh```. This script uses the scp command to copy the public key from the **server1** container to the **server2** container at the location ```/home/sshuser/public_key_$(HOSTNAME).asc```. This script requires the hostname and the SSH Password of the **server2** container as parameters.

Example :
```bash
sh /app/scripts/keytransfert.sh 436189dc0a90 sshpassword
```

3. Import the **server1** container's public key into the **server2** container using the script ```/script/keyimport.sh```. This script imports the **server1** container's public key into the **server2** container. The user is then prompted to enter the key ID to allow signing and setting the trust level (5).

Example :
```bash
sh /app/scripts/keyimport.sh
```
It is possible to check the imported keys using the script :
```bash
sh /app/scripts/keycheck.sh
```

### Server 2

1. Generate PGP keys on the **server2** container by running the script ```/script/keygen.sh```. This script makes the public key available at the following location: ```$USER_HOME/public_key.asc```, which corresponds to ```/home/pgpuser/public_key.asc``` by default.

Example :
```bash
sh /app/scripts/keygen.sh
```

2. Copy the public key from the **server2** container to the **server1** container using the script ```/script/keytransfert.sh```. This script uses the scp command to copy the public key from the **server2** container to the **server1** container at the location ```/home/sshuser/public_key_$(HOSTNAME).asc```.

Example :
```bash
sh /app/scripts/keytransfert.sh 0adbe442875e sshpassword
```

3. Import the **server2** container's public key into the **server1** container using the script ```/script/keyimport.sh```. This script imports the **server2** container's public key into the **server1** container. The user is then prompted to enter the key ID to allow signing and setting the trust level (5).

Example :
```bash
sh /app/scripts/keyimport.sh
```

## File Transfer

After initializing the PGP keys, files can be transferred between the two containers. To do this, follow these steps:

### From Server 1 to Server 2

1. Create or deposit ```.txt``` files in the server1 deposit area ```(/app/depot)```.
2. Encrypt the files using the script ```/script/fileencrypt.sh``` on **server1**. This script encrypts the files located in the ```/app/depot``` directory. It requires the email of the recipient's public key as a parameter.

Example :
```bash
sh /app/scripts/fileencrypt.sh pgpuser@8355ed50b4e9
```

3. Transfer the encrypted files from **server1** to **server2** using the script ```/script/filetransfert.sh```. This script uses the scp command to copy the encrypted files from **server1** to **server2** at the location ```/app/depot```. This script requires the recipient's hostname and SSH password as parameters. It would have been better to use SSH keys. After the transfer, the encrypted files are archived in the ```/app/depot/archive``` directory.

Example :
```bash
sh /app/scripts/filetransfert.sh 436189dc0a90 sshpassword
```

4. Decrypt the files on **server2** using the script ```/script/filedecrypt.sh```. This script decrypts the files located in the ```/app/depot``` directory. It does not require any parameters. If the correct key was used for encryption, there will be no prompt for the passphrase, and the decrypted files will be available in the ```/app/depot/``` directory on **server2**.

Example :
```bash
sh /app/scripts/filedecrypt.sh
```

**It is posible to encouter the following error :**
When trying to decrypt the file, you may encounter the prompt Enter passphrase. Just enter the passphrase one time and the script will continue and the prompt will not appear again.

### From Server 2 to Server 1

The actions are the same as for the transfer from **server1** to **server2**, but in reverse. You need to change the hostname, passwords, and targeted PGP keys.


## Improvements

* Use SSH keys for the connection between the two containers
* Automate the management of SSHD services
* ???

## Conclusion
In conclusion, this project provides a bidirectional multi-file transfer solution between two Docker containers with encryption via PGP key. By following the steps outlined in the README, you can set up the necessary configurations and initialize the PGP keys on both server1 and server2. Once the keys are initialized, you can easily transfer files between the two containers using the provided scripts. The encryption and decryption processes ensure the security of the transferred files.