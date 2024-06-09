---
author: Antonio Archilla
title: Java Platform Debug Architecture
date: 2020-05-05
categories: [ "references", "java", "jvm" ]
tags: [ "java" ]
layout: post
excerpt_separator: <!--more-->
---

La **Java Platform Debug Architecture** o **JPDA** es la arquitectura que implementa los mecanismos de *debug* dentro de la JVM. Se trata de una arquitectura multicapa formada por varios componentes:

* **Java Debug Interface (JDI)**: Define la interfaz necesaria para implementar *debuggers* que se conectarán a la JVM a fin de enviar las diferentes ordenes que se produzcan durante la sesión de *debug*. Las funcionalidades de *debug* de los diferentes IDE son ejemplos de *front-end* que implementan esta interfaz.
* **Java VM Tooling Interface (JVM TI)**: Define los servicios que permiten **instrumentalizar la JVM**. Esto va desde la monitorización, la manipulación de código en caliente, la gestión de *threads* de ejecución, el *debug* de código y otras muchas funciones más. Todo ello se consigue mediante el uso de los denominados ***agents* nativos** que es especifican durante el **arranque de la JVM** mediante el *flag* `-agentlib:<nombre librería>`. En el caso concreto del *debug*, se utiliza el **JWPD *agent*** para procesar las peticiones que se envían desde el **front-end** del *debugger*. Los servicios implementados por el **JWPD *agent*** en esta capa forman el **back-end** del *debugger* que se conecta directamente con el proceso en ejecución de la JVM que está siendo *debugado*.
* **Java Debug Protocol (JDWP)**: Define el protocolo de comunicación entre los procesos *front-end* y el *back-end* del *debugger* a través de varios canales de comunicación que incluyen *socket* y memoria compartida. 
	
En este artículo se muestra una visión práctica de como **configurar la conexión a la JVM** para poder las depurar aplicaciones que se ejecuten sobre ella.

<!--more-->

## JPDA en la práctica

En **Java 5** se introdujo la actual forma de iniciar el **JWPD *agent*** mediante el *flag* `-agentlib:jdwp` especificado como opción en el arranque de la JVM. Este *flag* admite diferentes opciones que permiten configurar la conexión de *debug*. Cada una de ellas se especificará en el mismo *flag* utilizando ',' como separador:

* `transport`: Canal de comunicación utilizado para la conexión entre el *front-end* y el *back-end* del *debugger*. Puede tomar los valores `dt_socket` para conexión mediante *socket* o `dt_shmem` para hacerlo mediante una región de memoria compartida. En este último caso los procesos *front-end* y *back-end* deben ejecutarse en la misma máquina. La opción mas común es `dt_socket`.
* `server`: (Opcional). Indica si ja JVM quedará a la espera de conexión por parte de un *debugger* externo (`y`) o si será la **JVM** quien inicie la conexión a la dirección especificada en la opción `address` actuando como cliente (`n`). La opción más habitual es especificar el comportamiento de servidor, ya que normalmente es el *debugger* externo quien se conecta a la JVM.
* `suspend`: (Opcional). Indica si la JVM una vez inicializada suspende todos los hilos de ejecución (`y`) o prosigue con la ejecución normal (`n`). El valor por defecto es `y`, por lo que para asegurar la ejecución de la aplicación se debe especificar explícitamente el valor `y`.
* `address`: (Opcional en caso de `server=n`). Indicará la dirección para escucha de conexiones remotas en caso de `server=n` o la dirección a la que el `back-end` intentará conectarse en caso de actuar como cliente con `server=s`.

A continuación se especifica la forma de establecer los valores para dichas opciones dependiendo de la versión de la JVM que se esté utilizando.

#### JDK 8 o anterior

El siguiente ejemplo ejecuta la aplicación `Application` estableciendo el *debug* tanto local como remoto a través del puerto `8001`:

```sh
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8001 Application
```

Si todo ha ido bien, la máquina virtual reportará el mensaje `Listening for transport dt_socket at address: 8001` que indicará que el **JWPD *agent*** se ha iniciado correctamente y se encuentra a la espera de conexiones en el puerto especificado.

Si sólo se desea permitir conexiones locales, explícitamente se debe especificar la IP de localhost `127.0.0.1` en el parámetro `address`:

```sh
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=127.0.0.1:8001 Application
```

Es importante remarcar la necesidad de acotar el acceso al puerto expuesto para las conexiones remotas. En este caso se debe establecer un control a nivel de sistema operativo, por ejemplo mediante **firewall**, para que sólo se pueda acceder a él desde orígenes permitidos.
 

#### JDK 9 o posterior

A partir de **Java 9** se introdujo la necesidad de especificar explícitamente el filtro de las direcciones locales o remotas a las que se permite establecer conexión con el **JWPD *agent***. Por defecto el **JWPD *agent*** escucha solo conexiones locales con **localhost** como origen, rechazando así toda conexión remota que provenga de otras interfaces de red. En el siguiente ejemplo se configura al escucha para procesos de *debug* locales a través del puerto `8001`

```sh
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8001 Application
```

Para permitir el *debug* remoto se debe especificar un *hostname* especifico en la opción `address` o bien el filtro `*` para permitir todas la conexiones:

```sh
# Permitir solo conexiones provenientes de la dirección 192.168.1.10
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=192.168.1.10:8001 Application

# Permitir conexiones de cualquier dirección
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:8001 Application
```

Especificar un valor de la opción `address` como en el ejemplo anterior, utilizando el filtro de direcciones `*` para una JVM 8 o inferior provocará un error en la inicialización de la aplicación. Direcciones del tipo `*:<puerto>` solo son posibles en la versión 9 o posterior.


## Referencias

* [Especificación arquitectura JPDA][jpda-architecture]

[//]: # (Links)
[jpda-architecture]:https://docs.oracle.com/javase/9/docs/specs/jpda/architecture.html
