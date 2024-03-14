#!/bin/bash

SRC=$1
API="https://api.trace.moe/search?url="

[ -f "$SRC" ] || exit

echo "testing"

for LINE in $(cat $SRC)
do
	echo -n ...
	curl -s "${API}${LINE}" \
	| jq .error \
	| grep -v '""'
done

echo "done :)"
