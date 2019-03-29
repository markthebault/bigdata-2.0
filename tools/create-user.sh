#!/bin/bash


if [[ $# -ne 5 ]] ; then
    echo "USAGE: $0 AWS_REGION USER_POOL_ID USERNAME GROUP_NAME EMAIL"
    exit 0
fi

USER_POOL_ID=$2
USERNAME=$3
GROUP_NAME=$4
EMAIL=$5
REGION=$1

aws cognito-idp admin-create-user \
    --region $REGION \
    --user-pool-id $USER_POOL_ID \
    --username $USERNAME \
    --user-attributes '[{"Name":"email","Value":"'${EMAIL}'"},{"Name":"custom:acl","Value":"1,2"}]'

aws cognito-idp admin-add-user-to-group \
    --region $REGION \
    --user-pool-id $USER_POOL_ID \
    --username $USERNAME \
    --group-name $GROUP_NAME