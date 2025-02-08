---
author: Xavier Salvador
title: OCP7 11 – Hilos (06) – Colecciones con protección de Thread	
date: 2018-12-30
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

En general las colecciones de java.util no tienen protección de **thread**. Para poder utilizar colecciones en modo de protección de **thread** se debe utilizar uno de los siguientes mecanismos:

* Utilizar bloques de código sincronizado para todos los accesos a una colección si se realizan escrituras.
* Crear un envoltorio sincronizado mediante métodos de biblioteca  como `java.util.Collections.synchronizedList(List<T>)`. 
Es importante destacar que el hecho de que una Collection se cree con protección thread no hace que sus elementos dispongan de la misma protección de **thread**.
* Utilizar colecciones dentro de java.util.concurrent.

<!--more-->

## Collecciones _thread safe_

La clase `ConcurrentLinkedQueue` proporciona una **cola FIFO** no bloqueante con protección de **thread** escalable eficaz.

Adicionalmente existen cinco implementaciones en `java.util.concurrent` que también soportan la interfaz ampliada `BlockingQueue` que define las versiones de bloqueo de colocación y captura:

* [LinkedBlockingQueue](https://docs.oracle.com/javase/7/docs/api/java/util/concurrent/LinkedBlockingQueue.html)
* [ArrayBlockingQueue](https://docs.oracle.com/javase/7/docs/api/java/util/concurrent/ArrayBlockingQueue.html)
* [SynchronousQueue](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/SynchronousQueue.html)
* [PriorityBlockingQueue](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/PriorityBlockingQueue.html)
* [DelayQueue](https://docs.oracle.com/javase/7/docs/api/java/util/concurrent/DelayQueue.html)

Ademas de las colas, este paquete proporciona implementaciones de `Collection` diseñadas para su uso  en contextos multihilo siguientes:

* [ConcurrentHashMap](https://docs.oracle.com/javase/7/docs/api/java/util/concurrent/ConcurrentHashMap.html)
* [ConcurrentSkipListMap](https://docs.oracle.com/javase/7/docs/api/java/util/concurrent/ConcurrentSkipListMap.html)
* [ConcurrentSkipListSet](https://docs.oracle.com/javase/7/docs/api/java/util/concurrent/ConcurrentSkipListSet.html)
* [CopyOnWriteArrayList](https://docs.oracle.com/javase/7/docs/api/java/util/concurrent/CopyOnWriteArrayList.html)
* [CopyOnWriteArraySet](https://docs.oracle.com/javase/7/docs/api/java/util/concurrent/CopyOnWriteArraySet.html)

Cuándo se espera que muchos **threads** accedan a la colección proporcionada, normalmente se prefiere

* `ConcurrentHashMap` a `HashMap` sincronizado.
* `ConcurrentSkipListMap` a `TreeMap` sincronizado.

Cuándo el número esperado de lecturas y transversales supera en gran medida el número de actualizaciones en una lista se prefiere

* `CopyOnWriteArrayList` a `ArrayList` sincronizado .