---
author: Antonio Archilla
title: Ubuntu - Referencia de comandos útiles
date: 2024-10-20
categories: [ "references", "system", "ubuntu" ]
tags: [ "ubuntu" ]
layout: post
excerpt_separator: <!--more-->
---

* [Fechas y localización](#fechas-y-localizacion)
	* [Consulta de la zona horaria actual del sistema](#consulta-zona-horaria)
	* [Modificar zona horaria del sistema](#modificar-zona-horaria)
	* [Modificar el *layout* de teclado](#consulta-layout-teclado)
* [Logs](#logs)
* [Sistema de ficheros](#sistema-ficheros)
	* [Búsqueda de una cadena dentro de ficheros](##busqueda-cadena-en-ficheros)
	* [Consulta de directorios *top consumers* de espacio en disco](##consulta-top-consumers)
	* [Comprobación de permisos sobre un fichero para un usuario especifico](#comprobacion-permisos-fichero-para-usuario)
	* [Copia remota de ficheros](#copia-remota-de-ficheros)
* [Servicios](#servicios)
	* [Ejecución de servicios](#ejecucion-servicios)
	* [Consultas sobre servicios](#consulta-servicios)


## Fechas y localización ## {#fechas-y-localizacion}

#### Consulta de la zona horaria actual del sistema #### {#consulta-zona-horaria}

```sh
cat /etc/timezone
```

#### Modificar zona horaria del sistema #### {#modificar-zona-horaria}

Bajo el directorio `/usr/shar/zoneinfo` se encuentran los descriptores de las zonas horarias. Para cambiar la zona horaria actual, se debe 
modificar el descriptor al que apunta el *link* `/etc/localtime` utilizando un ***soft link***. Por ejemplo, si se desea especificar la zona
`Europe/Madrid` se hará de la siguiente manera.

```sh
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
```

#### Modificar el *layout* de teclado #### {#consulta-layout-teclado}

###### Sólo para la sesión actual

loadkeys &lt;código [ISO-639-1][ISO-639-1]&gt;

Ejemplo para cambio a *layout* español:

```sh
loadkeys es
```

## Logs ## {#logs}

###### Logs del boot actual

```sh
journalctl -b
```

###### Trazas de *log* de un servicio concreto

```sh
sudo journalctl -u <nombre servicio>
```

## Sistema de ficheros ## {#sistema-ficheros}

#### Busqueda de una cadena dentro de ficheros #### {#busqueda-cadena-en-ficheros}

```sh
find . -type f -print | xargs grep "cadena a buscar"
```


#### Consulta de directorios *top consumers* de espacio en disco #### {#consulta-top-consumers}

```sh
# Top 15
du -xhS | sort -h -r | tail -n15
```

Donde:
* `-x`: Permite ignorar directorios en sistemas de ficheros separados
* `-h`: En el comando `du` muestra el resultado en un formato legible que puede ser ordenado por `sort -h`
* `-S`: En el comando `du` permite excluir el tamaño de los subdirectorios en el computo para un directorio determinado


#### Comprobación de permisos sobre un fichero para un usuario especifico #### {#comprobacion-permisos-fichero-para-usuario}

```sh
sudo -u <usuario> test -[x|w|r] <path al fichero o directorio>
# Obtener el resultado del comando anterior
echo $?
```

Utilizando las opciones `x`, `w` o `r` se podrán probar los permisos de ejecución, escritura y lectura respectivamente. La ejecución del comando `echo $?` es necesaria porque el comando `test` no devuelve un valor visible. De esta manera
se muestra por pantalla el valor de retorno del comando, siendo 0 que el usuario tiene el permiso especificado y cualquier otro valor que no lo tiene.

Ejemplo:

```sh
sudo -u root test -r /etc/systemd/system 
```

El comando `echo $?` devolverá 0 indicando que `root` tiene acceso de lectura al directorio



#### Copia remota de ficheros #### {#copia-remota-de-ficheros}

Copia mediante SCP. Funciona sobre SSH para copiar ficheros entre hosts:

```sh
scp [flags] <origen> <destino>
```

Donde:
- `flags`: Es necesario indicar el flag `-r` para la copia de directorios
- `origen` y `destino`: Indica el fichero / directorio origen y destino. Si se trata de una ubicación remota el formato deberá indicar credenciales, host y ruta en
  formato &lt;credenciales&gt;@&lt;host&gt;:&lt;ruta&gt;

Ejemplo de copia de host remoto a local:

```sh
scp username@hostname:/path/to/remote/file /path/to/local/file
```

Ejemplo de un copia de un directorio de host local a remoto:

```sh
scp -r /path/to/local/folder username@hostname:/path/to/remote/folder
```

Ejemplo de copia de entre hosts:

```sh
scp username1@hostname1:/path/to/remote1/file username2@hostname2/path/to/remote2/file
```


## Servicios ## {#servicios}

#### Ejecución de servicios #### {#ejecucion-servicios}

**Crear un nuevo descriptor de servicio**

Crear un fichero en el directorio `/etc/systemd/system/`. El descriptor de un servicio básico tiene la siguiente estructura:

```
[Unit]
Description=<descripción del servicio>
After=<dependencias de otros servicios>

[Service]
Type=simple
User=<usuario con el que se ejecutará el servicio>
Group=<grupo con el que se ejecutará el servicio>
WorkingDirectory=<directorio en el que se ejecutará el servicio>
ExecStart=<comando de arranque del servicio>
Environment=<variables de entorno aplicadas al servicio>

[Install]
WantedBy=multi-user.target
```

**Recargar configuración del servicio**

```sh
sudo systemctl reload <nombre servicio>
```

#### Consultas sobre servicios #### {#consulta-servicios}

**Estado del servicio**

```sh
sudo systemctl status <nombre servicio>
```



[//]: # (Links)
[ISO-639-1]:https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
