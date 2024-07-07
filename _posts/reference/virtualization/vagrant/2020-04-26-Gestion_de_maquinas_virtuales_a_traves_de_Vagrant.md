---
author: Antonio Archilla
title: Gestión de máquinas virtuales a través de Vagrant
date: 2020-04-26
categories: [ "references", "virtualization", "vagrant" ]
tags: [ "vagrant" ]
layout: post
excerpt_separator: <!--more-->
---

[Vagrant][vagrant-home] es una herramienta proporcionada por la empresa **HashiCorp** que permite la construcción y la gestión de máquinas virtuales de forma configurable y reproducible. Esto significa que se podrá crear un arquetipo que defina qué los componentes que forman la máquina virtual y de cómo se ejecuta esta que fácilmente se podrá distribuir para su reproducción en diferentes entornos.

Un caso de uso básico es la creación de una máquina virtual con todos los componentes de un entorno de desarrollo destinado a que los miembros de un equipo ejecuten de forma local, cada uno con su instancia propia. La distribución del arquetipo de definición de la máquina virtual o **box** permitirá a cada uno de ellos disponer de un entorno estandarizado igual para todos ellos. Con esto se consigue ahorrar tiempo y evitar errores, dado que la configuración sólo se realiza una única vez. También se consigue propagar los cambios que se realicen en dicho entorno de una forma ordenada y documentada, ya que los cambios se realizan directamente en el arquetipo, que además puede ser gestionado por un sistema de control de versiones.

En el presente artículo se presenta una guía inicial de la gestión de máquina virtuales mediante [Vagrant][vagrant-home], desde la creación de la **box**, su ejecución y gestión de los recursos asociados.

<!--more-->

## Operativas con las boxes {#operativas-con-las-boxes}

Una de las características principales de [Vagrant][vagrant-home] es que dispone de un [repositorio central][vagrant-boxes] de **Boxes** que dispone de miles de definiciones diferentes para las combinaciones de sistema operativo, *software* instalado, etc. todas ellas catalogadas y accesibles mediante una página de búsqueda que hace fácil su localización.

Cada una de las definiciones registradas en el repositorio central dispone de un identificador con el formato `<propietario>/<artefacto>`. Por ejemplo, la **box** de Ubuntu 18.04 Bionic tiene este ID `ubuntu/bionic64`. Basta con consultarlo en la página de búsqueda del repositorio.

#### Inicialización {#inicializacion}

Una vez se ha encontrado el ID de la **box** que se quiere utilizar, sólo hay que ejecutar el siguiente comando para que [Vagrant][vagrant-home] inicialice el directorio actual cómo el entorno de ejecución de la **box** especificada. 

```sh
vagrant init ubuntu/bionic64
```

Esto creará el fichero **Vagrantfile** que le indica a [Vagrant][vagrant-home] la **box** que tiene que ejecutar y cómo tiene que hacerlo. Por defecto solo se indica el identificador de la **box** que se provisionará, pero cómo se verá más adelante, en este fichero se pueden especificar multitud de configuraciones adicionales que servirán para personalizar la máquina virtual. También será posible obviar la ejecución del comando `vagrant init` y inicial el entorno creando manualmente el fichero **Vagrantfile**.

Cómo norma general, todos los comandos destinados a modificar o trabajar con uno de los entornos virtuales debe de ser ejecutada dentro el directorio que contiene su fichero **Vagrantfile** correspondiente. A continuación se lista las acciones más usuales una vez el entorno ha sido inicializado.

#### Ejecución

Para iniciar la **box** se deberá ejecutar el comando:

```sh
vagrant up
```

La primera ejecución es un tanto especial ya que se encargará de descargar la imagen del **sistema *guest***, en caso de no tenerla cacheada por haberla descargado antes, y de inicializar la máquina virtual en el motor de virtualización correspondiente previamente a su ejecución. Por defecto [Vagrant][vagrant-home] utiliza [Virtualbox][virtualbox-home]  cómo motor de virtualización dado que es una plataforma bastante extendida y accesible para todo tipo de usuarios, aunque cómo se verá más adelante, esto podrá cambiarse para poder utilizar otros proveedores cómo por ejemplo VMWare, Hyper-V, Docker, etc.

