---
author: Antonio Archilla
title: Error NullPointerException al evaluar una expresión ternaria
date: 2016-02-12
categories: [ "references", "java", "error reference" ]
tags: [ "java" ]
layout: post
excerpt_separator: <!--more-->
---

## Descripción de error

Se produce un error de tipo `NullPointerException` al evaluar una expresión ternaria donde se mezclan valores de tipo primitivo (int, long, double…) con sus correspondientes tipos Wrapper (Integer, Long, Double) si el valor de resultante de la expresión es null.

Cuando la expresión condicional evalua y se asigna un valor no nulo, en este caso el segundo operando de la expresión, la operación funciona correctamente:

```java
long val1 = 1;
         
Long valor2 = val1==1 ? val1 : (Long)null;
System.out.println("VALOR2 is null -> " + (valor2 != null));
```

&rarr; `VALOR2 is null -> true`

En cambio, cuando se evalúa la condición y el valor resultante es `null`, tercer operando en el ejemplo, aunque este último se trate como un tipo objeto, se produce un error:

```java
long val1 = 2;

Long valor2 = val1==1 ? val1 : (Long)null;
System.out.println("VALOR2 is null -> " + (valor2 != null));
```

&rarr; `Exception in thread "main" java.lang.NullPointerException`

## Solución propuesta

El error se produce porque en las expresiones ternarias de este tipo, el compilador escoge como tipo de retorno el valor primitivo, en el caso de los ejemplos anteriores el tipo long en lugar del tipo _wrapper_ **Long**. Por esta razón, aunque se especifique una conversión explicita al tipo adecuado cuando se utiliza un valor nulo, siempre se producirá un error si ese es el resultado de la operación ya que el tipo primitivo no admite este tipo de valores.

La solución simple a este error es trasformar en todos los casos el valor resultante a un tipo _wrapper_. En el ejemplo, el segundo miembro de la operación es transformado a Long mediante el método `valueOf` para que todos los operandos sean de este tipo, que si admite valores nulos. El compilador escogerá este tipo para el resultado de la operación ya que es el único presente en las 2 alternativas, tanto si se cumple la condición como si no.

```java
long val1 = 2;
         
Long valor2 = val1==1 ? Long.valueOf(val1) : (Long)null;
System.out.println("VALOR2 is null -> " + (valor2 != null));
```

&rarr; `VALOR2 is null -> false`

 
## Referencias

- [Definición del operador ternario en la especificación del lenguaje Java (JLS)](http://docs.oracle.com/javase/specs/jls/se8/html/jls-15.html#jls-15.25)
