---
author: Antonio Archilla
title: Migrar un repositorio de código Mercurial a Git
date: 2020-06-23
categories: [ "references", "scm", "scripts and utilities" ]
tags: [ "git", "mercurial" ]
layout: post
excerpt_separator: <!--more-->
---

En el siguiente artículo se expone el proceso de migración de un repositorio de código gestionado por [Mercurial SCM][mercurial-hg] a [Git SCM][git]. 
El proceso se puede llevar a cabo en entornos **Linux / Unix** o **Windows** utilizando la consola de comandos **Git Bash** y adicionalmente herramientas gráficas 
como [Tortoise Hg][tortoise-hg] y [Tortoise Git][tortoise-git] para verificar los resultados. 

<!--more-->

## Preparación del entorno

Para llevar a cabo el proceso será necesario tener instalado en el entorno de trabajo las herramientas de gestión de repositorios **Mercurial** y **Git**. 
Dependiendo del sistema operativo, se podrán obtener de diferentes maneras. En el caso de **Mercurial** será necesario instalar ademas la extensión **Mercurial-Git** 
que permitirá realizar el ***push*** de los *changesets* a un repositorio **Git**.


#### En entornos Linux

En la mayoría de distribuciones **Linux** se pueden encontrar las herramientas directamente en los repositorios oficiales de la distribución. 
Por ejemplo, en **Ubuntu** se ejecutarían los siguientes comandos para instalar las herramientas de **Mercurial**, **Git** y la extensión **Mercurial-Git** de **Mercurial**:

```sh
sudo apt-get install git
sudo apt-get install mercurial
sudo apt-get install mercurial-git
```

Una vez instaladas la aplicaciones en el sistema, se deberá verificar que tanto los comandos `git` como `hg` se encuentran correctamente en el *path*, 
por ejemplo ejecutando el comando para obtener la versión de las aplicaciones instaladas:

```sh
hg version
git version
```

#### En entornos Windows

La instalación de las diferentes herramientas en un entorno Windows se realiza a través de los instaladores oficiales de cada una de ellas. 
En el caso de **Mercurial** se deberá descargar el instalador de **Tortoise Hg** desde su [página oficial][tortoise-hg] que además de la herramienta gráfica 
instalará la distribución de **Mercurial**.

Para instalar **Git** se deberá descargar el instalador de la distribución para Windows desde su [página oficial][git]. Una vez hecho esto si se quiere también 
se puede instalar opcionalmente una herramienta gráfica como [Tortoise Git][tortoise-git].

## Procedimiento

Los pasos a seguir para realizar la migración de los repositorios se enumeran a continuación. Para ejemplificar el caso, se supondrá un repositorio **Mercurial** 
origen ubicado en un servidor remoto con url `https://mercurial-repo/repository1` que se quiere migrar al repositorio **Git** destino ubicado en `https://git-repo/repository1`.

**Hacer una copia local a migrar** 

Se clonará el repositorio **Mercurial** origen a partir de su url (en el ejemplo `https://mercurial-repo/repository1`). 

```sh
hg clone http://mercurial-repo/repository1
```

En caso que ya se disponga de una copia local que se quiera copiar para no alterar el original o bien se trate de un repositorio almacenado en una ubicación de disco, 
se podrá substituir la url del comando por la ruta a disco correspondiente.

La acción de clonado creará una nueva carpeta con el nombre del repositorio, en este caso `repository1`, en el directorio de trabajo. En el ejemplo se supondrá 
que se está trabajando en el directorio `/workspace`. 

**Inicializar el repositorio Git destino**

Se creará una nueva carpeta al mismo nivel donde se ha clonado el repositorio **Mercurial** en el paso anterior. En ella se ubicará la copia local del repositorio **Git** 
donde se transferirán los *changesets* posteriormente. Para facilitar el proceso, se puede nombrar este directorio con el mismo nombre del origen añadiendo el sufijo `_git` 
para identificarlo mejor. En el ejemplo, los 2 directorios sobre los que se trabajará serán:

* **/workspace/repository1**: Repositorio Mercurial origen
* **/workspace/repository1_git**: Repositorio Git destino

Una vez creado el directorio destino, será necesario inicializar el repositorio **Git** desde su interior:

```sh
cd /workspace/repository1_git
git init --bare .git
```

Se creará como repositorio de tipo `bare` ya que durante el proceso de migración este no contendrá ficheros. Posteriormente se modificará este *setting*.


**Configurar el repositorio Mercurial origen**

Se editará el fichero de configuración del repositorio origen local para habilitar las extensiones necesarias para el proceso de migración y indicar la ubicación del 
directorio correspondiente al repositorio **Git** destino. Este fichero se encuentra en la ruta `.hg/hgrc` dentro del directorio del repositorio (/workspace/repository1/.hg/hgrc 
en el ejemplo).