Para que todo esto funcione, es necesario que el motor de virtualización, por defecto [Virtualbox][virtualbox-home], esté correctamente instalado y configurado en el **sistema *host*** previo a la ejecución del comando `vagrant up`.

Las posteriores ejecuciones del comando `vagrant up` serán mucho más ligeras ya que no será necesario descargar ni inicializar la máquina virtual, sólo arrancarla.

#### Acceso mediante SSH

Una vez inicializada la máquina virtual, [Vagrant][vagrant-home] proporciona un mecanismo de acceso pre-configurado al **sistema *guest*** mediante SSH. Para utilizarlo, se debe ejecutar el siguiente comando:

```sh
vagrant ssh
```

El usuario remoto `vagrant` mediante el que se conecta dispone de permisos de **sudo** y de acceso al **sistema *host*** mediante la ruta `/vagrant` del sistema de ficheros del **sistema *guest***. Esta se encuentra mapeada con el directorio que contiene el fichero **Vagrantfile** del entorno, por lo que este podrá ser utilizado cómo directorio compartido para traspasar información de un sistema a otro.

#### Aprovisionamiento

Durante la primera ejecución de la máquina virtual mediante el comando `vagrant up`, [Vagrant][vagrant-home] realiza lo que se denomina **aprovisionamiento** de la máquina virtual. Esto es, la ejecución de las instrucciones de inicialización especificadas en el fichero **Vagrantfile**. Si después una vez ejecutado el primer **aprovisionamiento** este proceso se debe volver a ejecutar, ya sea porque se ha realizado alguna modificación en la configuración o porque el primero ha fallado, se puede realizar ejecutando los siguientes comandos:

```sh
# Si la máquina virtual está parada
vagrant up --provision

# Si la máquina virtual está en funcionamiento
vagrant provision
```

En un posterior apartado se detallará cómo pueden especificarse las instrucciones a ejecutar durante el **aprovisionamiento**.

#### Paro y reinicio

Para finalizar la ejecución de la máquina virtual o reiniciarla, se deberá utilizar los siguientes comandos:

```sh
# Finalizar ejecución
vagrant halt

# Reinicio
vagrant reload
```

#### Otros comandos

A continuación se muestran otros comandos útiles para la gestión de los entornos virtuales registrados en [Vagrant][vagrant-home]:

* **Listar los entornos registrados**: Permite listar información de los entornos de ejecución de las diferentes máquinas virtuales registradas, tales cómo el **id**, **motor de virtualización**, **estado de la máquina** o el **directorio asociado**. Este comando se puede ejecutar desde cualquier directorio dado que proporciona información global de todo el sistema.

```sh
vagrant global-status

id       name    provider   state    directory
---------------------------------------------------------------------------------
a51c556  default virtualbox poweroff /home/vagrant/alm-vm
272ab70  default virtualbox poweroff /home/vagrant/wordpress-vm
```

* **Estado de un entorno**: Si no se proporciona ningún argumento adicional, indica si el entorno de virtualización alojado en el directorio actual está o no en funcionamiento. Si se proporciona una de las ID retornadas por el comando `vagrant global-status`, el estado de este será el reportado.

```sh
# Entorno alojado en el directorio actual
vagrant status

# A partir de una ID concreta
vagrant status 272ab70
```

* **Eliminación de un entorno**: Si no se proporciona ningún argumento adicional, elimina el entorno correspondiente al directorio actual. Si se proporciona una de las ID retornadas por el comando `vagrant global-status`, este será el entorno eliminado. 

```sh
# Entorno alojado en el directorio actual
vagrant destroy

# A partir de una ID concreta
vagrant destroy 272ab70
```

