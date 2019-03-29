#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
cd ${SCRIPTPATH}/js

if [[ $# -ne 4 ]] ; then
    echo "USAGE: $0 USER_NAME USER_POOL_ID USER_POOL_CLIENT_ID REGION"
    exit 0
fi

echo "Enter the temporary password received by mail: "
read -s old_pass

echo "Enter the new password (password must contain all: >8 chars, Uppercase, lowercase, numbers, special chars): "
read -s new_pass



export USER_CURRENT_PASSWORD=$old_pass
export USER_NEW_PASSWORD=$new_pass
export USER_NAME=$1
export USER_POOL_ID=$2
export USER_POOL_CLIENT_ID=$3
export AWS_REGION=$4

node userChangePassword.js
