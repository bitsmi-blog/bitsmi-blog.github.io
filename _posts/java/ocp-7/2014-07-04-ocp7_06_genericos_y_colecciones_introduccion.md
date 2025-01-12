---
author: Xavsal
title: OCP7 06 – Genéricos y colecciones – Introducción
date: 2014-07-04
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

<!--more-->

## Tipos de Genéricos

Los objetos genéricos se describen de forma abstracta mediante la siguiente notación:

```
Objetos Genéricos <T>
```

Por convención en Java dentro del **operador diamante** se ha establecido la siguiente convención:

- T – Tipo
- E – Elemento
- K – Key
- V – Valor
- S, U – Se emplea si hay 2, 3 o más tipos definidos.

El Operador Diamante es `<..>` y permite evitar el uso del tipo genérico T en la construcción de un objeto dado que a partir de su declaración se infiere el tipo `T` asociado. 
Además, el operador simplifica y mejora la lectura del código fuente.

## Tipos de Colecciones

Una **colección** es un **objeto único que maneja un grupo de objetos**. A esta agrupación de objetos también les llamamos **elementos**, tienen operaciones de inserción, borrado y consulta.

El _framework_ de **colecciones** en Java es un arquitectura unificada que representa y maneja las colecciones independientemente de los detalles de implementación. 
Implementan pilas, colas, etc… y sus clases se almacenan en `java.util`.

![](/assets/posts/java/ocp-7/2014-07-04-ocp7_06_genericos_y_colecciones_introduccion_fig1.png)

### List

Una lista es una **interfaz** que define el comportamiento de una lista genérica. **Colección ordenada** en que **cada elemento ocupa una posición identificada por un índice**. 
Las listas crecen de forma dinámica. Se pueden añadir, eliminar, sobrescribir elementos existentes, y se permiten elementos duplicados.

```java
List<T> lista = new ArrayList<>(3)
```

Un `ArrayList` es la implementación más conocida de una `Collection`, aunque también existen `LinkedList` y otras implementacions no detalladas en este post. 
En este enlace se puede profundizar en su conocimiento de forma más exahustiva.

### Set

Además de `List` existe otra interfície que deriva de `Collection` llamada `Set` cuyas implementaciones más conocidas son `Hashset` y `TreeSet` (implementación ésta de la interfaz `SortedSet`).

### Queue

Existe una tercera interfaz que también deriva de `Collection` llamada `Queue`. En este enlace puede encontrarse información más detallada.

Para un mayor detalle y nivel de profundidad respecto a la clase Collections de Oracle, puede consultarse su documentación oficial online en este [enlace](http://docs.oracle.com/javase/7/docs/api/java/util/Collection.html) para el JDK 7.

## Autoboxing & Unboxing

Los tipos primitivos (`int`, `float`, `double`, etc…..) usados en Java no forman parte de su jerarquía de clases por cuestiones de eficiencia.
Java permite un mecanismo de envoltura llamado `Wrapper` para poder encapsular un tipo primitivo en un objeto. 
Una vez encapsulado dicho tipo primitivo, su valor puede ser recuperado mediante los métodos asociados a la clase de envoltura. Nomenclatura de los procesos:

- **_AutoBoxing_**: Encapsular el valor de un tipo primitivo en un objeto `Wrapper`.
- **_Unboxing_**: Extraer el valor de un tipo primitivo de un objeto `Wrapper`.

Su utilización simplifica la sintaxis y produce código más limpio y legible para los programadores.

Ejemplo de **_Autoboxing_** & **_Unboxing_**: 

```java
import java.util.ArrayList;
import java.util.List;
 
public class UnboxingAndAutoboxing {
    public static void main(String[] args) {
        //  Autoboxing
        int inNumber=50; 
        Integer a2 = new Integer(a);  //Boxing 
        Integer a3 = 5;               //Boxing 
        System.out.println(a2+" "+a3);
        // Unboxing
        Integer i = new Integer(-8);
        // 1. Unboxing through method invocation
        int absVal = absoluteValue(i);
        System.out.println("absolute value of " + i + " = " + absVal);
        List<Double> ld = new ArrayList<>();
        ld.add(3.1416);    // Π is autoboxed through method invocation.
 
        // 2. Unboxing through assignment
        double pi = ld.get(0);
        System.out.println("pi = " + pi);
    }
 
    public static int absoluteValue(int i) {
        return (i < 0) ? -i : i;
    }
}
```
