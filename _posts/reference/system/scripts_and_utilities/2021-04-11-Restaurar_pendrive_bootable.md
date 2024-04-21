---
author: Antonio Archilla
title: Restaurar pendrive bootable
date: 2021-04-11
categories: [ "references", "system", "scripts and utilities" ]
tags: [ "windows" ]
layout: post
excerpt_separator: <!--more-->
---

Habitualmente se utilizan *pendrives* como soporte para la instalación de sistemas operativos mediante la creación de un ***pendrive bootable***. El problema es que después de hacer esto este queda en un estado que no permite su uso para el almacenamiento de datos porque el proceso de conversión a ***bootable*** ha creado múltiples particiones y sistemas como Windows no son capaces de reconocerlo correctamente.

![](/assets/posts/reference/system/scripts_and_utilities/Restaurar_pendrive_bootable_fig1.png)

En este post se describe el proceso de restauración de un ***pendrive bootable*** a su estado original en **Windows**.
<!--more-->
El proceso se hará a través de la herramienta `Diskpart` que incorpora **Windows** para administrar las unidades del equipo (discos, particiones, volúmenes o discos duros virtuales). Se deberán seguir los siguientes pasos:

* Abrir el `cmd` del sistema como Administrador
* Ejecutar `diskpart`
* Listar los discos presentes en el sistema mediante la orden `list disk`. En el ejemplo el disco asociado al *pendrive* es la **2** pero en otros casos puede ser diferente
![](/assets/posts/reference/system/scripts_and_utilities/Restaurar_pendrive_bootable_fig2.png)
* Seleccionar el disco asociado al *pendrive*. En el ejemplo corresponde al **2** pero en otros casos puede ser diferente.
```sh
select disk 2
```
* Eliminar todo el formato de las particiones del disco seleccionado
```sh
clean
```
* Crear al partición primaria de la unidad
```sh
create partition primary
```
* Marcar la partición creada como activa
```sh
active
```
* Formatear la unidad en el formato de ficheros especificado
Para NTFS
```sh
format fs=ntfs quick
```
Para FAT32
```sh
format fs=fat32 quick
```
* Asignar una letra a la unidad. Se puede obviar el parámetro `letter` para asignar la siguiente letra disponible por defecto.
```sh
assign letter=f
```

Una vez hecho todo esto, se puede salir de la aplicación mediante la orden `exit`. El resultado es una extraible usable como media de almacenamiento de datos totalmente reconocible por **Windows**

![](/assets/posts/reference/system/scripts_and_utilities/Restaurar_pendrive_bootable_fig3.png)


## Referencias

* [Documentación oficial de Diskpart][diskpart-docs]

[//]: # (Links)
[diskpart-docs]:https://docs.microsoft.com/es-es/windows-server/administration/windows-commands/diskpart
