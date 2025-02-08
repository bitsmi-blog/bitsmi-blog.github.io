---
author: Xavier Salvador
title: Adaptación de librería java-json.jar a JAVA 1.4
date: 2015-06-16
categories: [ "references", "java", "libraries" ]
tags: [ "java", "json" ]
layout: post
excerpt_separator: <!--more-->
---

Una de las limitaciones más comunes a la hora de programar es la versión del jdk que requiere nuestra aplicación. Cuando los requerimientos exigen una versión un tanto antigua (1.4 por ejemplo), 
encontramos problemas a la hora de usar tecnologías como AJAX, sobretodo si necesitamos utilizar respuestas de tipo JSON. 
Para ello existe una librería muy simple «java-json.jar» pero nos encontramos de que es incompatible con el jdk 1.4.

Aquí explicaré en pocos pasos como adaptar y recompilar esta librería para hacerla compatible y funcional para una aplicación que use un jdk 1.4. 
Necesitaremos descargar el código fuente de la librería y modificar unos pequeños detalles de las clases que contiene.

Se puede descargar el código fuente de [aquí](https://github.com/douglascrockford/JSON-java/archive/master.zip)

<!--more-->

## Procedimiento

Primero importaremos el código a nuestro IDE (en este caso uso Eclipse Juno) . Crearemos un proyecto Java.

![](/assets/posts/reference/java/libraries/2015-06-16-adaptacion_libreria_java-json.jar_a_java_1_4_fig1.png)

Y definimos la versión del jdk que usaremos como jdk_4_2_19

![](/assets/posts/reference/java/libraries/2015-06-16-adaptacion_libreria_java-json.jar_a_java_1_4_fig2.png)

Una vez tenemos nuestro proyecto creado, importaremos las clases de la librería que vamos a refactorizar. Para eso vamos a Archivo -> importar -> File System

![](/assets/posts/reference/java/libraries/2015-06-16-adaptacion_libreria_java-json.jar_a_java_1_4_fig3.png)

Y seleccionamos la carpeta donde tenemos las clases descargadas.

Una vez tenemos las clases importadas, abrimos una de estas clases y miramos el «package» donde debería estar incluida la clase.

![](/assets/posts/reference/java/libraries/2015-06-16-adaptacion_libreria_java-json.jar_a_java_1_4_fig4.png)

Creamos en nuestro proyecto este package y movemos todas las clases a este package

![](/assets/posts/reference/java/libraries/2015-06-16-adaptacion_libreria_java-json.jar_a_java_1_4_fig5.png)

Ahora comprobaremos que las clases muestran errores, esto es lo que debemos corregir.

- Cambiamos la utilización de la clase «StringBuilder» por `StringBuffer`

![](/assets/posts/reference/java/libraries/2015-06-16-adaptacion_libreria_java-json.jar_a_java_1_4_fig6.png)

- Eliminamos las parametrizaciones de las clases «Iterator», «ArrayList», «Set», «Collection», «Enumeration», «Map» i «HashMap»

![](/assets/posts/reference/java/libraries/2015-06-16-adaptacion_libreria_java-json.jar_a_java_1_4_fig7.png)

- Al eliminar la parametrización, deberemos añadir unos «casts» ya que al no estar parametrizados, ahora todos seran «Object».

![](/assets/posts/reference/java/libraries/2015-06-16-adaptacion_libreria_java-json.jar_a_java_1_4_fig8.png)

- Eliminamos las anotaciones.

![](/assets/posts/reference/java/libraries/2015-06-16-adaptacion_libreria_java-json.jar_a_java_1_4_fig9.png)

- Las operaciones de suma entre objetos se deben modificar para que sean entre tipos primitivos, ya que la suma entre objetos no está soportada.

![](/assets/posts/reference/java/libraries/2015-06-16-adaptacion_libreria_java-json.jar_a_java_1_4_fig10.png)

![](/assets/posts/reference/java/libraries/2015-06-16-adaptacion_libreria_java-json.jar_a_java_1_4_fig11.png)

- Modificamos las asignaciones directas de tipos primitivos a clases por una instanciación de la propia clase.

![](/assets/posts/reference/java/libraries/2015-06-16-adaptacion_libreria_java-json.jar_a_java_1_4_fig12.png)

Una vez nuestro proyecto esta corregido sin errores, encapsulamos de nuevo todas las clases en un nuevo archivo .jar compilado con el jdk 1.4. 
Para esto, clickamos sobre el package `org.json` con el botón derecho del ratón y selecionamos `export -> Java-> Jar file`.

![](/assets/posts/reference/java/libraries/2015-06-16-adaptacion_libreria_java-json.jar_a_java_1_4_fig13.png)

Finalmente, clickamos a «Finish» y tenemos nuestra librería compilada y totalmente funcional para Java 1.4.

![](/assets/posts/reference/java/libraries/2015-06-16-adaptacion_libreria_java-json.jar_a_java_1_4_fig14.png)
