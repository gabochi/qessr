#!/bin/bash

# este comando descarga la url almacenada en la variable LINK a un archivo con nombre aleatorio
# hace falta armar un bucle que itere sobre todas las urls del archivo results, mucha suerte!
curl -s "${LINK}" --output img/${RANDOM}.jpg
