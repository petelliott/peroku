#!/usr/bin/env bash

PEROKU=$1
PROJECT=$2
RULE=$3
DATA=$(tar -zc . | base64 -w 0)

PAYLOAD="{\"project\": \"$PROJECT\", \"rule\": \"$RULE\", \"data\": \"$DATA\"}"

curl -H "Content-Type: application/json" \
    -H "Authorization: Bearer $PEROKU_TOK" \
  -X POST \
  --data "$PAYLOAD" \
  $PEROKU/run

# to prevent missing newline from curl
echo
