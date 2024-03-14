#!/bin/bash

LINK=$1
API="https://api.trace.moe/search?url="

curl -s "${API}${LINK}" | jq .result[].image | tr -d '"' | tee results