Para indicar la ubicación del repositorio destino, se añadirá la linea `git = /workspace/repository1/.git` a la sección `[paths]` del fichero. 
El identificador `git` a la izquierda del '=' es personalizable y servirá posteriormente como referencia cuando se haga ***push*** de los cambios al repositorio destino.

La habilitación de las extensiones necesarias se realizará en la sección `[extensions]` añadiendo los valores `hgext.bookmarks` y `git`.

El siguiente ejemplo muestra un fichero de configuración con el resultado final:

```properties
[paths]
default = http://mercurial-repo/repository1
git = /workspace/repository1_git.git

[ui]
username = John Doe <jdoe@example.com>

[extensions]
hgext.bookmarks =
git =
```

**Marcar los *changesets* a migrar**

Mediante la extensión **Bookmarks** de mercurial se procederá a marcar los *changesets* que se migraran a **Git**. Una manera fácil de seleccionar el contenido es 
a través de las ramas creadas en el repositorio. Mediante el comando `hg branches` se puede obtener la lista de ramas abiertas. Como resultado se obtendrá una lista 
de identificadores de ramas y el changeset al que apunta su `head`:

```sh
feature/new_feature           648:21b671e08b97
bug/DF-18_filter_list_reorder 642:d38d1c8ad2b4
devel                         627:316766e64626
default                       529:822bf5ce7a33 (inactive)
```

Para cada una de las ramas que se quieran migrar, se tendrá que actualizar el contenido del repositorio apuntado al `head` de cada una y creando un **bookmark** 
que se convertirá en una nueva rama en el repositorio **Git** destino. Al nombrar el **bookmark** no se podrá utilizar el mismo nombre de la rama, por lo que es 
buena idea utilizar un prefijo añadiéndolo a este. De esta forma no se repite el nombre y es fácil identificar las ramas que se han migrado. Hay que tener en cuenta 
que los nombres de las marcas realizadas mediante no pueden contener el carácter '/' ya que internamente se trata como separador de fichero y dará un error:

```sh
hg update feature/new_feature
hg bookmarks hg-feature_new_feature
```

Técnicamente se puede marcar cualquier *changeset* del repositorio con este mecanismo. En lugar de hacer `update` utilizando el nombre de la rama como apuntador, 
se podrá utilizar cualquier identificador de *changeset* y tendrá el mismo efecto. Por ejemplo, para apuntar el repositorio al *changeset* 627:

```sh
hg udpate 627
```

Cada una de las marcas realizadas conlleva que se migrará al repositorio destino tanto el *changeset* marcado como sus antecesores hasta el primer *changeset* del repositorio.

**Migrar los *changesets***

Una vez seleccionados los *changesets* que se quieren migrar, se utilizará el comando `hg push` para pasar los *changesets* al repositorio **Git** local 
(/workspace/repository1_git en el ejemplo). Si se ha configurado un identificador para el destino en la sección `[paths]` del fichero de configuración `hgrc`, 
será posible utilizarlo como abreviación. En el ejemplo, el destino se ha configurado con el identificador `git`:

```sh
hg push git
```

Además de los **bookmarks** marcados en el paso anterior, también tendrán en cuenta para la migración los *changesets* marcados con *tags*. En este caso, 
en lugar de crearse ramas en el repositorio destino como con los **bookmarks** se crearán *tags* de **Git**.

Una vez realizado el *push* al repositorio destino, se deberá ejecutar el siguiente comando en el directorio del repositorio local de **Git**, de esta forma se podrá hacer 
*checkout* de los diferentes *changesets* migrados. 

```sh
cd /workspace/repository1_git.git
git config --bool core.bare false
```

Esta modificación también evita que al trabajar o visualizar el *changelog* se produzcan errores como el siguiente ocurrido en **Tortoise Git**:

![](/assets/posts/reference/scm/scripts_and_utilities/Migrar-repositorio-hg-a-git_fig1.png)


**Hacer *push* al repositorio remoto**

Cuando el repositorio **Git** local contenga los *changesets* migrados será el momento de hacer *push* de estos al repositorio **Git** remoto. 
Para ello se configurará el `remote` correspondiente y se realizará un `push` de todas las ramas:

```sh
cd /workspace/repository1_git.git
git remote add origin https://git-repo/repository1
git push --all origin
```


[//]: # (Links)
[mercurial-hg]:https://www.mercurial-scm.org
[git]:https://git-scm.com
[tortoise-hg]:https://tortoisehg.bitbucket.io
[tortoise-git]:https://tortoisegit.org
