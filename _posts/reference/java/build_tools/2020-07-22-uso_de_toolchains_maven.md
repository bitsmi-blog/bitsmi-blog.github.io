---
author: Antonio Archilla
title: Uso de toolchains Maven
date: 2020-07-22
categories: [ "references", "java", "build tools" ]
tags: [ "java", "maven" ]
layout: post
excerpt_separator: <!--more-->
---

Un ***toolchain*** en **Maven** es un mecanismo que permite a los ***plugins*** que se ejecutan durante las diferentes fases de construcción de un artefacto acceder a un conjunto de herramientas predefinido de forma general. De esta forma se evita que cada uno de ellos deba definir la composición y ubicación de este conjunto de herramientas y se homogeniza para que en todos los casos sea la misma. Habitualmente este mecanismo se utiliza para proporcionar la especificación de la **jdk** que será utilizada en el proceso de construcción en los casos que se deba utilizar una implementación diferente a utilizada para ejecutar el propio **Maven**, pero existe la posibilidad de construir ***toolchains* personalizadas**. El uso de las diferentes tipologías de ***toolchains*** debe estar soportado por los ***plugins*** utilizados. Afortunadamente, ***plugins*** básicos como `maven-compiler-plugin`, `maven-javadoc-plugin`, `maven-surefire-plugin`, entre otros, están diseñados para dar soporte a ***toolchains*** de tipo **jdk**, lo que permite definir procesos de construcción para diferentes implementaciones de **jdk** sin problema.

En este artículo se explicarán los pasos necesarios para definir una ***toolchain*** en la instalación local de **Maven** y de como utilizarla en la construcción de un artefacto.

<!--more-->

## Definición de una *toolchain*

Las ***toolchains*** pueden ser definidas a nivel de instalación local de **Maven** de manera que los detalles de la localización de las herramientas son transparentes a la definición de su uso en un proyecto determinado. Se recomienda realizar esta definición a nivel de usuario en el fichero `${user.home}/.m2/toolchains.xml`, pero también es posible realizarla a nivel global si se edita el fichero `conf/toolchains.xml` dentro del directorio de instalación de **Maven**. 

En el siguiente ejemplo se muestra la definición de **Amazon Corretto 11** que implementa la **jdk 11**.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<toolchains xmlns="http://maven.apache.org/TOOLCHAINS/1.1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xsi:schemaLocation="http://maven.apache.org/TOOLCHAINS/1.1.0 http://maven.apache.org/xsd/toolchains-1.1.0.xsd">
	<toolchain>
		<type>jdk</type>
		<provides>
			<version>11</version>
			<vendor>Amazon</vendor>
		</provides>
		<configuration>
			<jdkHome>c:\jdk\amazon-corretto\jdk11.0.6_10</jdkHome>
		</configuration>
	</toolchain>
</toolchains>
```

Los detalles a destacar de esta configuración son los siguientes:

* Se define en el campo `type` que la tipología de la ***toolchain*** es `jdk`. Los ***plugins*** que quieran hacer uso de ella la referenciaran por este identificador accedera ella.
* Se proporcionan detalles de la implementación, como la `version` y el `vendor`. Estos valores se utilizarán en la configuración de los proyectos para seleccionar la implementación a utilizar para un `type` concreto. Su uso se muestra en el apartado **Uso de una *toolchain* predefinida en un proyecto** de este artículo.
* Se define la ubicación en el sistema local donde se encuentra la ***home*** de la **jdk**.

Adicionalmente, a partir de la versión **Maven 3.3.1** es posible especificar una ubicación cualquiera del fichero de definición `toolchains.xml` utilizando la opción `--global-toolchains <ruta fichero>` al ejecutar **Maven**.


## Uso de una *toolchain* predefinida en un proyecto

Para utilizar una ***toolchain*** especifica en un proyecto basado en **Maven**, se utilizará el ***plugin*** `maven-toolchains-plugin` para especificar la implementación que será utilizada por el resto de ***plugins* compatibles** durante las diferentes fases de la construcción:

```xml
<plugins>
	<plugin>
		<groupId>org.apache.maven.plugins</groupId>
		<artifactId>maven-toolchains-plugin</artifactId>
		<version>3.0.0</version>
		<executions>
		  <execution>
			<goals>
			  <goal>toolchain</goal>
			</goals>
		  </execution>
		</executions>
		<configuration>
		  <toolchains>
			<jdk>
			  <version>11</version>
			  <vendor>Amazon</vendor>
			</jdk>
		  </toolchains>
		</configuration>
	</plugin>
</plugins>
```

Los valores especificados en los campos `version` y `vendor` deberán coincidir con los especificados en la definición de la ***toolchain*** realizada en el apartado anterior. Asimismo, es importante que estos campos se encuentre dentro de los *tags* `<jdk></jdk>`, ya que esto indicará a **Maven** qué tipología de ***toolchain*** deberá escoger.

Una vez especificada la configuración anterior, cada vez que un ***plugin*** requiera de una ***toolchain*** de tipo **jdk** accederá siempre a la implementación indicada, en el ejemplo **Amazon Corretto 11**.
