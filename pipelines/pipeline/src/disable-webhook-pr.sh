#!/usr/bin/env bash

##
# This script removes the "pull_request" event from a given webhook.
##
hook_url=$1
token=$2

echo "{\"remove_events\": [\"pull_request\"]}" | \
  curl -s -X PATCH -H "Authorization: token $token" "$hook_url" --data @- > /dev/null
