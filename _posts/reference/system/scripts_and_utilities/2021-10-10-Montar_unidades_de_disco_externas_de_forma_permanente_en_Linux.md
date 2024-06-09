---
author: Antonio Archilla
title: Montar unidades de disco externas de forma permanente en Linux
date: 2021-10-10
categories: [ "references", "system", "scripts and utilities" ]
tags: [ "linux" ]
layout: post
excerpt_separator: <!--more-->
---

En el siguiente artículo se explica la configuración necesaria en **Linux** para montar unidades de disco externas automáticamente al iniciar el sistema. Aunque la explicación y ejemplos se han hecho específicamente para sistemas **Ubuntu**, los mismos pasos también son aplicables a otros sistemas **Linux**.

El proceso se puede dividir en los siguientes pasos:

- Identificar el dispositivo de disco externo en el sistema
- (Opcional) Configurar un grupo que permita restringir el acceso al contenido de las unidades externas
- Modificar la configuración en `fstab` para añadir las unidades de disco externas a los dispositivos a montar durante el arranque del sistema

Adicionalmente, se explica cómo habilitar disco montado como volumen en contenedores **Docker** cuando se utilizan usuarios con acceso restringido a las ubicaciones de disco.

<!--more-->

## Identificación del dispositivos

Como paso previo a la configuración del dispositivo en el `fstab` del sistema, será necesario recuperar algunos datos de este. Para identificar el dispositivo en el sistema se utilizará el comando `lsblk`, a través del cual se obtendrá la ubicación del dispositivo. En el caso de ejemplo de este artículo se trabajará sobre el dispositivo usb de 2TB que aparece en la salida del comando bajo el identificador `sdb2`. Dependiendo de la configuración del sistema en el que se ejecuta, el resultado será diferente.

```sh
lsblk

NAME                 MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
loop0                  7:0    0  55.5M  1 loop /snap/core18/2074
loop1                  7:1    0  55.4M  1 loop /snap/core18/2128
loop2                  7:2    0  61.8M  1 loop /snap/core20/1081
loop3                  7:3    0  70.3M  1 loop /snap/lxd/21029
loop4                  7:4    0  67.3M  1 loop /snap/lxd/21545
loop5                  7:5    0  32.3M  1 loop /snap/snapd/12883
loop6                  7:6    0  32.3M  1 loop /snap/snapd/13170
loop7                  7:7    0  61.9M  1 loop /snap/core20/1169
sda                    8:0    0 119.2G  0 disk
├─sda1                 8:1    0   512M  0 part /boot/efi
├─sda2                 8:2    0     1G  0 part /boot
└─sda3                 8:3    0 117.8G  0 part
  └─ubuntu--vg-lv--0 253:0    0 117.8G  0 lvm  /
sdb                    8:16   0   1.8T  0 disk
├─sdb1                 8:17   0    16M  0 part
└─sdb2                 8:18   0   1.8T  0 part
```

Una vez identificado el dispositivo, se procederá a obtener el `UUID` asociado para su posterior uso. Para ello se utilizará el comando `blkid`:

```sh
sudo blkid /dev/sdb2
```

En este caso la salida del comando indica que el UUID del dispositivo es `254AB66744378BC`.

## (Opcional) Creación de un grupo para el administrar el acceso 

Para administrar el acceso al directorio será posible crear un grupo al que asignar los permisos adecuados. La creación del grupo se ejecutará a través del comando `groupadd`. En el siguiente ejemplo se crea el grupo `data_ext` y se asigna al usuario existente `local_user`:

```sh
groupadd data_ext
sudo usermod -aG data_ext local_user
```

Una vez creado el grupo, se deberán identificar los **UID** y **GUID** del usuario y grupo para su posterior especificación en la configuración de `FSTAB`.

```sh
# Para el UID
id -u local_user
# Para el GID
getent group data_ext
```

En el ejemplo, los valores mostrados como resultado de los comandos anteriores son UID=1010, GID=1011.


## Configuración en FSTAB

Editar el fichero `/etc/fstab` con el comando:

```sh
sudo nano /etc/fstab
```

Y añadir la siguiente configuración:

```
# device  mountpoint  FS-Type  Options	Dump  fsck-Order
UUID=254AB66744378BC /media/DATA_EXT auto uid=1010,gid=1011,umask=007,nofail,x-gvfs-show 0 0
```

Indicando los siguientes valores:
- Columna `device`: El UUID recuperado en pasos anteriores. En el caso de ejemplo corresponde al valor `254AB66744378BC`.
- Columna `mountpoint`: El directorio donde se quiere montar el contenido del disco externo. En el caso de ejemplo, se accederá a este desde el directorio `/media/DATA_EXT`.
- Columna `fs-type`: Tipo del sistema de ficheros (**ext4**, **xfs**, **hfs** y **ntfs-3g**). Indicando el valor `auto` el sistema será el encargado de identificarlo.
- Columna `options`: Opciones de montado adicionales. En el caso de ejemplo se especifican el UID y GID del usuario y grupos que tendrán acceso al directorio montado (Valores recuperados en el apartado anterior). Adicionalmente, se especifica la opción `umask` para poder aplicar permisos a sistemas de ficheros **FAT** o **NTFS**. `umask` funciona de forma similar a los códigos octales utilizados en instrucciones como `chmod` pero invirtiendo los valores, es decir, substrayendole a 7 el valor que se indicaría al comando `chmod`. Por ejemplo, para especificar los permisos `755` se deberá especificar el `umask=022`. Como en el caso del comando `chmod`, los códigos constan de 3 dígitos, siendo el primero para el correspondiente al usuario actual, el segundo al grupo y el tercero para el resto de casos. En el caso del ejemplo el valor `umask=007` indica que el usuario `local_user` (UID=1010) y el grupo `data_ext` (GID=1011) tienen permisos completos (valor 0), mientras que el resto de usuarios no tienen acceso totalmente restringido (valor 7).
- Columna `dump`: hace referencia a la configuración de *backup* (1=backup, 0=No backup)
- Columna `fsck-order`: Define si el disco deberá ser comprobado al iniciar el sistema o durante el montado. 0 significa que no se realizará **fsck**. Otros valores definen el orden en el que se realizará el **fsck**.

Para aplicar los cambios una vez guardada la configuración en `fstab`, se deberá volver a montar el directorio especificado en dicha configuración:

```sh
umount /media/DATA_EXT
mount  /media/DATA_EXT
```

## Caso adicional - Montar el directorio montado como volumen en Docker

Para montar el directorio montado como volumen en contenedores **Docker**, el grupo creado en el *host* debe ser asignado al usuario correspondiente dentro del contenedor que deba leer y/o escribir en el volumen. Todas las instrucciones descritas a continuación se deberán ejecutar dentro del contenedor. Se puede acceder a la ejecución de comandos en el contenedor mediante el siguiente comando:

```sh
sudo docker exec -it <nombre o id contenedor> /bin/sh
```

El primer paso es asegurar que el grupo creado en el *host* exista también en el contenedor y que tengan el mismo GID:

```sh
groupadd --gid 1011 data_ext
```

Posteriormente se debe asignar el grupo al usuario dentro del contenedor. En este ejemplo se habilita al usuario `www-data` del contenedor leer y escribir en el directorio montado:

```sh
usermod -aG data_ext www-data
```

Como último paso, se deberá reiniciar el contenedor.


