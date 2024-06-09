---
author: Antonio Archilla
title: Creación de una image base para Raspberry Pi
date: 2020-04-20
categories: [ "project", "kumo" ]
tags: [ "Raspberry Pi" ]
layout: post
excerpt_separator: <!--more-->
---

El primer paso para trabajar con una **Raspberry Pi** siempre es copiar la imagen del sistema operativo en una tarjeta SD y configurar dicho sistema creado usuarios,
configurando la red... Si se tienen múltiples dispositivos, esto significa repetir los mismos pasos una y otra vez con las configuraciones comunes.

La siguiente guía describe los pasos a seguir para la creación de la imagen base de una instalación de sistema operativo para **Raspberry Pi**
que pueda ser instalada en múltiples dispositivos y proporcione todas las aplicaciones y configuraciones comunes a todas ellos. 
Esto incluye la configuración de red, la creación de una cuenta de usuario administrador que centralice la gestión del sistema y la configuración del acceso
remoto para dicho usuario de forma remota a través de SSH.

Con ello se pretende ahorrar tiempo y simplificar el mantenimiento de todas las instalaciones, ya que los cambios se harán una sola vez para todos los dispositivos.

<!--more-->

## Instalación del sistema operativo

El primer paso para conseguir lo propuesto en el apartado anterior es el de instalar y ejecutar el sistema operativo en un dispositivo. En este caso, se utilizará una
imagen estándar de **ubuntu 18.04 server**. Para ello se hará lo siguiente:

* Descargar la aplicación [Balena Etcher Tool][Balena Etcher download] para *flashear* la imagen del sistema operativo en una tarjeta SD
* Descargar del [repositorio oficial de Ubuntu][Ubuntu IMG download] el fichero de imagen apropiada para **Raspberry Pi 3** o **4**. 
En esta guía se utilizará **Raspberry Pi 3 (Hard-Float) preinstalled server image** ya que se trabajará con una **Raspberry Pi 3 Model B**.
* *Flashear* la imagen de sistema descargada en el paso anterior usando la aplicación **Etcher**
* Insertar la tarjeta SD con el sistema en la **Raspberry Pi** y conectar monitor, ratón, teclado y el cable de red.
* Conectar a la corriente la *Raspberry Pi* y esperar a que el sistema cargue. En este caso el sistema cargará en modo consola. Se puede acceder con el usuario
`ubuntu` y la contraseña `ubuntu`. El sistema fozará el cambio de estas credenciales durante el primer acceso.

## Configuración de red

#### Asignación de una dirección IP temporal

Esta configuración sólo afecta a la sesión actual y será descartada al reiniciar el sistema. Se puede utilizar para realizar una asignación temporal antes de realizar
la configuración final.

```sh
# IP
sudo ifconfig eth0 10.0.0.100 netmask 255.255.255.0

# Gateway
sudo route add default gw 10.0.0.1 eth0

# Mostrar configuración actual
ip addr show
```

#### Asignación de una dirección IP estática

Para configurar el sistema para el uso de una dirección estática permanente, se utilizará la utilidad `netplan`. Para ello se creará un fichero en la ruta
`/etc/netplan/kumo_config.yaml`. El ejemplo de abajo asume la configuración del la interfaz de red `eth0`. 
Modifique los valores de **addresses**, **gateway4** y **nameservers** según los requerimientos.

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      addresses:
        - 10.0.0.100/24
      gateway4: 10.0.0.1
      nameservers:
          search: [mydomain.com, otherdomain.net]
          addresses: [1.0.0.1, 1.1.1.1]
```

**NOTA:** Los valores de `Addresses` corresponden a IPs de servidores DNS mientras que los de `Search` corresponden a nombres de dominio que serán añadidos a los
nombres de *host* en las consultas a los servidores DNS. Por ejemplo, al hacer una petición sobre el *host* **server1** disparará las siguientes consultas DNS para la 
configuración anterior **server1.mydomain.com** y **server1.otherdomain.net**
El campo `Search` puede estar vacío si no se utilizan dominios de búsqueda.

Después de especificar la configuración anterior, se puede ejecutar usando la utilidad [Netplan][netplan].

```sh
sudo netplan apply
```

Para eliminar las asignaciones de IPs antiguas, se ejecutará el comando `ip address show dev eth0` para listar las direcciones actualmente
asignadas a la interfaz de red, `eth0` en el ejemplo. El resultado mostrará las direcciones IP asignadas por `netplan` en el paso previo así como la
IP antigua identificada cómo `scope global secondary eth0`. Esta dirección antigua se puede eliminar ejecutando el siguiente comando. En el ejemplo se borrará
la ip `10.0.0.8/24`, incluyendo la máscara de red tal y como se muestra en los resultados de `ip address show`:

```sh 
sudo ip address delete 10.0.0.8/24 dev eth0
``` 

## Configuración de una cuenta de usuario de administración

En esta sección se describe la creación y configuración de una cuenta de usuario con capacidades de administración para agrupar todas las tareas y permisos
administrativos del sistema. En esta guía este usuario se llamará `kumo_admin`.

#### Creación del usuario

Para crear un nuevo usuario se accederá al sistema con el usuario `ubuntu` y se ejecutarán las siguientes acciones:

###### - Crear una nueva cuenta de usuario con permisos *sudo*

Durante la creación del usuario el sistema pedirá que se introduzca la contraseña, entre otros datos.

```sh
# Creación del usuario.
sudo adduser kumo_admin
# Asignación al grupo sudo
sudo usermod -aG sudo kumo_admin
```

Se podrán utilizar los siguiente comandos para comprobar los grupos asignados al usuario.

```sh
# Usuario actual
groups

