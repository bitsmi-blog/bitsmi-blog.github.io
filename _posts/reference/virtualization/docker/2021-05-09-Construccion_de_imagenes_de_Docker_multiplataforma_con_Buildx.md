---
author: Antonio Archilla
title: Construcción de imágenes de Docker multiplataforma con Buildx
date: 2021-05-09
categories: [ "references", "virtualization", "docker" ]
tags: [ "docker" ]
layout: post
excerpt_separator: <!--more-->
---

**Docker** proporciona soporte para crear y ejecutar contenedores en una multitud de arquitecturas diferentes, incluyendo **x86**, **ARM**, **PPC** o **Mips** entre otras. Dado que no siempre es posible crear las imágenes correspondientes de arquitectura equivalente por cuestiones de disponibilidad, comodidad o rendimiento, la alternativa de poder crearlas desde un mismo entorno crea interesantes escenarios, como la posibilidad de tener un servicio de integración continua encargado de la creación de todas las variaciones para las diferentes arquitecturas cubiertas por una aplicación.

En este artículo se expone la configuración de la herramienta **buildx** de **Docker** para la creación imágenes de múltiples arquitecturas en un mismo entorno. En el ejemplo incluido se crearán 2 imágenes para las arquitecturas **AMD64** y **ARM64** en un entorno basado en **Ubuntu Linux AMD64**. 
<!--more-->

#### Instalación del entorno de emulación

El proceso empieza con la instalación de los paquetes **QEMU** necesarios. Esto proporcionará un entorno de virtualización y emulación de las diferentes arquitecturas soportadas:

```sh
sudo apt-get install qemu binfmt-support qemu-user-static 
```

Una vez instalados, será necesario ejecutar los *scripts* de registro. Afortunadamente, existen imágenes de **Docker** preconfiguradas para esto que realizan todo el trabajo. Sólo es necesario ejecutar la imagen de la siguiente forma:

```sh
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes 
```

Para comprobar que todo el proceso se ha realizado correctamente, se puede ejecutar una imagen correspondiente a una arquitectura diferente a la del entorno y ver si funciona correctamente. Por ejemplo, si se ejecuta el comando `uname` sobre una imagen de **Ubuntu ARM64**:

```sh
docker run --rm -t arm64v8/ubuntu uname -m
```

La salida del comando mostrará por pantalla la cadena de texto **aarch64**, que indica que la ejecución se ha realizado sobre un sistema **ARM64**.


#### Creación de un Builder

El siguiente paso del proceso es la creación de un **builder** definido como **un perfil de configuración** de **Buildx**. Para ello se ejecutará el comando:

**Create a new builder and set it to default/current**

```sh
docker buildx create --name cross-builder --driver docker-container --use
```

Asignándole el nombre `cross-builder` que servirá para identificarlo posteriormente (se puede especificar un valor a voluntad) y especificando que será el **builder por defecto** mediante la opción `--use`. 

Una vez definido el **builder** se inicializará el entorno mediante la orden `inspect`. Este proceso inicia un nuevo contenedor para **Buildx** y crea los ficheros necesarios para su linealización y ejecución dentro del directorio **.docker**. El comando a ejecutar es el siguiente:

```sh
docker buildx inspect --bootstrap
```

Es posible que durante la inicialización aparezca un error similar al siguiente:

```
> Error: error getting credentials - err: exit status 1, out: `Cannot autolaunch D-Bus without X11 $DISPLAY`
```

Para resolverlo, se deberán instalar los paquetes `pass` and `gnupg2`:

```sh
sudo apt install gnupg2 pass
```

Cuando todo el proceso haya finalizado, se pueden consultar los **builders** registrados mediante el comando `docker buildx ls`. El nuevo **builder** deberá aparecer seleccionado por defecto junto a lista de arquitecturas soportadas.


#### Ejemplo de uso

Para testear el proceso de construcción *multiarquitectura*, se puede crear un **fichero de definición** `Dockerfile` simple como el siguiente. 

Para simplificar el ejemplo, la imagen base utilizada `jitesoft/alpine` es ya multiplataforma, por lo que no es necesario utilizar diferentes imágenes de base para las diferentes arquitecturas a tratar.

```
FROM jitesoft/alpine
RUN apk add --no-cache curl

ENTRYPOINT ["curl"]
CMD ["--version"]
```

Para generar las imágenes mediante **Buildx** se deberá ejecutar el comando expuesto a continuación. 

Cabe destacar la utilización de la opción `--platform=linux/arm64` para especificar la arquitectura correspondiente a la imagen generada y al uso de `--load` para cargarla en el registro de **Docker** local. En este ejemplo se ha etiquetado la imagen con el nombre `bitsmi/curl-sample:1.0.0` para su posterior identificación.

```sh
docker buildx build --platform=linux/arm64 -t bitsmi/curl-sample:1.0.0 --load .
```

En caso de disponer de un registro remoto donde ubicar las imágenes, es posible generar múltiples artefactos en un sólo comando especificándolas en la opción `--platform` separadas mediante comas y usando la opción `--push` con la dirección del registro. Esto no es posible si se usa la opción `--load` para cargarlas en el registro local.

```sh
docker buildx build --platform=linux/amd64,linux/arm64 --push -t registro.foo.bar:5000/bitsmi/curl-sample:1.0.0 . 
```

Una vez generada la imagen y cargada en el registro local, se puede ejecutar mediante el comando:

```sh
docker run -ti bitsmi/curl-sample:1.0.0
```

Para este ejemplo, tras su ejecución aparecerá por pantalla un mensaje de texto como el siguiente, indicando que la imagen **ARM64** se ha ejecutado en un *host* **AMD64**

```
WARNING: The requested image's platform (linux/arm64) does not match the detected host platform (linux/amd64) and no specific platform was requested
```
