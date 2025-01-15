---
author: Xavsal
title: OCP7 10 – E/S de archivos Java – Parte 3 – FileStore y WatchService
date: 2015-12-03
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

<!--more-->

## Clase FileStore

La  clase `FileStore` es útil para proporcionar información de uso sobre el sistema de archivos como el total de disco utilizable y asignado.

```
Filesystem kbytes used available
System (C:) 209748988 72247420 137501568
Data (D:) 81847292 429488 81417804
```
 
En este [enlace](https://docs.oracle.com/javase/tutorial/displayCode.html?code=https://docs.oracle.com/javase/tutorial/essential/io/examples/DiskUsage.java) oficial de Oracle puede estudiarse la implementación de `FileStore`.

## Interfaz WatchService

La implementación de la interfaz de `WatchService` representa un servicio de vigilancia que observa los cambios producidos en los objetos `Path` registrados.
Por ejemplo, una instancia de `WatchService` puede usarse para identificar cuándo fueron añadidos, borrados o modificados archivos en un directorio.

```
ENTRY_CREATE: D:testNew Text Document.txt
ENTRY_CREATE: D:testFoo.txt
ENTRY_MODIFY: D:testFoo.txt
ENTRY_MODIFY: D:testFoo.txt
ENTRY_DELETE: D:testFoo.txt
```

**NOTA:**

La implementación del mecanismo de observación del sistema de ficheros es dependiente de la plataforma de ejecución.

Por defecto, se intentan mapear los eventos que se observan a través del `WatchService` con los eventos nativos que el Sistema Operativo genera ante los cambios de ficheros. 
Esto hace que sea posible encontrarse diferentes tipos de eventos resultados de una misma acción.

En caso que no sea posible consumir los eventos nativos, la implementación en caso de error se encargará de [_polling_](https://en.wikipedia.org/wiki/Polling_(computer_science)) consultar el estado de los elementos del sistema de ficheros indicado.

La contra partida de este mecanismo de fallback es que ante eventos muy seguidos, es posible que no se reciban todos los eventos generados si el tiempo entre muestra y muestra es superior al tiempo transcurrido entre los eventos.

En todo caso, la utilización de este servicio ha de tener en cuenta esta particularidad para no obtener resultados inesperados.


En este [enlace](https://docs.oracle.com/javase/tutorial/essential/io/notification.html) oficial de Oracle puede estudiarse con más detalle el funcionamiento de la interfaz `WatchService`.
