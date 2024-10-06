---
author: Antonio Archilla
title: OCP7 11 – Hilos (01) – Introducción
date: 2014-06-20
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

En este apartado se exponen los conceptos básicos referentes del diseño de programas concurrentes y paralelos 
y los mecanismos que la especificación estándar de Java pone a disposición del programador para conseguirlo.

Se tratarán los siguientes conceptos:

* Cómo el sistema operativo gestiona los procesos e hilos.
* Ciclo de vida de un hilo de ejecución.
* Sincronización y comunicación de datos entre hilos de ejecución.

<!--more-->

## Gestión de procesos e hilos

La **Multitarea** se describe cómo la habilidad de ejecutar varias tareas aparentemente al mismo tiempo compartiendo uno o varios procesadores. 

Existen dos tipos de tareas:

* **Procesos**: Conjunto de instrucciones de código que se ejecutan secuencialmente y que tiene asociados un estado y recursos de sistema (espacio de memoria, punteros a disco, recursos de red…).
* **Hilos de ejecución**: También llamado proceso ligero, es un flujo de ejecución secuencial dentro de un proceso. En un proceso se pueden estar ejecutando uno o más hilos de ejecución a la vez. 
Los hilos permiten evitar **los cuellos de botella** en el rendimiento del sistema. 
Su origen puede venir determinado por varias razones: bloqueo de operaciones de E/S, bajo uso de CPU o debido al **recurso contencioso**, 
consistente en que dos o más tareas queden a la espera del uso exclusivo de un recurso.

El **planificador** es el componente de los **sistemas multitarea y multiproceso** encargado de repartir el tiempo de ejecución de un procesador entre los diferentes 
procesos que estén disponibles para su ejecución.

En los sistemas operativos de propósito general, existen tres tipos de planificadores:

* **Planificador a corto plazo**: Planificador encargado de repartir el tiempo de proceso entre los procesos que se encuentran en memoria principal en un momento determinado.
* **Planificador a mediano plazo**: Relacionado con aquellos procesos que no se encuentran en memoria principal. Se encarga de mover procesos entre memoria principal y la memoria de Swap (Disco).
* **Planificador a largo plazo**: Planificador encargado del ciclo de vida de los procesos, desde que son creados en el sistema hasta su finalización.

Existen diferentes políticas de planificación con multitud de variaciones y especializaciones que permiten ser utilizadas para diferentes propósitos. En el apartado de referencias se encuentran enlaces a las explicaciones de algunas de ellas.

**Paralelismo**

Se definen como procesos paralelos aquellos que se ejecutan en el mismo instante de tiempo, debido a esto, este tipo de computación sólo es posible en sistema multiprocesador.

**Concurrencia**

Se definen como procesos concurrentes aquellos que se ejecutan en un mismo intervalo de tiempo pero no necesariamente de forma simultánea. A diferencia del paralelismo, este tipo de computación se puede realizar en sistema monoprocesador alternando la ejecución de las 2 tareas. En la siguiente imagen se puede observar esta diferencia.

![](/assets/posts/java/ocp-7/2014-06-20-ocp7_11_hilos_01_introduccion_fig1.jpg)

Existe un método en java que permite obtener el número de procesadores disponibles en un sistema:

```java
int countProcessors = Runtime.getRuntime().availableProcessors();
```

## Ciclo de vida de un hilo de ejecución

El ciclo de vida de un hilo de ejecución representa los estados por los que este pasa desde que es creado hasta que completa su tarea o finaliza su por otra razón, cómo por ejemplo porque se produce un error que lo interrumpe.

![](/assets/posts/java/ocp-7/2014-06-20-ocp7_11_hilos_01_introduccion_fig2.jpg)

Se pueden enumerar los siguientes estados:

