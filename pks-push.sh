#!/bin/bash -ex

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
OLD_VERSION=${1}
NEW_VERSION=${2}
OLD_PKG=pks-nsx-t-$OLD_VERSION.tgz
NEW_PKG=pks-nsx-t-$NEW_VERSION.tgz
FILE_PREFIX=${3}
JUMPHOST_IP=${4}
REMOTE_SERVER_IP=${5:-30.0.0.5}
TILE_MANIFEST_FILE=${6}
TILE_MANIFEST_PATH=/var/tempest/workspaces/default/metadata/$TILE_MANIFEST_FILE
FILE_NAME=$FILE_PREFIX-$NEW_VERSION.tgz

JUMPHOST=kubo@$JUMPHOST_IP
REMOTE_SERVER=root@$REMOTE_SERVER_IP
REMOTE_DESTINATION=/var/tempest/releases
OWNER=tempest-web

bosh create-release --force --version $NEW_VERSION --tarball $FILE_NAME

scp -oProxyJump=$JUMPHOST $FILE_NAME $REMOTE_SERVER:$REMOTE_DESTINATION

FILE_PATH=$REMOTE_DESTINATION/$FILE_NAME
ssh -t -oProxyJump=$JUMPHOST $REMOTE_SERVER "sudo chown $OWNER:$OWNER $FILE_PATH; sed -i 's/'$OLD_VERSION'/'$NEW_VERSION'/g' $TILE_MANIFEST_PATH; sed -i 's/'$OLD_PKG'/'$NEW_PKG'/g' $TILE_MANIFEST_PATH; grep -A 2 $FILE_PREFIX $TILE_MANIFEST_PATH"

echo "$FILE_NAME has been uploaded to remote server"
rm -r $FILE_PREFIX-*.tgz

if [ "$7" == "apply" ]; then
	echo "Applying changes via opsman"
	ssh $JUMPHOST "om -t $REMOTE_SERVER_IP -u admin -p 'Admin!23' --skip-ssl-validation apply-changes"
fi
