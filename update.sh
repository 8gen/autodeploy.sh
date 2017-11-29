#!/bin/bash

export GIT_SSH_COMMAND='ssh -i ~/.ssh/id_ecdsa'

. /usr/local/lib/update_lib.sh

ID=iconic.vc
REPO_ROOT=/sites/iconic.vc/repo
DEPLOY_ROOT=/sites/iconic.vc/default
NAME="ICOnic.vc Front"
URL=http://iconic.vc/
CHANNEL_ID=-1232131232321
BUILD_SUBDIR=build

update ${ID} ${REPO_ROOT} ${DEPLOY_ROOT} "${NAME}" ${URL} ${CHANNEL_ID} ${BUILD_SUBDIR}
