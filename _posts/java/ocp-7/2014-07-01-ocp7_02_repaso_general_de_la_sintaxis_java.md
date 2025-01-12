---
author: Xavsal
title: OCP7 02 – Diseño de una clase Java
date: 2014-07-01
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

<!--more-->

## Estructura de una clase

- El `package` se coloca siempre al principio de un archivo java antes de cualquier declaración dentro de la clase.
- El `import` permite realizar la importación de las clases ubicadas en otros paquetes.
- El término `class` se corresponde con un bloque de código que contiene la declaración de una clase. Precede siempre al nombre de la clase. 
El **nombre de la clase** siempre **debe coincidir** con el **nombre del fichero .java**.
- Los comentarios en Java para bloques de texto se utilizan los carácteres  `/* */`. 
En caso de querer comentar sólo una línea de código se utilizan los caracteres `//`.
- Las **variables miembro** de una clase se **declaran** siempre **dentro de una clase** pero de forma externa al constructor de la clase. 
Java es un lenguaje fuertemente tipado y esto obliga a que las variables deban inicializarse antes de ser utilizadas. En Java **todos los parámetros son pasados por valor**.

## Constructores

- El **nombre del constructor debe coincidir con el nombre de la clase**.
- El constructor **no devuelve ningún valor solamente inicializa** (si así se desea) las variables miembro de la clase.
- Existe un **constructor por defecto** instanciado por el compilador, 
pero también existe el **constructor por parámetro** recibiendo como parámetros los posibles valores para las variables miembro de la clase 
y siendo asignadas a éstas en el cuerpo del constructor por parámetro.
- Toda implementación dentro de un **constructor es estrictamente opcional** dado que ya existe uno proporcionado por defecto por parte del compilador.

El punto de partida para cualquier programa Java que se ejecute des de una línea de comando es el **bloque main**:

```java
public static void main(String[] args) {

}
```

## Tipos de datos primitivos y operadores

En Java existen varios tipos de datos primitivos.  El siguiente cuadro los ilustra:

![](/assets/posts/java/ocp-7/2014-07-01-ocp7_02_repaso_general_de_la_sintaxis_java_fig1.png)

Debe tenerse en cuenta que el compilador  no asigna un valor predeterminado a una variable local por lo que puede producirse un error de compilación si no se asigna manualmente.

Dentro del rango de operaciones que pueden realizarse se contemplan las operaciones matemáticas y las lógicas. El siguiente cuadro ilustra los operadores que se pueden utilizar:

![](/assets/posts/java/ocp-7/2014-07-01-ocp7_02_repaso_general_de_la_sintaxis_java_fig2.png)

## Sentencias de control de flujo

Pueden encontrarse las sentencias for, if…else, do…while, while.

La sentencia `switch`:

![](/assets/posts/java/ocp-7/2014-07-01-ocp7_02_repaso_general_de_la_sintaxis_java_fig3.png)

Evalúa el valor de una variable de tipo `int`, `char` o `String`. Permite una acción u otra según el resultado de una comparación o un valor lógico. 
**Permite también agrupar un mismo resultado para varios case.**

## Programación orientada a objetos

### Paso por valor

En Java **siempre que se trabaja con paso de parámetros por valor** con argumentos de tipo primitivo o referencia **siempre se trabaja con copias de los valores**, nunca con los valores originales. 
De este modo, se asegura la integridad del valor con el que se desea trabajar. En el caso de referencias a objetos, se entiende como valor la propia referencia, no el objeto en si.

### Encapsulación

Consiste en la acción de **ocultar los datos dentro de una clase** y **hacerlos disponibles mediante ciertos métodos**. 
Para obtener la encapsulación correctamente **se hace necesario** aplicar los **modificadores de visibilidad** a la clase, a los campos de la clase y a las declaraciones de los métodos.
En general se llaman métodos asignadores y recuperadores a los métodos que disponen de los valores encapsulados dentro de una clase.

### Herencia

Consiste en un **mecanismo de relación entre clases**. Aunque **cada clase sólo tiene una SUPERCLASE**, existe una clase que se encuentra en la parte superior de la estructura de herencia.

Es la clase `Object`, clase de la que **derivan TODAS las clases Java** y a la que TODOS sus hijos pueden acceder a sus variables miembro y métodos miembro.

La herencia se implementa mediante la palabra clave: `extends <nom_class_padre>`

El mecanismo de herencia permite a los programadores poner miembros comunes en una clase y hacer que otras clases los hereden.

### Polimorfismo

Consiste en la capacidad para hacer referencia a un objeto mediante su forma actual o mediante su superclase.

### Sobrecarga de métodos (overloading)

En Java puede haber varios métodos con el mismo nombre dentro de una misma clase pero con distintos parámetros formales en los métodos. A esto se llama **_overloading_**.
Dentro de una misma clase es posible agrupar varias sobrecargas en Java para disponer de un sólo método pero que puede recibir distintas cargas o parámetros.

El mecanismo que permite la sobrecarga se llama **varargs (o argumentos variables)** y permite escribir un método más génerico del tipo siguiente

```java
public int sum (int… nums)
```

Dónde `nums` es un objeto array de tipo entero.
A nivel de JVM, el compilador siempre prefiere utilizar un método que contenga tipos de parámetros a los cuáles podamos convertir los tipos de argumentos utilizados 
en la llamada que utilizar un método que acepte argumentos variables.
