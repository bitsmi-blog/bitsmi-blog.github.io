---
author: Xavier Salvador
title: OCP7 11 – Hilos (05) – Variables atómicas y bloqueos de sincronización
date: 2019-01-07
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

En este artículo se exponen los mecanismos básicos que proporciona la plataforma estándar de Java para el acceso y actualización de variables de forma concurrente.
Se tratarán los siguientes conceptos:

- Uso de variables atómicas
- Acceso a variables mediante bloqueos de sincronización

<!--more-->

## Variables atómicas

El paquete `java.util.concurrent.atomic` contiene clases que soportan la programación con protección de `thread` y bloqueo libre en variables únicas.

La especificación de los métodos proporcionados por las clases de este paquete habilitan en las implementaciones el uso de instrucciones atómicas disponibles en arquitecturas de CPU que soportan una operación de definición y comparación nativa, aunque en algunas plataformas este soporte puede comportar algún tipo de bloqueos internos, por ello, los métodos implementados por las clases de este paquete no garantizan de forma absoluta el no bloqueo.

Las  clases proporcionadas por este paquete proporcionan una operación para la actualización de valores de forma condicional:

```java
boolean compareAndSet(expectedValue, updateValue)
```

Este método actualiza de forma atómica una variable al nuevo valor especificado si esta actualmente contiene el valor de control especificado, retornando true en caso de éxito.

```java
AtomicInteger ai = new AtomicInteger(5);
if(ai.compareAndSet(5, 42)) {
    System.out.println("Replaced 5 with 42");
}
```

El bloque del código `if` detecta mediante una operación atómica que el valor actual sea 5 y a continuación, se defina el valor actual en 42.

La plataforma proporciona contenedores atómicos para valores numéricos **enteros**, **booleanos** y **arrays** de estos, así cómo clases para su uso genérico con referencias o objetos complejos:

- `AtomicBoolean`: Valor booleano que puede ser actualizado de forma atómica
- `AtomicInteger`, `AtomicLong`: Valor numérico entero que puede ser actualizado de forma atómica
- `AtomicIntegerArray`, `AtomicLongArray`: Array de valores numéricos enteros los elementos del cual pueden ser actualizados de forma atómica
- `AtomicReference<V>:` Referencia a un objeto que puede ser actualizada de forma atómica
- `AtomicReferenceArray<E>`: Array de referencias a objetos los elementos del cual pueden ser actualizados de forma atómica
- `AtomicMarkableReference<V>:` Referencia a un objeto acompañada de un bit de marcado que pueden ser actualizados de forma atómica
- `AtomicStampedReference<V>`: Referencia a un objeto acompañada de un valor entero de marcado que pueden ser actualizados de forma atómica

## Bloqueos de sincronización

El paquete `java.util.concurrent.locks` es un marco para bloquear y esperar condiciones que es distinto del resto de mecanismos de monitorización y sincronización de la plataforma. 
Proporciona un grado de flexibilidad superior a estos, pero como contrapartida presenta una dificultad de uso mayor.

Las implementaciones de bloqueos reentrantes permiten a un `thread` que ya adquirido el bloqueo pueda llamar a métodos adicionales que también obtengan el bloqueo sin miedo a que se produzca un bloqueo sobre el mismo.

Se ofrecen dos implementaciones básicas:

- `ReentrantLock`: Implementa una región de exclusión mutua con el mismo comportamiento y semántica que el bloqueo implementado por una región definida por métodos o instrucciones `synchronized`. 
Incorpora algunas características adicionales cómo por ejemplo el garantizar el acceso prioritario a los hilos que lleven más tiempo esperando (**_fairness_**).
- `ReentrantReadWriteLock`: Mantiene un par de bloqueos asociados. Uno para operaciones de sólo lectura y otro para operaciones de escritura. 
Varios `threads` pueden adquirir simultáneamente el bloqueo de lectura pero sólo uno de ellos puede adquirir el bloqueo de escritura, siempre que el bloqueo de escritura no haya  sido activado. 
**El bloqueo de escritura es exclusivo**.

### Ejemplos de utilización

**Región de exclusión mutua**

En el siguiente ejemplo se puede observar la definición y uso de un bloqueo.

```java
class X 
{
  private final ReentrantLock lock = new ReentrantLock(); // (1)
  // ...
 
  public void m() 
  {
    lock.lock();  // (2)
    try {
      // ... (3)
    } finally {
      lock.unlock() // (4)
    }
  }
}
```

En todos los casos los pasos a seguir son:

- 1: Definición del bloqueo.
- 2: Espera para obtener la exclusividad y bloqueo.
- 3: Implementación de la región exclusiva
- 4: Liberación del bloqueo

Además es una buena práctica incluir el código a ejecutar en la exclusión mutua dentro de un bloque try/catch, de forma que se libere siempre el bloqueo en caso de error.

**Bloqueo de lectura / escritura**

En el siguiente ejemplo todos los métodos determinados como de sólo lectura pueden agregar el código necesario para bloquear y desbloquear un bloqueo de lectura.

El objeto `ReentrantReadWriteLock` permite la ejecución simultánea de ambos, un único método de sólo lectura y varios métodos de sólo lectura.

```java
public class ShoppingCart {
  // Bloqueo de un único escritor para varios lectores
  private final ReentrantReadWriteLock rw1 = new ReentrantReadWriteLock();
 
  // ...
 
  // Todos los métodos de sólo lectura se pueden ejecutar de forma simultánea
  public String getSummary() {    
    String summary = null
    rw1.readLock().lock();
    // Modificar la variable summary con el estado del ShoppingCart 
    // summary = ...
    rw1.readLock().unlock();
    return summary;
  }     
 
  public double getTotal () {
    // ...  Otro método de sólo lectura
    double total = null
    rw1.readLock().lock();
    // Modificar la variable total con el estado del ShoppingCart   
    // total = ...
    rw1.readLock().unlock();
    return total;
  }
 
  public void addItem (Object o) {
    rw1.writeLock().lock();
    try{
        /* Modificar el estado del ShoppingCart. Mientras tanto,
         * otros threads no podran actualizar ni acceder a él
         */
    }
    finally{
        rw1.writeLock().unlock();
    }
  }
}
```
