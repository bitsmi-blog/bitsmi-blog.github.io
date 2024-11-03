---
author: Xavsal
title: OCP7 11 – Hilos (10) – Sincronizadores
date: 2020-05-11
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

El paquete `java.util.concurrent` proporciona cinco clases que ayudan a las expresiones de sincronización con un objetivo común especial.

Las **clases de sincronizador** permiten a lo threads bloquearse hasta que se alcanza un determinado estado o acción.

<!--more-->

## Clases de sincronización

### Semaphore

Es una herramienta de simultaneidad clásica. Mantiene un juego de permisos dónde los threads tratan de adquirir permisos y se pueden bloquear hasta que otros threads liberen permisos.

### CountDownLatch

Utilidad todavía muy simple y muy común para bloquear hilos hasta que se contenga un número determinado de señales, eventos o condiciones.

Permite a uno o más threads esperar (bloquear) hasta la finalización de una cuenta atrás.

Una vez finalizada esta cuenta atrás, todos los threads en espera continúan. No se puede volver a usar una vez utilizado.

### CyclicBarrier

Punto de sincronización multidireccional reajustable útil en algunos estilos de programación paralela.

Se crea un recuento de terceros. Después de llamar a un número de partes (threads) en espera de `CyclicBarrier`, se liberarán (desbloquearán).

Entonces, `CyclicBarrier` se puede volver a usar.

### Phaser

Proporciona una forma más flexible de barrera que se puede usar para controlar el cálculo en fases entre varios _threads_.

### Exchanger

Permite a dos threads intercambiar objetos en un punto de encuentro común y es útil en distintos diseños de pipeline.

Permite realizar el cambio, por ejemplo entre un par de objetos realizando un bloqueo hasta que el intercambio ha finalizado.

Es una alternativa bidireccional de memoria eficaz a `SynchronousQueue`.

## Ejemplo

Es un ejemplo de categoría de sincronizador de clases proporcionada por `java.util.concurrent`.

```java
final CyclicBarrier  barrier = new CyclicBarrier(2);

new Thread() {

    public void run() {
       try{
            System.out.println("before await - thread 1");
            barrier.await();
            System.out.println("before await - thread 2");
         } catch() {
         }
   }
}.start();Copy
```

En este ejemplo para describir su comportamiento, si solo un hilo llama a `await()` en la barrera, dicho hilo se puede bloquear para siempre.

Después de que un segundo thread llame a `await()`, cualquier llamada adicional a `await()` se volverá a bloquear hasta que se alcance el número de hilos necesario.

`CyclicBarrier` contiene un método `await(long timeout, TimeUnit unit)`, que se bloqueará durante una duración especificada y devolverá una excepción `TimeoutException` si alcanza dicha duración.

## Alternativas de Thread de alto nivel

Puede resultar difícil usar las API relacionadas con el Thread tradicional de forma correcta.

Las alternativas incluyen:

- java.util.concurrent.ExecutorService
	- Mecanismo de mayor nivel usado para ejecutar tareas
	- Puede crear y volver a usar objetos de `Thread` para el usuario
	- Permite ejecutar el trabajo y comprobar los resultados en el futuro.
- Marco Fork-Join
	- Servicio de `ExecutorService` de extracción de trabajo especializado nuevo en Java7.
	
Los bloques de código sincronizado se utilizan para garantizar que a los datos que no tienen protección de thread no podrán acceder de forma simultánea varios threads.

Sin embargo, el uso de bloques de código sincronizados puede generar cuellos de botella de rendimiento.

Varios componentes del paquete java.util.concurrent proporcionan alternativas para utilizar bloques de código sincronizados.

Además de aprovechar recopilaciones simultáneas, colas y sincronizadores, existe otra forma de garantizar que a los datos no accederán de manera incorrecta varios threads: simplemente no permitir que varios threads procesen los mismos datos.

En algunos casos, puede ser posible crear varias copias de los datos en RAM y permitir que cualquier thread procese una única cópia.

## Detalle de java.util.concurrent.ExecutorService

`ExecutorService` se utiliza para ejecutar tareas.

- Elimina la necesidad de crear y gestionar threads de forma manual.
- Las tareas se pueden ejecutar en paralelo según la implantación de ExecutorService.
- Las tareas pueden ser:
	- `java.lang.Runnable`
	- `java.util.concurrent.Callable`
- La implantación de instancias se puede obtener con `Executors`.

```java
ExecutorService es = Executors.newCachedThreadPool();
```

### Comportamiento de ExecutorService

Un pool de threads almacenado en caché `ExecutorService`:

- Crea nuevos threads según sea necesario.
- Vuelve a usar sus threads (dichos threads no muere tras la finalización de la tarea).
- Termina los threads que han estado inactivos durante 60 segundos.

Otros tipos de implantaciones de ExecutorService disponibles:

```java
int cpuCOunt = Runtime.getRuntime().availableProcessors();
ExecutorService es = ExecutorsService.newFixedThreadPool(cpuCount);
```

Un pool de threads fijo `ExecutorService`:

- Contine un número fijo de threads.
- Vuelve a usar sus threads (dichos threads no mueren tras la finalización de la tarea).
- Se pone en cola hasta que un thread está disponible.
- Se podría usar para evitar el exceso de trabajo en un sistema con tareas con más uso de CPU.

Así `ExecutorService` siempre intentará usar todas las CPU disponibles en un sistema.

### Cierre de ExecutorService

El cierre de `ExecutorService` es importante porque sus threads son threads de no daemons y evitarán que la JVM se cierre.

```java
// Para la aceptación de nuevos Callable
es.shutdown();

try {
	// Si se desea esperar que las acciones Callable finalicen.
	es.awaitTermination(5, TimeUnit.SECONDS)
} catch(INterruptedException ex) {
	System.out.println("Stopped waiting early.");
}
```

## Detalle de java.util.concurrent.Callable

La interfaz `Callable`:

- Define una tarea ejecutada en `ExecutorService`.
- Es similar en naturaleza a `Runnable`, pero puede:
	- Devolver un resultado mediante genéricos.
	- Devolver una excepción comprobada.
	
```java
package java.util.concurrent;

public interface Callable<V> {
	V call() throws Exception;
}
```

## Detalle de java.util.concurrent.Future

La interfaz `Future` se utiliza para obtener resultados de un método `V call()` de `Callable`.

Tiempos de espera en `Future`: debido a que la llamada a `Future.get()` se bloqueará, debe realizar una de las siguientes acciones

- Envíe todo el trabajo a `ExecutorService` antes de llamar a ningún método `Future.get()`.
- Esté preparado para esperar que `Future` obtenga el resultado.
- Utilice un método no bloqueante como `Future.isDone()` antes de llamar a `Future.get()` o utilice `Future.get(long timeout, TimeUnit unit)`, 
que devolverá una excepción `TimeoutException` si el resultado no está disponible en una duración determinada.

```java
Future<V> future = es.submit(callable);

//  ExecutorService controla cuándo se ha realizado el trabajo. submit many callables
try {
	// Obtiene el resultado del método call de Callable (bloquea si es necesario)
	} catch(ExecutionException | InterruptedException ex) {
	//  Si Callable devuelve una Exception.
}
```