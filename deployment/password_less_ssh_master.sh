#!/bin/bash

#exit if any command fails
set -e

echo "Generating RSA Key for authentication"
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

echo "raspberry">~/passwd.txt
echo "copying rsa key to the nodes"
sshpass -p raspberry ssh -o StrictHostKeyChecking=no pi@node01 "exit"
sshpass -p raspberry ssh-copy-id pi@node01
sshpass -p raspberry ssh -o StrictHostKeyChecking=no pi@node02 "exit"
sshpass -p raspberry ssh-copy-id pi@node02
