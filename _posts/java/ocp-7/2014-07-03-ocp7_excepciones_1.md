---
author: Antonio Archilla
title: OCP7 08 – Excepciones (I)
date: 2014-07-03
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

## Tipos de Excepciones

### Excepciones comprobadas (checked).

Representan errores producidos durante la ejecución de un programa por condiciones inválidas en el flujo esperado. 
Estos errores pueden ser previsibles o esperables y por eso se puede definir un flujo alternativo para tratarlos. 
Es el caso, por ejemplo, de errores de conexión de red, errores en la localización de ficheros, conexión a base de datos, etc. 
En estos casos, se puede aplicar una política de re-intentos o bien informar al usuario del error de forma controlada si se trata de un entorno interactivo.

Los métodos están obligados a tratar de alguna manera las excepciones de este tipo producidas en su implementación, ya sea relanzándolas, apilándolas o tratándolas mediante un bloque `try/catch`.

`Exception` y subclases, excepto `RuntimeException` y subclases.

### Excepciones no comprobadas (unchecked).

Representan errores producidos durante la ejecución de un programa de los que no se espera una posible recuperación o no se pueden tratar. 
Se incluyen entre estos casos errores aritméticos, cómo divisiones entre cero, excepciones en el tratamiento de punteros, 
cómo el acceso a referencias nulas (NullPointerException) u errores en el tratamiento de índices, cómo por ejemplo el acceso a un índice incorrecto de un array.

Este tipo de errores pueden ocurrir en cualquier lugar de la aplicación y no se requiere su especificación en la firma de los métodos correspondientes o su tratamiento 
a través de bloques `try/catch` (aunque es posible hacerlo) lo que facilita a la legibilidad del código.

`RuntimeException`, `Error` y subclases de éstas.

En concreto la excepción no comprobada `Error` representa errores producidos por condiciones anormales en la ejecución de una aplicación que nunca deberían darse. 
En su mayoría se trata de errores no recuperables y por esta razón, este tipo de excepciones no extienden de Exception y si de `Throwable` con el propósito que no sean capturadas accidentalmente 
por ningún bloque `try/catch` que pueda impedir la finalización de la ejecución. A nivel de compilación, estos se tratan de igual forma que las excepciones no comprobadas, 
por lo que no hay la obligación de declarar su lanzamiento en las firmas de los métodos.

Ejemplos:

* **VirtualMachineError**: Indica que se ha producido un error que impide a la máquina virtual seguir con la ejecución, sea porque se ha roto o porque no puede conseguir los recursos necesarios para hacerlo, cómo por ejemplo, por falta de memoria (OutOfMemoryError), porque se haya producido un desborde de la pila (StackOverflowError) o porque se haya producido un error interno (InternalError).
* **LinkageError**: Indica incompatibilidades con una dependencia (clase) que ha sido modificada después de la compilación.
* **AssertionError**: Indica un error en una aserción.

## Jerarquía de Excepciones

La jerarquía de las excepciones en Java 7 puede visualizarse en el siguiente esquema:

![](/assets/posts/java/ocp-7/2014-07-03-ocp7_excepciones_1_fig1.png)

La **superclase** de todas las excepciones es `Throwable`.

La clase `Exception` sirve como **superclase** para crear excepciones de propósito específico, es decir, adaptado a nuestras necesidades.

La clase `Error` está relacionada con errores de compilación, del sistema o de la JVM. Normalmente estos errores son irrecuperables.

`RuntimeException` (**Excepciones Implícitas**): Excepciones muy frecuentes relacionadas con errores de programación. Existen pocas posibilidades también de recuperar situaciones anómalas de este tipo.

## Lanzamiento de Excepciones

Para el lanzamiento de una excepción debe ejecutarse el siguiente código:

```java
//  Crear una excepcion
MyException me = new MyException("Myexception message");
 
//  Lanzamiento de la excepción
throw me;
```

**Bloque try-catch**

El bloque que puede lanzar una excepción se coloca dentro de un bloque `try`. Se escribe un bloque `catch` para cada excepción que se quiera capturar. 
Ambos bloques se encuentran ligados en ejecución por lo que no debe existir una separación entre ellos formando una estructura `try-catch` conjunta e indivisible. 
Pueden asociarse varios bloques `catch` a un mismo bloque `try`.

```java
import java.util.*;
 
public class ExTryCatch {
 public static void main(String[] args){
   
  int i=-3;
   
  try{
   String[] array = new String[i];
   System.out.println("Message1");
  }
   
  catch(NegativeArraySizeException e){
   System.out.println("Exception1");
  }
   
  catch(IllegalArgumentException  e){
   System.out.println("Exception2");
  }
   
  System.out.println("Message2");
   
 }
}
```

**Bloque Finally**

Cuándo se agrupan excepciones al acceder a uno de los `catch` el resto de `catch` no se ejecutarán y puede provocar un error en la liberación de recursos utilizados en un programa. 
Java cuenta con un mecanismo para evitar esto de forma consistente en el bloque de código `finally` el cuál siempre se ejecuta.

```java
import java.util.*;
 
public class ExFinally {
 public static void main(String[] args){
   
  int i=5;
   
  try{
   String[] array = new String[i];
  }
   
  catch(NegativeArraySizeException e){
   System.out.println("Exception1");
  }
   
  catch(IllegalArgumentException  e){
   System.out.println("Exception2");
  }
   
  finally{
   System.out.println("This always executes");
  } 
 }
}
```

