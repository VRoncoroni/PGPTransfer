# PGPTransfer CENTOS 6.5 / REDHAT 6.5
Description of setting up a bidirectional multi-file transfer between two vm (CENTOS 6.5/ REDHAT 6.5) with encryption via PGP key

## Prerequisites

* Hyper V
* CENTOS 6.5 / Red Hat 6.5

## Architecture

The architecture of this project consists of two VM based on CENTOS 6.5. These VM are on the same virtual network (DEFAULT SWITCH).

## Configuration

* Start SSHD service on both VM with the root user:
```bash
service sshd start
```
* Create a app user on both VM:
```bash
useradd appuser
```

## Generation of PGP keys and export of the public key

On each VM, generate a PGP key with the appuser user with the following command:
```bash
gpg #this will generate the .gnupg directory
quit
```

Then, create a script to generate the PGP key:

```bash
vi keygen.sh
```
Content of the script:
```bash
gpg --batch --gen-key <<EOF
%echo Generating a default key
Key-Type: 1
Key-Length: 2048
Name-Real: TestA
Name-Comment: Test Key A
Name-Email: testuserA@example.com
Expire-Date: 2y
%commit
%echo Done
EOF
```
If necessary, modify the script to suit your needs. (passphrase, key length, etc.)

With root, give the right to execute the script:
```bash
chmod 777 keygen.sh
```

With the appuser, execute the script:
```bash
./keygen.sh
```

This will generate a PGP keys for the appuser user.

To export the public key, use the following command:
```bash
gpg --armor --export TestA > ~/public_key_A.asc
```
## Import the public key

Copy the public key from VM A to VM B and vice versa with the following command:
```bash
scp ~/public_key_A.asc appuser@VM_B_IP:~/public_key_A.asc # from VM A to VM B
scp ~/public_key_B.asc appuser@VM_A_IP:~/public_key_B.asc # from VM B to VM A
```
Make sure to replace the IP addresses and the name of the public key and to give the right to read the file to the appuser user.

Then, import the public key with the following command:
### VM A
```bash
gpg --import ~/public_key_B.asc
gpg --sign-key TestB
gpg --edit-key TestB
trust
5
o
quit
```

### VM B
```bash
gpg --import ~/public_key_A.asc
gpg --sign-key TestA
gpg --edit-key TestA
trust
5
o
quit
```

## File transfer
Make sure that the appuser user has the right to write in the home directory.

### From VM A to VM B

* Create a ```.txt``` files in the VM A.
* Encrypt the files with the following command:
```bash
gpg --batch --yes --encrypt --armor --recipient TestB file.txt
# this will generate a file.txt.asc
```
* Transfer the encrypted file to VM B with the following command:
```bash
scp file.txt.asc appuser@VM_B_IP:~/file.txt.asc
```
* Delete the file.txt.asc and the file.txt in VM A.

### From VM B to VM A

* Decrypt the file with the following command:
```bash
gpg --decrypt file.txt.asc > file.txt
```
* Delete the file.txt.asc and open the file.txt to check/modifiy the content with vi.
* Encrypt the file with the following command:
```bash
gpg --batch --yes --encrypt --armor --recipient TestA file.txt
# this will generate a file.txt.asc
```
* Transfer the encrypted file to VM A with the following command:
```bash
scp file.txt.asc appuser@VM_A_IP:~/file.txt.asc
```
* Delete the file.txt.asc and the file.txt in VM B.

Then you can repeat the process as many times as you want.

## Conclusion

This project allows you to transfer files between two VM with encryption via PGP key. It is a simple way to secure your data during the transfer.

# The S.gpg-agent error on CentOS 6.5

With a other user than root, you may encounter the following error if you try to directly use the gpg command: ```bash gpg --gen-key```

```bash
can't connect to `/appuser/.gnupg/S.gpg-agent': No such file or directory
```
It seems that the user is experiencing an issue where they don't have the necessary permissions to access the pinentry program. To resolve this problem, you can try using a script like the following:

```bash
gpg --batch --gen-key <<EOF
%echo Generating a default key
Key-Type: 1
Key-Length: 2048
Name-Real: TestA
Name-Comment: Test Key A
Name-Email: testuserA@example.com
Expire-Date: 2y
%commit
%echo Done
EOF
```

What is pineentry? It is a small utility that is used to prompt the user for a passphrase when using GnuPG. It is a separate program from GnuPG, and it is used to securely prompt the user for their passphrase. The error message you are seeing is because GnuPG is trying to use pinentry to prompt you for your passphrase, but it is unable to find the pinentry program.
