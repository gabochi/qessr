# QESsr
Tutorial mínimo para hacer QA automático de APIs usando git, docker, curl, jq y bash

## requerimientos

### primarios
+ docker

### secundarios
+ git
+ cuenta de github

## git y github
Git es el programa con el que vamos a administrar cambios y versiones de nuestro repositorio.
GitHub es una plataforma de alojamiento de repositorios.
Para arrancar basta con clonar este repositorio donde quieras:
```bash
git https://github.com/gabochi/qessr.git
```

## Docker
Docker sirve para trabajar en contenedores.
Los contenedores son ambientes que configuramos para que nuestros programas corran en cualquier lado.

### Descargando una imagen
Podemos empezar descargando una imagen docker de debian, va a ser la base de nuestro ambiente.
```bash
docker pull debian
```
Podemos ver todas las imágenes que descargamos de este modo:
```bash
docker images
```

### Corriendo un contenedor
Ahora podemos correr todas las instancias que queramos de esta base.
Vamos a ejecutar una instancia con bash.
```bash
docker run -it debian bash
```

### Trabajando dentro del contenedor
Listo, ahora estamos adentro. Para nuestro pequeño experimento vamos a necesitar descargar algunos programitas dentro.
Primero actualizamos los repositorios de debian.
```bash
apt update
```
Ahora instalamos los programas que vamos a usar desde esos repositorios.
```bash
apt install -y git curl jq jp2a nano
```

## API
Las pruebas que realizaremos van a ser con esta API:

<https://trace.moe/>

Acá hay más documentación de todo lo que se puede hacer con ella:

<https://soruly.github.io/trace.moe-api/#/docs>

## curl
Curl es fundamental para todo esto, es el programa con el que vamos a realizar peticiones.
Hagamos una primera petición para ver qué nos dice...
```bash
curl "https://api.trace.moe/search?url=https://images.plurk.com/32B15UXxymfSMwKGTObY5e.jpg"
```
La primera parte de la petición es la dirección de la API, luego tenemos el path `/search` y finalmente le especificamos una dirección donde está alojada la imagen que queremos saber qué es `?url=...`.

## jq
Una buena herramienta para procesar las respuestas de nuestras peticiones es jq. Generalmente, las APIs responden en formato JSON.  Con jq podemos parsear la respuesta y realizar distintas extracciones.
```bash
curl "https://api.trace.moe/search?url=https://images.plurk.com/32B15UXxymfSMwKGTObY5e.jpg" | jq 
```
Acabamos de *redireccionar* la salida del primer comando hacia el segundo, en este caso jq. El resultado es una respuesta más legible.

### parseando
Pero lo mejor de jq no es volver más legible una respuesta sino procesarla. Con el siguiente comando extraemos solamente lo que está dentro de `result`.
```bash
curl "https://api.trace.moe/search?url=https://images.plurk.com/32B15UXxymfSMwKGTObY5e.jpg" | jq .result
```

Como vemos, es una lista de muchos resultados. Podemos especificar un índice para extraer solamente la que nos interesa.
```bash
curl "https://api.trace.moe/search?url=https://images.plurk.com/32B15UXxymfSMwKGTObY5e.jpg" | jq .result[0]
```

También podemos extraer el campo que nos interesa de todos los elementos de la lista.
```bash
curl "https://api.trace.moe/search?url=https://images.plurk.com/32B15UXxymfSMwKGTObY5e.jpg" | jq .result[].image
```