# Usuario especifico
sudo groups kumo_admin

# Lista de todos los grupos disponibles
sudo less /etc/group
```

###### - Borrar la antigua cuenta de usuario

Para ejecutar las siguientes acciones se deberá acceder al sistema con el usuario `kumo_admin`. **ATENCIÓN! La cuenta borrada no podrá ser restaurada**

```sh
# Borrado del usuario
sudo deluser --remove-home ubuntu
# Borrado del grupo asociado (Si el paso anterior no lo hace)
sudo groupdel ubuntu
```

#### Habilitar la ejecución de SUDO sin necesidad de contraseña

Las tareas de administración a menudo requieren ejecuciones de comandos con permisos de **sudo**. La siguiente configuración elimina la necesidad de introducir la contraseña
cuando se requieren dichos permisos. Esto es útil cuando, por ejemplo, las tareas se ejecutan de forma automatizada por procesos, dónde no hay interacción con el usuario.
El grupo `kumo_sudo` se creará para restringir los usuarios que puedan ejecutar **sudo** sin contraseña:

###### - Crear el grupo `kumo_sudo`

```sh
groupadd kumo_sudo
```

###### - Configurar el grupo `kumo_sudo` para no necesitar contraseña

Añadir la siguiente línia al fichero `/etc/sudoers`. Serán necesarios permisos de **sudo** para editar el fichero:

```
%kumo_sudo      ALL=(ALL) NOPASSWD: ALL
```

###### - Asignar el grupo `kumo_sudo` al usuario `kumo_admin`

```sh
sudo usermod -aG kumo_sudo kumo_admin

# Comprobar que el grupo ha sido correctamente asignado. Puede requerir cerrar la sesión actual.
groups
```

#### Configuración de la conexión SSH

La configuración abajo expuesta permitirá al usuario acceder remotamente a través de SSH sin necesidad de introducir la contraseña utilizando para ello su certificado digital.

#### Configuración de las claves SSH

Para generar las claves RSA del usuario que permitan su identificación se deberá ejecutar el siguiente comando desde el sistema cliente:

```sh
ssh-keygen -t rsa
```

Esto generará 2 ficheros: `~/.ssh/id_rsa` con la **clave privada** y `~/.ssh/id_rsa.pub` con la **clave pública**.

Se debe copiar la **clave pública** en el servidor (Raspberry Pi) usando el comando `ssh-copy-id` cómo se muestra a continuación, 
reemplazando `<username>` y `<remote_host>` con los valores correspondientes. Se deberá introducir la contraseña del usuario remoto durante el proceso.

```sh
ssh-copy-id <username>@<remote_host>
```

Si no se dispone del comando `ssh-copy-id`, será posible realizar una cópia manual ejecutando el siguiente comando:

```sh
cat ~/.ssh/id_rsa.pub | ssh <username>@<remote_host> "mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys && chmod -R go= ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

Cómo en el caso anterior, los valores de `<username>` y `<remote_host>` deberán ser sustituidos por los valores correspondientes 
y también se deberá introducir la contraseña del usuario remoto durante el proceso.

#### Deshabilitar la autenticación por contraseña para las conexiones SSH

Dado que el usuario accederá al sistema mediante clave digital, la autentición por contraseña se puede deshabilitar para más seguridad. Para ello
se deberá editar el fichero `/etc/ssh/sshd_config` y cambiar la línea `PasswordAuthentication yes` por la siguiente `PasswordAuthentication no`.

Acto seguido se deberá reiniciar el servicio SSH para hacer activos los cambios:

```ssh
sudo service ssh restart
```

## Backup de la tarjeta SD de Raspberry Pi

Una vez realizada todas las modificaciones deseadas a la imagen base del sistema operativo, es momento de extraer y hacer una copia de dicha imagen para que 
posteriormente se pueda instalar en otros dispositivos. El proyecto [Kumo][kumo homepage] dispone de una máquina virtual que se ejecuta sobre **Vagrant**
que incorpora las utilidades necesarias para poder hacer la copia.

Para hacer la copia de la tarjeta SD se deberá hacer lo siguiente:

###### - Descargar y ejecutar la máquina Vagrant [Kumo developer VM][kumo-dev-vm]

