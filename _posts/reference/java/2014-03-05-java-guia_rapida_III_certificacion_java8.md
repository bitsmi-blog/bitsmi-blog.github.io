---
author: Xavsal
title: Java – Guía rápida – 3ª parte - Certificación Java 8
date: 2014-03-05
categories: [ "references", "java" ]
tags: [ "reference", "java" ]
layout: post
excerpt_separator: <!--more-->
---

<!--more-->

## Colecciones (Gran resumen)

![](/assets/posts/reference/java/2014-03-05-java-guia_rapida_III_fig1.jpg)

### Map

- Asociación de claves-valor.
- No puede contener claves duplicadas.
- Cada clave sólo puede tener asociado un valor como máximo.

#### Implementaciones de Map

Ninguna de las implementaciones es sincronizada aunque existen métodos que actúan como Wrapper (envoltorio) para implementar la sincronización.

##### HashMap

- Almacenamiento de las claves en una tabla Hash.
- Mejor rendimiento sin asegurar el orden durante las iteraciones.
- Importante definir previamente el tamaño para obtener un buen rendimiento.

##### TreeMap

- Almacenamiento de las claves según sus valores.
- Más lento que HashMap.
- Las claves deben implementar la interfaz Comparable.

##### LinkedHashMap

- Almacenamiento de las claves según el orden de inserción.

### List

- Interfaz que define una suceción de elementos.
- Permite contener elementos duplicados.
- Amplía la funcionalidad base añadiendo métodos que:
	- Permiten manipular un elemento concreto según su posición en la lista.
	- Permiten buscar un elemento concreto y recuperar su posición.
	- Permiten iterar sobre los elementos de la lista.
	- Permiten realizar operaciones sobre rangos de elementos.

De forma similar a `Set`, no son implementaciones sincronizadas y existen también métodos actuando como Wrapper (envoltorio) que permiten de dotar de sincronización a estas implementaciones.

#### Implementaciones de List

##### ArrayList

- Array redimensionable que incrementa su tamaño según crecen los elementos que contiene.
- Mejor rendimiento.

##### LinkedList

- Lista doblemente enlazada de los elmentos conteniendo cada uno de los elementos: un puntero al anterior elemento y un puntero al siguiente elemento.

### Set

- Interfaz que define una colección que no puede tener elementos duplicados.
- Para verificar la igualdad de 2 set iguales se comprueban todos los elementos que los componen y que sean iguales todos.

#### Implementaciones de Set

- Todas sus implementaciones son no sincronizadas.
- Existen métodos que permiten dotar de sincronización a las colecciones mediante un Wrapper (ampliar).

##### HashSet

- Almacenamiento de los valores en una tabla Hash.
- Implementación con mejor rendimiento sin asegurar el orden de as iteraciones (no importa el orden en esta implementación).
- Importante definir el tamaño inicial de la tabla hash dado que será lo que marcará el rendimiento.

##### TreeSet

- Añade ordenación en función de sus valores.
- Los elementos almacenados deben implementar la interfaz Comparable.

##### LinkedHashSet

- Más costosa que `HashSet`.
- Almacena los elementos según el orden de inserción.

## Sort

En Java 8 ya no es necesario implementar Comparable en la clase dónde se utilice pues ahora Sort se implementa como una interfície funcional.

Para realizar el compare será suficiente un código como el siguiente:

```java
values.sort((o1, o2) -> o1.compareTo(o2));
```

## Optional

- Javadoc: https://docs.oracle.com/javase/8/docs/api/java/util/Optional.html
- Ejemplos: https://www.baeldung.com/java-optional

Ejemplo rápido:

```java
package echo;

import java.util.Optional;
import java.util.function.Supplier;

public class OptionalJava8Tester {

    public static void main(String args[]) {

        OptionalJava8Tester java8Tester = new OptionalJava8Tester();

        Integer value1 = null;
        Integer value2 = new Integer(10);

        // Optional.ofNullable - allows passed parameter to be null.
        Optional<Integer> a = Optional.ofNullable(value1);

        // Optional.of - throws NullPointerException if passed parameter is null
        Optional<Integer> b = Optional.of(value2);
        System.out.println(java8Tester.sum(a, b));

    }

    public Integer sum(Optional<Integer> a, Optional<Integer> b) {

        Integer valueAOrigin = 0;
        Integer valueBOrigin = 0;

        // Optional.isPresent - checks the value is present or not - Just information
        System.out.println("First parameter is present: " + a.isPresent());
        System.out.println("Second parameter is present: " + b.isPresent());

        if(a.isPresent() && b.isPresent()) {

            // Optional.orElse - returns the value if present otherwise returns
            // the default value passed.    
            valueAOrigin = a.orElse(new Integer(0));

            // Optional.get - gets the value, value should be present
            valueBOrigin = b.get();

        } else {

            System.out.println("One of the values i zero. Check a and b values received. A: "+a.isPresent()+" B: " + b.isPresent());
        }

        return valueAOrigin + valueBOrigin;
    }
}
```

## Streams

Ejemplo práctico:

```java
private Details checkNoCarriersList(AirPriceRsp airPriceRsp) throws Exception {

List<AirIti> airItis = (List<AirIti>) airPriceRsp.getAirIti();

List<AirIti> airItisFiltered = airItis.stream()
        .filter(iti ->
             iti.getAirSeg().stream().anyMatch(
                typeBaseAirSeg ->
                     !traportConfigService.getNoCashCarriers().getCarriers().contains(typeBaseAirSeg.getCarrier()))).collect(Collectors.toList());

airPriceRsp.setAirIti((com.traport.schema.air_v62_0.AirIti)airItisFiltered);

return detailsProvidBuilder.build(airPriceRsp);
}
```
