#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
cd $SCRIPTPATH
terraform output -json | jq '[. | to_entries[] | {"key": .key, "value": .value.value}] | from_entries'
