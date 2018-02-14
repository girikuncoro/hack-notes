#!/bin/bash

# Pre-requisite: SSH with public/private key
#     ssh       ssh
# A ------> B ------> C
#     ^          ^
#  using A's   using A's
#  ssh key     ssh key
#
# where A: MacBook, B: Jumphost, C: Opsman VM
# From Macbookt: 
# $ ssh-keygen -t rsa
# $ cat ~/.ssh/id_rsa.pub | ssh kubo@<JUMPHOST-IP> 'cat >> .ssh/authorized_keys'
# $ scp ~/.ssh/id_rsa.pub kubo@<JUMPHOST-IP>:
# 
# From Jumphost:
# SSH to ubuntu@<REMOTE-SERVER> and enable root SSH access (vi /etc/ssh/sshd_config, edit PermitRootLogin, DenyUsers, and AllowGroups)
# $ cat ./id_rsa.pub | ssh root@<REMOTE-SERVER> 'cat >> .ssh/authorized_keys'

# Hack for deploying bosh release changes faster to remote testbed
VERSION=${1}
FILE_PREFIX=${2}
JUMPHOST_IP=${3}
FILE_NAME=$FILE_PREFIX-$VERSION.tgz

JUMPHOST=kubo@$JUMPHOST_IP
REMOTE_SERVER=root@30.0.0.5
REMOTE_DESTINATION=/var/tempest/releases
OWNER=tempest-web

bosh create-release --force --version $VERSION --tarball $FILE_NAME

scp -oProxyJump=$JUMPHOST $FILE_NAME $REMOTE_SERVER:$REMOTE_DESTINATION

FILE_PATH=$REMOTE_DESTINATION/$FILE_NAME
ssh -t -oProxyJump=$JUMPHOST $REMOTE_SERVER "sudo chown $OWNER:$OWNER $FILE_PATH;"

echo "$FILE_NAME has been uploaded to remote server"
