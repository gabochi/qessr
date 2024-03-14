#!/bin/bash

for LINK in $(cat results)
do
	echo descargando ${LINK}
	curl -s "${LINK}" --output img/${RANDOM}.jpg
done

echo "listo ;)"
