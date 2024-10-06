---
author: Xavsal
title: OCP7 11 – Hilos (04) – ReentrantReadWriteLock
date: 2020-04-22
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

**Nota:** Los ejemplos mostrados en este artículo suponen la utilización de arquitecturas de **CPU** que soportan operaciones de definición y comparación atómicas (operaciones Compare And Swap), 
como por ejemplo los procesadores x86 o Sparc actuales. En este caso las operaciones **lock / unlock** serán operaciones no bloqueantes. 
Otras arquitecturas que no soporten esta funcionalidad pueden requerir alguna forma de bloqueo interno por parte de la plataforma.

## Paquete java.util.concurrent.locks

El paquete `java.util.concurrent.locks` es un marco para bloquear y esperar condiciones que es distinto de las supervisiones y sincronización incorporadas.

<!--more-->

## Bloqueo de varios lectores y un único escritor

```java
 public class ShoppingCart {
    private final ReentrantReadWriteLock rw1 = new ReentrantReadWriteLock();

    public void addItem (Object o) {

    rw1.writeLock().lock();
    //  source code to modify shopping cart
    rw1.writeLock().unlock();
    }
}  // End class ShoppingCart
```	

El código fuente en `main()` que implementa el bloqueo y el desbloqueo es el siguiente junto con el código fuente para realizar las modificaciones del shopping cart:

```java
rw1.writeLock().lock();
//  source code to modify shopping cart
rw1.writeLock().unlock();
```

realizando el bloqueo de escritura.

Describiendo un poco todo lo documentado, una de la funciones del paquete `java.util.concurrent.locks` es la implantación de un bloqueo de varios lectores con un único escritor.

Es posible que un `thread` no tenga ni obtenga un bloqueo de lectura mientras está en uso el bloqueo de escritura.

Varios `threads` pueden adquirir simultáneamente el bloqueo de lectura pero sólo uno de ellos puede adquirir el bloqueo de escritura (n -lecturas <-> 1 escritura).

El bloqueo es **reentrante**: un `thread` que ya adquirido el bloqueo de escritura puede llamar a métodos adicionales que también obtengan el bloqueo de escritura sin miedo a que se produzca un bloqueo.

## Bloqueo de lectura (sin ningún escritor)

Ejemplo dónde se muestra como los métodos de lectura son concurrentes:

```java
public class ShoppingCart {
	public String getSummary() {
		String s = "";
		rw1.readLock().lock();
		//  Source code to read cart, modify s
		rw1.readLock().unlock();
		return s;
	}

	//  Todos los métodos de sólo lectura se pueden ejecutar de forma simultánea
	public double getTotal () {
		//  another read-only method
	}
}   //  End class ShoppingCart
```

En el ejemplo todos los métodos determinados como de sólo lectura pueden agregar el código necesario para bloquear y desbloquear un bloqueo de lectura.

`ReentrantReadWriteLock` permite la ejecución simultánea de ambos, dónde puede ejecutar un único método de sólo lectura o varios métodos de sólo lectura concurrentes.

