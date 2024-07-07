---
author: Antonio Archilla
title: Error al sincronizar repositorio Git con certificado SSL auto-firmado
date: 2020-12-26
categories: [ "references", "scm", "scripts and utilities" ]
tags: [ "git", "ssl" ]
layout: post
excerpt_separator: <!--more-->
---

## Descripción del error

El cliente local de *Git* produce un error de comunicación con el servidor remoto cuando este último tiene un **certificado SSL auto-firmado**, avisando que la comunicación no es segura.

![Error de sincronización en TortoiseGit](/assets/posts/reference/scm/scripts_and_utilities/Error_al_sincronizar_repositorio_Git_con_certificado_SSL_auto-firmado_fig1.png)

## Solución

Es posible indicar a *Git* que confíe en origen remoto y permita trabajar con el repositorio. **Esto se debe hacer sólo si se conoce el repositorio remoto y se confía en él**. 

<!--more-->

Para ello, se deberá descargar el certificado SSL del servidor e importarlo como CA en el repositorio. La descarga se puede realizar desde el mismo navegador, por ejemplo en **Firefox**, mediante las opciones accesibles desde el icono "candado" junto a la barra de direcciones:

![](/assets/posts/reference/scm/scripts_and_utilities/Error_al_sincronizar_repositorio_Git_con_certificado_SSL_auto-firmado_fig2.png)

O si se dispone de `openssl`, mediante el siguiente comando en el que se indicará el `host` del repositorio remoto:

```sh
openssl s_client -connect host.repositorio.git:443
```

Del resultado del comando anterior, se deberá copiar el texto contenido entre las cadenas de texto `-----BEGIN CERTIFICATE-----` y `-----END CERTIFICATE-----`, ambas incluidas, a un fichero `.pem`.

Una vez descargado el certificado, se podrá indicar a *Git* que confíe en el certificado del servidor de forma global para todos los repositorios del usuario, a nivel de sistema o sólo para un repositorio. 

#### Inclusión a nivel de sistema o global

Si se decide trabajar de forma global o a nivel de sistema, se podrán utilizar el siguiente comando para incluir el certificado:

```sh
git config --system http.sslCAinfo /path/a/certificado.pem

git config --global http.sslCAinfo /path/a/certificado.pem
```

**ATENCIÓN**: Hay que tener cuidado porque estos comandos sobrescriben la configuración del fichero que contiene los CAs por defecto en caso de existir y como resultado sólo admitiría como válido el certificado contenido en el fichero descargado previamente. Para evitar esto, se puede editar el fichero por defecto añadiendo el nuevo certificado. La ruta del fichero por defecto se puede extraer mediante el siguiente comando:

```sh
git config --system --list

git config --global --list
```

En caso de existir, aparecerá una linea similar a `http.sslcainfo=/ruta/a/ssl/certs/ca-bundle.crt`

Para añadir el nuevo certificado y que sea aceptado, se deberá copiar el contenido del fichero del nuevo certificado a este.

#### Inclusión a nivel de repositorio local

Para incluir el certificado sólo para dicho repositorio, se deberá incluir la siguiente configuración en el fichero `.git/config` del repositorio local, indicando la ruta al fichero del certificado descargado. Se debe tener cuidado de no repetir el encabezado `[http]` si este ya existe en el fichero de configuración.

```
[http]
	sslCAinfo = /path/a/certificado.pem
```

El mismo efecto se consigue ejecutando el siguiente comando mediante `git bash` dentro del directorio del repositorio:

```sh
git config http.sslCAinfo /path/a/certificado.pem
```

## Solución alternativa

**ATENCIÓN**: Esta opción es muy insegura y no debe utilizarse de forma generalizada.

Como última opción, también es posible deshabilitar la verificación del certificado SSL del servidor en la configuración del repositorio local. Puede deshabilitarse para todos los orígenes configurados o sólo uno concreto. Para ello, se deberá incluir la siguiente configuración en el fichero `.git/config` del repositorio local:

Para deshabilitar la verificación en todos los orígenes:

```
[http]
	sslVerify = false
```

Para deshabilitar la verificación en un origen concreto, especificando la url de este:	

```
[http "https://host.repositorio.git"]
	sslVerify = false
```
