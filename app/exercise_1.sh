#!/bin/bash

# En este ejercicio hay un bucle que recorre todos los archivos en la carpeta img/
# Lo que falta es la peticion a la API por cada uno.

for FILE in $(ls img/)
do
	echo me gustaria saber de que anime es la imagen ${FILE}
done

