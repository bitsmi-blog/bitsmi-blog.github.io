---
author: Xavier Salvador
title: OCP7 05 – Herencia en las interfaces Java
date: 2014-07-01
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

## Uso de las interfaces Java

Una interfaz representa **una alternativa a la herencia multiple de objetos**.
Son similares a las clases abstractas ya que **contienen únicamente métodos públicos y abstractos**.
Ninguno de sus métodos pueden ser implementados (ni siquiera con un conjunto vacío de llaves).
La declaración de una interfaz es similar a la declaración de una clase.
Se usa la palabra reservada interface.
Para la implementación de una interface se añade implements a la clase que implementa la interfaz.
Una interfaz puede utilizarse como un tipo de referencia. Puede utilizarse el operador instanceof con las interfaces para detectar si un objeto es del tipo de referencia indicado por la interfície implementada.
Interfaces de Marcador: definen un tipo concreto pero no describen  los métodos que deben ser implementados por una clase, sólo sirven para la comprobación de tipos.

Existen dos tipos:

-  `java.io.Serializable` és una interfaz de marcador utilizado por la biblioteca de E/S de Java para determinar si un objeto puede tener su estado serializado.

## Como convertir de un tipo de dato al tipo de la interfaz

Antes de generar una excepción en la conversión de tipos de unos objetos a otros objetos se comprueba que dicha conversión sea posible mediante la utilización del operador instanceof (ya comentado anteriormente).

En general, cuándo se utilicen referencias, éstas deben utilizar el tipo más genérico posible, es decir, que sirvan para cualquier tipo de interfaz o clase padre. Así la referencia no se vincula a una clase particular.

Una clase puede heredar de una clase padre e implementar una o varias interfaces pero siempre en este orden: primero hereda – extends – y después implementa – implements – separando las interfaces mediante comas.

Una interfaz puede heredar de otra interfaz. Java no permite la herencia múltiple de clases pero sí la herencia múltiple de interfaces:

![](/assets/posts/java/ocp-7/2014-07-01-ocp7_05_herencia_en_las_interfaces_java_fig1.png)

Si escribimos una clase que hereda de una **clase que implementa una interfaz**, entonces la **clase que estamos escribiendo hereda también de dicha interfaz**. 
La refactorización consiste en realizar modificaciones en el código para mejorar su estructura interna sin alterar su comportamiento externo.

## Composición

Este patrón de diseño permite la **creación de objetos más complejos a partir de objetos más simples. Se crea una nueva clase con referencias a otras clases.** 
A esta nueva clase le agregaremos los mismos métodos que tienen las demás clases.

```java
public class ComplexClass {
    private Single1 c1 = new Single1();
    private Single2 c2 = new Single2();
    private Single3 c3 = new Single3();
}
```

## Referencia al polimorfismo

Vamos a describir un ejemplo de polimorfismo. Si existe una clase nueva llamada Hombre que dispone  de un método addCoche con la configuración de clases establecida en la siguiente imagen:

![](/assets/posts/java/ocp-7/2014-07-01-ocp7_05_herencia_en_las_interfaces_java_fig2.png)

No se le puede pasar como argumento al método addCoche de Hombre cualquier tipo de coche.
**Solución**: Para soportar el polimorfismo en las composiciones cada clase usada en la composición debe disponer de una interfaz definida y así se le podrá pasar cualquier tipo de coche al método en cuestión.

![](/assets/posts/java/ocp-7/2014-07-01-ocp7_05_herencia_en_las_interfaces_java_fig3.png)

