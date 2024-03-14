#!/bin/bash

# En este ejercicio hay una peticion a un link que graba la imagen en un archivo.
# Falta un bucle que haga lo mismo por cada url que haya en el archivo results o cualquier otro...

curl -s "${LINK}" --output img/${RANDOM}.jpg
