---
author: Xavier Salvador
title: Variables de entorno para OC4J
date: 2014-04-11
categories: [ "references", "java", "application servers", "oc4j" ]
tags: [ "java", "oc4j" ]
layout: post
excerpt_separator: <!--more-->
---

Para realizar la instalación de un **servidor de aplicaciones OC4J** en un entorno **Windows** es necesario habilitar las siguientes **variables de entorno** para obtener una instalación correcta y estable.

La variables a definir son las siguientes:

* J2EE_HOME
	* Valor: `<Directorio_Instalacion_OC4j>/OC4J_TRUNK/j2ee/home`
	* Descripción: Opcional. Acceso a los ficheros oc4j.jar y admin.jar. Estableciendo estas variables  podrán invocarse estos Jars des de cualquier directorio.
* OC4J_JVM_ARGS
	* Valor: -XX:PermSize=256m -XX:MaxPermSize=256m -Xms512m -Xmx768m
	* Descripción: Obligatoria. Pueden agregarse cualquier tipo de parámetros a la máquina virtual de Java al iniciar el servidor.  
	En el caso de ejemplo se aumenta la  memoria  reservada para el cargador de clases `-XX:PermSize=256m -XX:MaxPermSize=256m` y para la para la pila `-Xms512m -Xmx768m`
* ORACLE_HOME
	* Valor: `<Directorio_Instalacion_OC4j>/OC4J_TRUNK`. Dentro del Path del sistema debe incluirse el siguiente valor `%ORACLE_HOME%bin;` 
	permitiendo el arranque y parada del servidor des de la consola de comandos de Windows.
	* Descripción: Obligatoria. Apunta al directorio raíz de la instalación del OC4J. Es obligatorio definir esta variable si se desea ejecutar un script ejecutable del servidor mediante el fichero OC4J.	
	