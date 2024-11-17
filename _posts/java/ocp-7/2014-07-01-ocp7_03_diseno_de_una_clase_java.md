---
author: Antonio Archilla
title: OCP7 03 – Diseño de una clase Java
date: 2014-07-01
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

En este apartado se introducen conceptos relacionados con el diseño de una clase.

<!--more-->

## Modificadores de visibilidad

En Java existen distintos modificadores que afectan a la visibilidad de distintos elementos Java.
La siguiente tabla define los modificadores de acceso existentes para los campos y los métodos que forman una clase.

![](/assets/posts/java/ocp-7/2014-07-01-ocp7_03_diseno_de_una_clase_java_fig1.png)

En este caso, la tabla muestra los modificadores de acceso existentes de una clase.

![](/assets/posts/java/ocp-7/2014-07-01-ocp7_03_diseno_de_una_clase_java_fig2.png)

### Sobrescribir un método: uso y normas

Sobrescribir un método consiste en redefinirlo en una subclase de tal forma que su nombre, número y tipo de parámetros sean iguales a los de la superclase.
Debe coincidir el tipo de retorno o el subtipo de retorno con el del método de la superclase.
En el caso de miembros estáticos de la clase, si se redefine en una subclase éste no es sobrescrito, sino que su implementación se oculta (hidden method). 
Se puede encontrar bastante información detallada en la [documentación oficial de Oracle](http://docs.oracle.com/javase/tutorial/java/IandI/override.html)

### InstanceOf (Conversión de Objetos)

El operador `instanceOf`  permite identificar el tipo de objeto que se está tratando.
Las conversiones en dirección ascendente en la jerarquía de clases siempre están permitidas y no precisan de operador de conversión.
En el caso de las conversiones descendentes el compilador debe considerar que la conversión al menos es posible.
Si se intenta realizar una conversión de clases que no tienen relación de herencia se produce un error de compilación en la JVM.

### Sobreescritura de métodos de la clase Object

La clase `Object` es la superclase de todas las clases Java y no necesita ser indicada la herencia mediante el operador extends de forma explícita.
Contiene tres métodos muy importantes:

- Método `toString`: Este método es llamado si una instancia de nuestra clase es pasada a un método que toma un string  pasándolo al método println y devuelve el nombre de la clase y su dirección de referencia.
Se puede sobrescribir el método para proporcionar información de mayor utilidad.
- Método `equals`: Este método de un objeto devuelve true únicamente si las dos referencias comparadas se refieren al mismo objeto.
Comparar el contenido de dos objetos siempre que sea posible, razón por la que se sobrescribe con frecuencia este método con implementaciones más específicas por parte del programador para demostrar la igualdad entre dos objetos ubicados en memoria.
- Método `hashcode`: Este método se utiliza principalmente para la optimización de colecciones basadas en hash y su sobrescritura debe ir a la par que la sobrescritura del método equals.
No es recomendable crearlo manualmente a no ser que sea absolutamente necesario.
Existen generadores que permiten obtener de forma automática el cuerpo de este método.
