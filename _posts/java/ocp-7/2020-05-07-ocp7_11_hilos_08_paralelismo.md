---
author: Xavsal
title: OCP7 11 – Hilos (08) – Paralelismo
date: 2020-05-07
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

## Introducción

Los sistemas modernos contienen varias CPU. Para sacar partido de la potencia de procesamiento en un sistema es preciso ejecutar tareas en paralelo en varias CPU.

Divide y vencerás.
Una tarea se debe dividir en subtareas. Debe intentar identificar aquellas subtareas que se puedan ejecutar en paralelo.

- Puede ser difícil ejecutar algunos problemas como tareas paralelas.

- Algunos problemas son más sencillos. Los servidores que soportan varios clientes pueden usar una tarea independiente para manejar cada cliente.

- Se debe tener cuidado con el hardware. La programación de demasiadas tareas paralelas puede afectar de forma negativa al rendimiento.

## Recuento de CPU

Si las tareas requieren muchos cálculos, al contrario de operaciones que generan muchas E/S, el **número de tareas paralelas no debe superar en gran cantidad el número de procesadores del sistema**.

Puede detectar el número de procesadores de forma sencilla en Java:

```java
int count = Runtime.getRuntime().availableProcessors();
```

## Sin paralelismo

Los sistemas modernos contienen varias CPU. Si no aprovechan los threads de alguna forma, sólo se utilizará una parte de la potencia de procesamiento del sistema.

## Definición de etapa

Si tiene una gran cantidad de datos que procesar pero solo un thread para procesar dichos datos, se utilizará una CPU.

Como ejemplo el procesamiento de una matriz podría ser una tarea simple, como buscar el valor más alto en la matriz. Entonces, en un sistema de cuatro CPU, debe haber tres CPU inactivas mientras se procesa la matriz.

## Paralelismo naive

Una solución paralela simple divide los datos que se van a procesar en varios juegos en un juego de datos para cada CPU y un thread para procesar cada juego de datos.

## División de datos

Siguiendo el ejemplo de la matriz (como gran juego) se divide en cuatro subjuegos de datos, uno para cada CPU.

Ello implica que se crea un thread por CPU para procesar los datos.

Tras el procesamineto de los subjuegos de datos, los resultados se tendrán que combinar de una forma significativa.

Hay distintas forma de subdividir el juego de datos grande que se va a procesar.

- Se usaría demasiada memoria para crear una matriz por thread que contenga una copia de una parte de la matriz original.
- Cada matriz puede compartir una referencia a una única matriz grande pero solo acceder a un subjuego de una forma con protección de hread no bloqueante.

