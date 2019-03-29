#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
cd ${SCRIPTPATH}/js

if [[ $# -ne 4 ]] ; then
    echo "USAGE: $0 USER_NAME USER_POOL_ID USER_POOL_CLIENT_ID REGION"
    exit 0
fi


echo "Enter the user password: "
read -s new_pass



export USER_PASSWORD=$new_pass
export USER_NAME=$1
export USER_POOL_ID=$2
export USER_POOL_CLIENT_ID=$3
export AWS_REGION=$4

node userAuthenticate.js