## output to file
El contenido del campo image es una url de la imagen que estima similar a la que le dimos (y un token para poder acceder `?token=...` entre otras cosas.
Podemos copiar la url en nuestro navegador para efectivamente acceder a la misma pero también podemos descargarla en un archivo usando curl.
```bash
curl "https://api.trace.moe/image/15883/%5BMabors%20Sub%5DFantasista%20Doll%20-%2012%5BBIG5%5D%5B720P%5D%5BPSV%26PC%5D.mp4.jpg?t=574.71&now=1710306000&token=IjLSRNaa6PPA6NhXsopunV9Xc" --output file.jpg
```

## upload file
Esta API está buenísima, también podemos darle un archivo de imagen que tengamos guardado en vez de una url.
```bash
curl --data-binary "@file.jpg" https://api.trace.moe/search
```

## jp2a
Pero el navegador no está dentro de nuestro contenedor. Solamente por diversión, imaginemos que no podemos salir del contenedor. ¿Cómo podemos visualizar una imagen?
```bash
jp2a file.jpg
```

## más direccionamientos
En bash no solamente podemos redireccionar la salida de un comando a otro comando, también podemos hacerlo a un archivo.
Con el siguiente comando extraemos las urls de imágenes en la respuesta a nuestra petición, les borramos las comillas y grabamos todo en un archivo que llamamos "urls".
```bash
curl "https://api.trace.moe/search?url=https://images.plurk.com/32B15UXxymfSMwKGTObY5e.jpg" | jq .result[].image | tr -d '"' > urls
```
Con cat podemos ver el contenido de nuestro nuevo archivo.
```bash
cat urls
```

## primer script, automatizacion!
Bueno, llego la hora. Supongamos que tenemos un archivo con mil urls y queremos realizar peticiones a la API con cada una. Hacerlo a mano sería lento y aburrido.  
No hay problema, para eso existen las computadoras y es lo que diferencia a un QE pete de uno crack. Copiá y pegá este script en el bash del contenedor y dale enter.
```bash
for ARCHIVO in $(ls)
	do echo aqui se encuentra el archivo $ARCHIVO
done
```
Lo que acabamos de hacer es un bucle de iteración.  Dicho en criollo, un programa que ejecuta una acción por cada elemento de una lista.
La lista es el resultado del comando `ls`, que son los nombres de los archivos en nuestro directorio.  
La acción que realizamos por cada archivo es simplemente imprimir "aqui se encuentra el archivo ..." y a continuación el nombre de cada archivo, uno por uno.

### nano
Escribir un script directamente desde la línea de comando es hardcore, si querés ser re hacker re pulenta lo podés hacer.  Pero para que no te mates ya tenés instalado nano.
Nano es un editor re básico. Con este comando creás un archivo nuevo, para guardarlo usá *CONTROL+S* y para salir *CONTROL+X*.
```bash
nano automatizacion.sh
```
Ahora pegá este script, guardalo y salí. Para ejecutarlo escribí `bash automatizacion.sh`
```bash
for LINE in $(cat urls)
do 
	curl -s $LINE --output file.jpg
	clear
	jp2a file.jpg
	echo Presione ENTER para continuar
	read
done
```
Ahora la lista sobre la que vamos iterando es el comando `cat urls`, que imprime una por una las líneas del archivo "urls". 
¿Podés deducir cuál es la acción que realizamos por cada elemento de esta lista?

## errores
Usemos otro campo de la respuesta de la API. Como vamos a testear, seguramente nos sirva el campo "error".
De paso aprendamos algunas cosas.
```bash
API="https://api.trace.moe/search?url="
```
Con esto de arriba guardamos la parte que no cambia de una petición en una variable llamada "API"
Ahora podemos realizar una petición simplemente invocando a la variable y pegando a continuación la url de una imagen.
```bash
curl "${API}https://images.plurk.com/32B15UXxymfSMwKGTObY5e.jpg"
```
Vamos a extraer solamente el campo error.
```bash
curl "${API}https://images.plurk.com/32B15UXxymfSMwKGTObY5e.jpg | jq .error"
```
Nos muestra `""`, o sea, digamos, está vacío el campo porque no hubo ningún error.
Lo mejor de ser tester no es encontrar sino GENERAR un error:
```bash
curl "${API}https://una.pagina.que.no.existe.com/el_secreto_de_la_vida.jpg | jq .error"
```
Suficiente por el momento, salí del contenedor escribiendo `exit` o pulsando *CONTROL+D*.

---

## Dockerfile troll
Me olvidaba de contarte, acabás de perder todo lo que hiciste porque los contenedores no son persistentes, lo que hagas adentro muere con la instancia.
Así que lo que hacen los testers que quieren automatizar es configurar ambientes todos los días.
Nah, mentira. En este repo te dejé un archivo *Dockerfile* que tiene todo lo que quieren las huachas.
Miralo y vas a ver que hace exactamente lo mismo que hicimos antes, usa una base debian, le instala los programas, etc.
```Dockerfile
FROM debian:latest

RUN apt update
RUN apt -y install git curl jq jp2a nano

ENTRYPOINT bash
```

Podés crear una imagen nueva a partir del Dockerfile ejecutando esto en el directorio donde se encuentre:
```bash
docker build . -t qessr
```
Hermoso, ahora tenés una nueva imagen que bauticé "qessr".  Confirmalo listando las imágenes que tenés disponibles ahora.
```bash
docker images
```

## Volúmenes
Corré la imagen nueva.
```bash
docker run -it -v ./app:/app qessr
```
Pero con este comando acabamos de hacer algo muy cheto. Acabamos de crear un volumen, o sea, una carpeta compartida entre el contenedor y tu compu!
Ojo, no la cagues, es de lectoescritura, lo que hagas con los archivos que están adentro pasa con los que están afuera.
Ahora el directorio `app` está adentro y afuera del contenedor. Si entrás vas a encontrar muchas cosas copadas:

### img/
Podés copiar imágenes en este directorio para buscarlas con la API. En los ejercicios lo vas a necesitar.

### test_urls.sh
Un script que busca errores en una lista de urls: `bash test_urls.sh [ARCHIVO]`

### save_results.sh
un script que guarda una lista de urls del resultado de una petición: `bash save_results.sh [LINK]`

### more_urls
Una lista con un par de animes que me gustan, ¿cuáles son?

### results
La lista de urls que genera save_results.sh

> ## Ejercicios
> En app/ también hay dos ejercicios propuestos, son scripts a medio hacer.
> En el primero tenés el for pero te falta el curl, en el segundo está el curl pero te falta el for.
> **Mucha suerte!!!**

---

## TO DO
Falta que explique un ejercicio final, sería forkear el repo, crear un branch, comitear y pushear los ejercicios resueltos.

```bash
git checkout -b versiones/2.0
```

```bash
git add .
```

```bash
git commit -m "ultimo ejercicio del tutorial"
```

```bash
git push --set-upstream origin versiones/2.0
```