###### - Conectar la tarjeta SD al pc mediante un lector de tarjetas

###### - Configurar el acceso a la tarjeta SD desde la máquina host.

Este paso sólo es necesario si la tarjeta SD no es accesible desde el sistema *Guest* de la máquina virtual.

Se debe ejecutar el siguiente comando dentro de dicho sistema para asegurar que el dispositivo requerido es listado:

```sh
sudo fdisk -l
```

En el ejemplo, el dispositivo es `/dev/sdc`. 
Si el dispositivo no es mostrado en la lista, se deberá configurar un **dispositivo *raw*** para poder acceder a la tarjeta SD. 
Si el dispositivo es listado, se pueden saltar los siguientes pasos.

###### - Obtener el ID de dispositivo del lector de tarjetas

En el sistema *host* **Windows**, abrir un CMD como administrador y ejecutar el siguiente comando:

```cmd
wmic diskdrive list brief
```

El resultado será una lista similar a la siguiente:

```cmd
D:\usr\bin\virtual_box>wmic diskdrive list brief
Caption                     DeviceID            Model                       Partitions  Size
SAMSUNG ---------------     \\.\PHYSICALDRIVE1  SAMSUNG ---------------     3           256052966400
ST----------------          \\.\PHYSICALDRIVE0  ST----------------          1           1000202273280
SDHC Card                   \\.\PHYSICALDRIVE2  SDHC Card                   2           7772889600
```

En el ejemplo el ID de dispositivo es `\\.\PHYSICALDRIVE2`

###### - Crear un fichero VMDK que enlazará a la tarjeta SD

En el sistema *host* **Windows**, abrir un CMD como administrador y ejecutar el siguiente comando,
teniendo en cuenta modificar las rutas hacia la instalación de VirtualBox y la ubicación final donde se quiere crear el fichero VMDK.

```cmd
c:\path\to\virtual_box\VBoxManage internalcommands createrawvmdk -filename "\path\to\vm\external-disk\sdcard.vmdk" -rawdisk "\\.\PHYSICALDRIVE2"
```

###### - Enlazar el fichero RAW a la máquina virtual dentro de la UI de VirtualBox

1. Asegurarse de que la VM no está en marcha.
2. Iniciar VirtualBox en modo administrador.
3. Abrir la configuración de la máquina virtual
4. *Click* en la opción **Storage** de la barra de opciones
5. *Click* en el icono **Add Hard Disk**
6. Seleccionar **Choose existing disk**
7. Navegar por el sistema de ficheros hasta el archivo vmdk y seleccionarlo
8. El fichero vmdk aparecerá en la lista.

**NOTA:** Para prevenir errores en la VM cuando el lector de tarjetas SD no se encuentra conectado al PC, el fichero asociado al disco debe ser des-asociado
en la sección **storage** de VirtualBox después de su uso.


#### Clonado de la tarjeta SD

Ejecutar el siguiente comando desde la máquina virtual:

```sh
sudo fdisk -l
```

Esto debería mostrar la información del dispositivo asociado, en este ejemplo `/dev/sdc`. Para iniciar el clonado de la tarjeta SD, se debe ejecutar el siguiente
comando para copiar el contenido de `/dev/sdc` hacia el fichero destino `/path/to/clone.img`.

```sh
sudo dd if=/dev/sdc of=/path/to/clone.img
```

#### Minimizar el tamaño de la imagen

Con este paso se eliminará el tamaño no usado de la imagen de disco, con lo cual se minimiza el tamaño del fichero resultante.

```sh
sudo pishrink.sh -d /path/to/clone.img /path/to/clone-shrink.img
```

Donde:
* `-d` activa el modo *debug* creando un fichero de *log* en el directorio actual
* `/path/to/clone.img` es el fichero a minimizar
* `/path/to/clone-shrink.img` es el fichero minimizado resultante

**NOTA:** El fichero destino no puede ser un directorio compartido entre los sistemas *Host* y *Guest*, como por ejemplo `/vagrant`

#### Flashear la imagen en una nueva tarjeta SD

Usar [Balena Etcher Tool][Balena Etcher download] para escribir la imagen generada en una nueva tarjeta SD


#### Comprimir el fichero de la imagen

```sh
gzip -9 /path/to/clone-shrink.img
```

## Referencias

* [Balena Etcher download]
* [Ubuntu 18.04 download][Ubuntu IMG download]
* [Netplan Homepage][netplan]
* [Repositorios proyecto Kumo][kumo homepage]
* [Kumo developer VM][kumo-dev-vm]

[//]: # (Links)
[Balena Etcher download]:https://www.balena.io/etcher/
[Ubuntu IMG download]:http://cdimage.ubuntu.com/ubuntu/releases/bionic/release/
[netplan]: https://www.netplan.io
[kumo homepage]: https://bitbucket.org/account/user/bitsmi-projects/projects/KUMO
[kumo-dev-vm]: https://bitbucket.org/bitsmi-projects/kumo-dev-vm
