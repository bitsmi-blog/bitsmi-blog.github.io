---
author: Antonio Archilla
title: Docker - Referencia de comandos
date: 2024-10-20
categories: [ "references", "virtualization", "docker" ]
tags: [ "docker" ]
layout: post
excerpt_separator: <!--more-->
---

<!--more-->

NOTE: WORK IN PROGRESS

## Índice

* [Operaciones con imágenes](#operaciones-con-imagenes)
	* [Listar imágenes locales](#listar-imagenes)
	* [Crear una imagen a partir de un Dockerfile](#crear-imagen-dockerfile)
	* [Inspeccionar la definición de una imagen](#inspeccionar-imagen)
* [Operaciones con contenedores](#operaciones-con-contenedores)
	* [Crear un contenedor](#crear-contenedor)
	* [Borrar contenedor](#borrar-contenedor)
	* [Modificar la configuración de un contenedor](#modificar-configuracion-contenedor)
	* [Listar *Stats* de un contenedores en funcionamiento](#stats-contenedores)
	* [Parar un contenedor en funcionamiento](#parar-contenedor)
	* [Ejecutar un comando en un contenedor](#ejecutar-comando-en-contenedor)
	* [Ejecutar shell en un contenedor](#ejecutar-shell-en-contenedor)
* [Ejecución de servicios con Docker-Compose](#docker-compose)


## Operaciones con imágenes ## {#operaciones-con-imagenes}

#### Listar imágenes locales #### {#listar-imagenes}

Este comando proporcionará, entre otros datos, el ID de las imágenes (`IMAGE ID`) descargadas en el entorno local que se utilizará para referenciar dichas imágenes en otras operativas.

```sh
docker image ls
```

#### Crear una imagen a partir de un Dockerfile #### {#crear-imagen-dockerfile}

```sh
sudo docker image build -t <etiqueta imagen> --build-arg <argumento Dockerfile> <ruta a Dockerfile>
```

Dónde `Argumento Dockerfile`: Corresponde a un elemento de tipo `ARG` del **Dockerfile**. La pareja `--build-arg <argumento>` puede especificarse tantas veces cómo parámetros haya.


Ejemplo:

```sh
sudo docker image build -t "custom/image:1.0.0" --build-arg jar_file="dist/main.jar" .
```



#### Inspeccionar la definición de una imagen #### {#inspeccionar-imagen}

Este comando permitirá inspeccionar la definición de una imagen contenida en el registro local, esto es, su `Dockerfile`.

```sh
docker image inspect <IMAGE ID>
```

Dónde el `IMAGE ID` es el identificador retornado por el comando para el [Listado de imágenes locales](#listar-imagenes)

## Operaciones con contenedores ## {#operaciones-con-contenedores}

#### Listar contenedores #### {#listar-contenedores}

```sh
# Listado de los contenedores en funcionamiento
sudo docker container ls
sudo docker ps

# Listado de todos los contenedores independientemente de su estado
sudo docker container ls --all
```
	
Proporciona información de los contenedores creados en el entorno local que incluye:

* **CONTAINER_ID**: ID del contenedor. Puede utilizarse para referenciar el contenedor en otros comandos
* **IMAGE**: Referencia a la imagen sobre la que se ha creado el contenedor
* **COMMAND**: *Hint* del comando que ejecuta el contenedor
* **CREATED**: Fecha relativa a la creación del contenedor
* **STATUS**: Estado actual del contenedor. Indica si se encuantra en funcionamiento, parado, con errores, etc.
* **PORTS**: Puertos expuestos por el contenedor y su correspondencia con el puerto del host
* **NAMES**: Nombre asignado al contenedor. Puede utilizarse en lugar del `CONTAINER_ID` para referenciar el contenedor en otros comandos
	
#### Crear un contenedor #### {#crear-contenedor}

```sh
# En 1 paso
sudo docker run -v <mapeo volumes> -p <mapeo puerto> --name <nombre container> <nombre imagen> 

# En 2 pasos
sudo docker container create -v <mapeo volumes> -p <mapeo puerto> --name <nombre container> <nombre imagen> 
sudo docker container start <container_name or container_id>
```

Dónde el `nombre` o `id` del contenedor son valores retornados por el comando para el [Listado de contenedores](#listar-contenedores)

Ejemplo:

```sh
# En 1 paso
sudo docker run -v /home/vagrant/prometheus/conf:/etc/prometheus -p 9090:9090 --name prometheus prom/prometheus:v2.17.2

# En 2 pasos
sudo docker container create -v /home/vagrant/prometheus/conf:/etc/prometheus -p 9090:9090 --name prometheus prom/prometheus:v2.17.2 
sudo docker container start prometheus
```
	
#### Borrar contenedor #### {#borrar-contenedor}

```sh
sudo docker rm <nombre o id contenedor>
```

Dónde el `nombre` o `id` del contenedor son valores retornados por el comando para el [Listado de contenedores](#listar-contenedores)

#### Modificar la configuración de un contenedor #### {#modificar-configuracion-contenedor}

**Modificar política de reinicio**

```sh
sudo docker container update --restart <policy> <nombre o id contenedor>
```

Donde: 
* `nombre` o `id` del contenedor son valores retornados por el comando para el [Listado de contenedores](#listar-contenedores)
* `policy`: Indica la política de reinicio y puede tomar los valores 
	* `no`: (*Default*) No reicniar el contenedor automáticamente
	* `on-failure`: Reiniciar el contenedor si anteriormente finalizado con error (Devuelve un código != 0)
	* `always`: Reiniciar el contendor siempre. Si el contenedor se ha parado manualmente, se reiniciará sólo cuando el *daemon* de Docker se reinicie 
	(Reinicio del sistema o reinicio manual del *daemon*)
	* `unless-stopped`: Similar a `always` excepto que no se reinicia cuando el contenedor ha sido parado manualmente 	

#### Listar *Stats* de un contenedores en funcionamiento #### {#stats-contenedores}

Proporciona información sobre el consumo de recursos de los contenedores en funcionamiento

```sh
sudo docker stats
```
	
#### Parar un contenedor en funcionamiento #### {#parar-contenedor}

```sh
sudo docker stop <nombre o id contenedor>
```
	
Dónde el `nombre` o `id` del contenedor son valores retornados por el comando para el [Listado de contenedores](#listar-contenedores)	

#### Ejecutar un comando en un contenedor #### {#ejecutar-comando-en-contenedor}

**NOTA**: El comando debe estar disponible dentro del contenedor

```sh
sudo docker exec -t <nombre o id contenedor> <comando>
```

Dónde el `nombre` o `id` del contenedor son valores retornados por el comando para el [Listado de contenedores](#listar-contenedores)	

Por ejemplo, para listar el contenido de un fichero ubicado dentro de contenedor:

```sh
sudo docker exec -t grafana_loki_1 cat /etc/loki/local-config.yaml
```


#### Ejecutar shell en un contenedor #### {#ejecutar-shell-en-contenedor}

```sh
sudo docker exec -it <nombre o id contenedor> /bin/sh
```

Dónde el `nombre` o `id` del contenedor son valores retornados por el comando para el [Listado de contenedores](#listar-contenedores)	

## Ejecución de servicios con Docker-Compose ## {#docker-compose}

WIP