* **Listado de las box descargadas**: Lista las **box** descargadas remotamente que sirven cómo base a los entornos gestionados. Una vez se descarga por primera vez una máquina concreta esta queda cacheada de forma local y no se vuelve a descargar en sucesivos usos.

```sh
vagrant box list
```

* **Actualización de las box descargadas**: Actualiza las **box** base cacheadas. En caso de que estas tengan una nueva versión disponible remotamente, se descargará la nueva versión para que esté disponible en las próximas inicializaciones de nuevos entornos basados en ella. Los entornos ya incializados deben actualizarse manualmente o bien destruirse e inicializarse de nuevo. Si no se proporciona ningún argumento adicional, el comando indentifica la **box** base utilizada por el entorno contenido en el directorio actual. También se puede especificar el **tag** asociado a la **box** listado por el comando `vagrant box list`

```sh
# Box asociada al entorno alojado en el directorio actual
vagrant box update

# A partir de un tag concreto
vagrant box update --box ubuntu/bionic64

# Comprobar si hay actualizaciones pero sin descargarlas
vagrant box outdated --outdated
```

Las versiones antiguas de las **box** no serán borradas automáticamente. Se deberá ejecutar el siguiente comando para borrarlas. En caso se que una de ellas aún esté en uso por alguno de los entornos gestionado, se pedirá confirmación.

```sh
vagrant box prune

# Mostrar sólo el listado de candidatos al borrado
vagrant box prune --dry-run
```

* **Instalación de plugins**: Permite la instalación de *plugins* que amplían la funcionalidad base de [Vagrant][vagrant-home].

Por ejemplo, para instalar el *plugin* [vagrant-disksize][vagrant-disksize-home] que permite especificar el tamaño de disco utilizado por la máquina virtual se deberá ejecutar el siguiente comando:

```sh
vagrant plugin install vagrant-disksize
```

En el siguiente enlace se dispone de una [lista de los *plugins* soportados][Vagrant plugins].

## Configuración de una máquina virtual personalizada mediante Vagrantfile

La configuración de una máquina gestionada por [Vagrant][vagrant-home] se realiza mediante el fichero de configuración **Vagrantfile**, el arquetipo que se ha mencionado en los apartados anteriores. En él se indican cual será la base de la máquina virtual que se está configurando, el aprovisionamiento adicional, es decir, qué aplicaciones y configuraciones se harán sobre dicha base y todo tipo de configuraciones adicionales de la máquina virtual (red, espacio de disco, memoria asignada...).

A continuación se muestra la anatomía principal de un fichero **Vagrantfile** y cómo puede ser modificada para personalizar la ejecución de la máquina virtual. Su sintaxis está basada en **ruby** aunque no hace falta conocer el lenguaje para trabajar con él. En las referencias del artículo se encuentra un enlace a la [documentación oficial][vagrantfile-doc] que contempla la totalidad de las opciones. Aquí sólo se pretende dar una introducción a las opciones más típicas sin entrar en casos muy concretos:

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|	
	config.vm.provider :virtualbox do |vb|                      # (1)
		vb.customize ["modifyvm", :id, "--memory", "6144"]
	end

	config.vm.box = "ubuntu/bionic64"                           # (2)
	
	config.vm.network :private_network, ip: "192.168.1.10"      # (3)
	config.vm.network :forwarded_port, guest: 8080, host: 9877
	
	config.disksize.size = "60GB                                # (4)
		
	config.vm.provision "shell", path: "provision.sh"           # (5)	