* **Nuevo (new)**: En el momento en que se crea un nuevo **Thread**, este se sitúa en estado **nuevo** hasta que el programa inicia su ejecución. En este estado el hilo no se encuentra activo.
* **Ejecutable (runnable)**: En el momento en que se inicia el hilo mediante el método `start()` se considera que este se encuentra activo. En este momento el control de su ejecución pasa a ser del planificador que decidirá si se ejecuta inmediatamente o se mantiene a la espera en un pool hasta que decida ponerlo en ejecución.
* **En ejecución (running)**: En el momento en que el planificador escoge un hilo del pool para ser ejecutado, este pasa a estar en ejecución. Una vez en este estado, el hilo puede volver al estado de espera (ejecutable) si el planificador decide que su tiempo asignado de CPU ha finalizado aunque no haya completado su tarea. En este supuesto, deberá esperar a que el planificador vuelva a escogerlo para devolverlo a ejecución. Otras causas por las que un hilo puede abandonar este estado son los bloqueos o esperas o por su finalización.
* **Bloqueado/esperando (bloqued/waiting)**: Un hilo activo puede entrar en un estado de espera finito, por ejemplo durante operaciones de entrada/salida en las que debe esperar para obtener datos de un recurso. Cuando esta espera finaliza, el hilo vuelve al estado de ejecución. Este estado también se puede producir en caso de que el hilo de ejecución deba esperar a la realización de una tarea por parte de otro hilo. En este caso volverá al estado activo cuando el otro hilo envíe le una señal al hilo en espera para que siga su ejecución.
* **Finalizado (dead)**: Un hilo activo entra en este estado cuando completa su tarea o finaliza por otra causa, como por ejemplo que se produzca un error o se le envíe una señal de finalización.

## Problemas de concurrencia

Cuando 2 o más hilos se ejecutan al mismo tiempo y tienen que competir por los mismos recursos o colaborar para producir un resultado, es posible que se produzcan situaciones no deseadas 
que alteren este resultado o incluso produzcan problemas de rendimiento considerables en el sistema.

Entre los problemas más corrientes y conocidos se encuentran los siguientes:

* **Condición de carrera (Race condition)**: Este problema se produce cuando 2 o más hilos de ejecución modifican un recurso compartido en un orden diferente al esperado, provocando un estado erróneo de este recurso. Por ejemplo, 2 hilos de ejecución leen es valor de una variable compartida, realizan un cálculo sobre este y actualizan de nuevo la variable con el resultado. Si no se sincroniza adecuadamente el acceso a dicha variable es posible que los hilos hayan realizado los cálculos en base a un valor obsoleto porque el otro hilo lo haya actualizado antes. En este caso, la solución pasa por disponer de mecanismos para sincronizar el acceso a los recursos compartidos de manera que la lectura y posterior actualización sean atómicas y no puedan producirse de forma concurrente.
* **Bloqueo mutuo (Deadlock)**: Este problema se produce cuando 2 o más hilos de ejecución compiten por un recurso o se comunican entre ellos y no pueden acceder al recurso quedando indefinidamente a la espera de que sea liberado pero esto no se produce nunca. Un ejemplo clásico sería el de 2 hilos A y B que tienen asignados 2 recursos R1 y R2 respectivamente. Si A require R2 y B requiere R1 pero estos no son liberados por sus poseedores en ese momento, tanto A como B se encuentran bloqueados a la espera de poder acceder a los recursos. En este caso, la solución pasa por impedir situaciones en que un hilo de ejecución quede bloqueado esperando un recurso compartido sin liberar antes los que tiene él tiene ocupados.

## Referencias

**Políticas de planificación de tareas en Wikipedia**

* [Round-Robin](https://es.wikipedia.org/wiki/Planificaci%C3%B3n_Round-robin)
* [FIFO](https://es.wikipedia.org/wiki/First_in,_first_out)
* [LIFO](https://es.wikipedia.org/wiki/Last_in,_first_out)
* [Shortest Job First](https://en.wikipedia.org/wiki/Shortest_job_next)

