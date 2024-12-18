#!/bin/bash

# Get the list of windows with their workspace numbers
wmctrl -lG | awk '{
  printf "{ \"id\": \"%s\", \"desktop\": \"%d\", \"x\": \"%d\", \"y\": \"%d\", \"width\": \"%d\", \"height\": \"%d\", \"host\": \"%s\", \"title\": \"%s\" }\n",
    $1, $2, $3, $4, $5, $6, $7, substr($0, index($0, $8))
}' | jq -s . > workspace_info.json

echo "Workspace information saved to workspace_info.json"
