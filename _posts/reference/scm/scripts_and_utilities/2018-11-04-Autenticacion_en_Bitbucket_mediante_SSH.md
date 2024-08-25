---
author: Antonio Archilla
title: Autenticación en Bitbucket mediante SSH
date: 2018-11-04
categories: [ "references", "scm", "scripts and utilities" ]
tags: [ "git", "bitbucket", "ssh" ]
layout: post
excerpt_separator: <!--more-->
---

Esta mini guia expone los pasos a seguir para configurar el acceso en Bitbucket mediante **SSH**, de forma que no sea necesaria la especificación de las credenciales cada vez que se realice una acción 
sobre un repositorio hospedado en dicho servicio. Incluye la configuración necesaria para los 2 tipos de repositorio soportados por **Bitbucket** **Git** y **Mercurial**).

Es importante mencionar que la guia está enfocada a entornos Windows aunque los pasos son bastante similares en entornos Linux cambiando las instrucciones de consola por las del entorno de que toque.

<!--more-->

## 1. Generación del certificado:

### Cygwin

**Bitbucket** soporta claves de usuario generadas con cualquiera de los siguientes algoritmos de encriptación: **Ed25519**, **ECDSA**, **RSA** y **DSA**. 
En entornos Linux o en **Windows** utilizando **Cygwin**, se puede utilizar el siguiente comando para generarlas:

```sh
ssh-keygen -t rsa -b 4096 -C "usuario@bitsmi.com"
```

Dónde:

- **-t**: Indica el algoritmo de encriptación, RSA en este caso. El resto de algoritmos soportados por Bitbucket se pueden utilizar mediante las opciones ed25519, ecdsa o dsa
- **-b**: Indica el número de bits de la clave generada, 4096 bits en el ejemplo. Para claves RSA, el tamaño por defecto es 2048 y el mínimo es 1024 bits. En el caso de DSA, 
el tamaño está fijado en 1024 bits. Para las claves de tipo ECDSA este valor determina el tamaño de la clave de entre 1 de tres opciones: 256, 384 o 521 bits. 
Cualquier otro valor provocará un error en el proceso.
- **-C**: Comentario asociado a la claves, normalmente la dirección de correo asociada a las claves.

La ejecución del comando generará los ficheros `id_rsa` con la clave privada y `id_rsa.pub` con la clave pública del certificado. 
Los nombres de estos ficheros pueden diferir en caso de utilizar otro algoritmo de encriptación o especificar manualmente otro nombre durante el proceso de generación de las claves.

### Putty Key Generator

Otra forma de generar las claves necesarias es mediate la utilidad **PuTTY Key Generator** disponible con la instalación del cliente **PuTTY**. En este caso se podran generar claves de tipo **RSA** o **DSA**:

![](/assets/posts/reference/scm/scripts_and_utilities/Autenticacion_en_Bitbucket_mediante_SSH_fig1.jpg)

El resultado del proceso es el mismo que utilizando el comando `ssh-keygen`: Un fichero con la clave pública y otro con la clave privada.

En entornos Windows se recomienda dejar ubicada la **clave privada exclusivamente en la ruta por defecto** de `C:\Users\<nombre_usuario>`. 
Esto facilita la ubicación y selección de la clave privada en las distintas aplicaciones que la requieran.

## 2. Añadir la clave pública a la configuración de Bitbucket

Desde la configuración de la cuenta de **Bitbucket** será posible añadir la clave pública generada de forma que el servicio sea capaz de verificar la identidad del usuario en las operaciones que se realicen contra el repositorio remoto.

Se podrá acceder a la opción de añadir nuevas claves en el menú **SSH Keys** del apartado Security. Es importante que se especifique únicamente la **clave pública del certificado (fichero *.pub)**.

![](/assets/posts/reference/scm/scripts_and_utilities/Autenticacion_en_Bitbucket_mediante_SSH_fig2.jpg)

## 3. Especificar el mecanismo de autenticación SSH en repositorios Mercurial

Para configurar **Mercurial** y utilizar el mecanismo de autenticación **SSH** se tendrá que modificar el archivo general **mercurial.ini** ubicado en el directorio del usuario 
(`C:\Users\<nombre_usuario>\` en entornos **Windows**) del sistema modificado o añadiendo (en caso de no existir) la siguiente sección para que contenga las siguientes propiedades:

```properties
[ui] 
username = nombre_de_usuario 
ssh = tortoiseplink.exe -ssh -i "ruta_a_fichero_clave_privada" -l nombre_de_usuario
```

Dónde:

- **username**: Nombre de usuario de acceso a **Bitbucket**
- **ssh**: Indica a **Mercurial** que realice la conexión mediante SSH. Para ello se utiliza el ejecutable `tortoiseplink` proporcionado en la instalación del cliente **TortoiseHG**. Se especificarán en esta linea la ruta al fichero con la clave privada del certificado y el nombre de usuario de acceso a **Bitbucket**.

Una vez realizada esta configuración, para impedir que se requiera al usuario de dicha contraseña cada vez que se realice una conexión al repositorio remoto se podrá utilizar la herramienta **pageant** 
incluida en la instalación del **Putty** para que la guarde:

```sh
pageant.exe "ruta_a_fichero_clave_privada"
```

Una vez introducida la contraseña de la clave privada en **pageant**, no se volverá a requerir en las operaciones con el repositorio remoto.

A partir de este momento, se tiene que asegurar que todas las urls de conexión al repositorio remoto ubicado en **Bitbucket** sean de tipo **SSH**. 
Estas URLs estan especificadas en el fichero `.hg/hgrc` dentro de cada uno de los repositorios. Se puede consultar la url correcta al clonar el repositorio desde **Bitbucket**.

**NOTA**: En entornos **Windows** es importante destacar que se deberá volver a ejecutar el pageant manualmente y activar de nuevo el **SSH** indicando la contraseña para poder realizar 
la sincronización con los repositorios **Mercurial** locales con los de **Bitbucket** cuándo se realice un reinicio o un nuevo arranque de **Windows**.

## 4. Especificar el mecanismo de autenticación SSH en repositorios Git

Para configurar el cliente de **Git** para utilizar el mecanismo de autenticación **SSH** se tendrán que ejecutar los siguiente comandos desde **Git Bash**:

- Iniciar el agente **SSH** para gestionar los accesos:

```sh
eval $(ssh-agent)
```

- Añadir la clave privada:

```sh
ssh-add "ruta_a_fichero_clave_privada"
```

Una vez introducida la contraseña de la clave privada (se recomienda ubicarla en la ruta `C:\Users\<nombre_usuario>\`), no se volverá a requerir en las operaciones con el repositorio remoto.

En caso de utilizar como cliente de **Git**, Bitbucket se puede utilizar también la sincronización mediante **SSH** con **pageant** siguiendo el mismo proceso explicado en la sección de **Mercurial**.

