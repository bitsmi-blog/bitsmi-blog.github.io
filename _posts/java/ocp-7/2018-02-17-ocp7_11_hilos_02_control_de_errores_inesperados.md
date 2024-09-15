---
author: Antonio Archilla
title: OCP7 11 – Hilos (02) – Control de Errores Inesperados
date: 2018-02-17
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

La clase `Thread` cuenta con un mecanismo de control de errores para casos en que se produzca un final inesperado a la ejecución de éste. 
A través del método `setUncaughtExceptionHandler` de la clase `Thread` es posible recoger la causa de esta finalización anómala dentro del hilo principal de la aplicación y actuar en consecuencia.

<!--more-->

A continuación se añade un ejemplo que ilustra su funcionamiento:

```java
// Resto del código
Thread t = new Thread(new Runnable()) {
 
 @Override
 public void run() {
  // Código del thread que provoca
  // una finalización anómala en su
  // ejecución
 }
});
t.setUncaughtExceptionHandler(new Thread.UncaughtExceptionHandler(){
   
 @Override
 public void uncaughtException(Thread t, Throwable e) {
  // Tratamiento del error producido en el Thread.
  // Por ejemplo, se puede registrar un error o emprender
  // una acción alternativa
 }
});
 
// Inicialización de la ejecución del Thread.
// Gracias al Listenr del thread no es necesario supervisar la finalización
// del thread para tratar el error pudiendo seguir la ejecución del programa
// principal
t.start(); 
 
// Resto del código
```