end
```

En el código anterior se pueden observar la siguientes configuraciones:

###### - Configuración del *provider* (1)

El **provider** es el motor de virtualización que utilizará [Vagrant][vagrant-home] para ejecutar la máquina virtual. En el ejemplo se especifica el valor `virtualbox` para **VirtualBox** pero se pueden utilizar otros según conveniencia, cómo por ejemplo **VMware**, **Hyper-V**, **Docker** u otros. 

Dentro del bloque `config.vm.provider` se podrán especificar múltiples bloques `customize` con los que personalizar cada uno de los **providers**. En el ejemplo se muestra cómo modificar la cantidad de memoria asignada a la máquina virtual. Los parámetros admitidos en esta sección dependerán del **provider** utilizado. 

Durante el resto del artículo se presupondrá la utilización de **VirtualBox** cómo proveedor del motor de virtualización. Las configuraciones específicas de los **providers** permitidos se puede consultar en la [documentación oficial][vagrantfile-doc].

###### - Configuración de la base (2)

El valor especificado es este atributo determinará la **box** que se utilizará cómo base para el entorno generado cuando se ejecute el comando `vagrant up`. Cómo en el casuística expuesta en el apartado [Inicialización](#inicializacion) de este mismo artículo, se deberá indicar el **tag** correspondiente a la **box** deseada que puede encontrarse en el [repositorio central][vagrant-boxes].

###### - Configuración de red (3)

En la configuración del entorno virtualizado permite personalizar algunos parámetros de red que se creará para la máquina virtual asociada. Este es el caso de la IP privada asociada que permitirá evitar conflictos cuando se tienen diversas máquinas virtuales en funcionamiento e incluso permitirá la comunicación entre ellas a través de dichas IPs cómo si de máquinas remotas cualquiera se tratara. También se podrá mapear de puertos entre los sistemas **guest** y **host** en caso que se deba exponer alguno de ellos para su acceso desde el exterior de la máquina virtual.

###### - Otras configuraciones (4)

Según los *plugins* instalados será posible añadir parámetros de configuración adicional. Por ejemplo, si se ha instalado el *plugin* que permite redimensionar el disco asociado a la máquina virtual, se podrá indicar qué tamaño debe tener este, cómo se muestra en la configuración. Para saber qué valores se pueden especificar en cada caso se deberá referir a la documentación especifica de cada *plugin*. En el caso de [vagrant-disksize][vagrant-disksize-home], las configuraciones especificadas sólo tienen efecto si el entorno aún no ha sido inicializado, por lo que si se modifica esta configuración en un entorno ya existente, no tendrá efecto.

###### - Aprovisionamiento (5)

Cómo se he explicado en el apartado dedicado a las [operativas con las boxes](#operativas-con-las-boxes) de este mismo artículo, durante la primera ejecución de la máquina virtual o mediante el comando `vagrant provision` se ejecuta el **aprovisionamiento** de la máquina virtual. [Vagrant][vagrant-home] permite realizar este **aprovisionamiento** mediante diferentes mecanismos, sea utilizando comandos de **bash** directamente o mediante herramientas más avanzados como **Chef**, **Puppet** o **Ansible**. 

Los dos mecanismos más básicos serían la especificación de un *shell script* con comandos que debe especificarse mediante su ruta relativa al fichero **Vagrantfile**:

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|	
	# ...
		
	config.vm.provision "shell", path: "provision.sh"
end
```

O directamente una serie de comandos *inline*: 

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

$script = <<-SCRIPT
echo Script de Aprovisionamiento
# Definimos algunos Alias utiles...
alias untar='tar -zxvf '
alias c='clear'
SCRIPT

Vagrant.configure("2") do |config|	
	# ...
		
	config.vm.provision "shell", inline: $script
end
```

## Referencias

* [Vagrant][vagrant-home]
* [VirtualBox][virtualbox-home]
* [Vagrant plugins][Vagrant plugins]

[//]: # (Links)
[vagrant-home]:https://www.vagrantup.com/
[vagrant-boxes]:https://app.vagrantup.com/boxes/search
[Vagrant plugins]: https://github.com/hashicorp/vagrant/wiki/Available-Vagrant-Plugins
[vagrantfile-doc]:https://www.vagrantup.com/docs/vagrantfile/
[virtualbox-home]:https://www.virtualbox.org/
[vagrant-disksize-home]:https://github.com/sprotheroe/vagrant-disksize
