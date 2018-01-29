#!/bin/bash

# Hack for deploying bosh release changes faster to remote testbed
VERSION=${1}
FILE_PREFIX=${2}
JUMPHOST_IP=${3}
FILE_NAME=$FILE_PREFIX-$VERSION.tgz

JUMPHOST=kubo@$JUMPHOST_IP
REMOTE_SERVER=ubuntu@30.0.0.5
REMOTE_DESTINATION=/var/tempest/releases
OWNER=tempest-web

bosh create-release --force --version $VERSION --tarball $FILE_NAME

scp -oProxyJump=$JUMPHOST $FILE_NAME $REMOTE_SERVER:

FILE_PATH=$REMOTE_DESTINATION/$FILE_NAME
ssh -t -oProxyJump=$JUMPHOST $REMOTE_SERVER "sudo mv /home/ubuntu/$FILE_NAME $FILE_PATH; sudo chown $OWNER $FILE_PATH; sudo chgrp $OWNER $FILE_PATH"
