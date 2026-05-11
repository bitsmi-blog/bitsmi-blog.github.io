---
author: Xavier Salvador
title: 15.- Internal Aspect of JUnit
date: 2025-02-23
page_order: 15
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

El capítulo 15 estudia en profundidad la clase `ComparisonCompactor` del framework JUnit, demostrando cómo aplicar las reglas del Código Limpio a un módulo ya bien escrito mediante el principio "Boy Scout": dejar el código mejor de como lo encontramos.

<!--more-->

## Qué hace ComparisonCompactor

`ComparisonCompactor` produce mensajes de error legibles en fallos de aserción de igualdad. Dado `contextLength`, `expected` y `actual`, genera cadenas del estilo:

```
expected: <...B[X]D...>  but was: <...B[Y]D...>
```

Los corchetes encierran la parte diferente; los puntos suspensivos indican contexto recortado. El módulo tenía cobertura de tests del 100%.

## Código original (Listing 15-2)

El original era código correcto pero mejorable. Variables privadas con prefijo `f` (`fContextLength`, `fExpected`, `fActual`, `fPrefix`, `fSuffix`), una condición negativa sin encapsular en `compact()` y nombres que no describían bien la intención.

## Pasos de refactorización

### 1. Eliminar el prefijo `f` en variables miembro [N6]

Los entornos modernos hacen innecesario este tipo de encoding de alcance:

```java
private int contextLength;
private String expected;
private String actual;
private int prefix;
private int suffix;
```

### 2. Encapsular la condicional negativa [G28]

```java
if (shouldNotCompact())
    return Assert.format(message, expected, actual);

private boolean shouldNotCompact() {
    return expected == null || actual == null || areStringsEqual();
}
```

### 3. Invertir a positivo [G29]

Las negaciones son más difíciles de leer. Se renombra y se invierte:

```java
if (canBeCompacted()) { ... }

private boolean canBeCompacted() {
    return expected != null && actual != null && !areStringsEqual();
}
```

### 4. Renombrar `compact` → `formatCompactedComparison` [N7]

El nombre `compact` ocultaba el efecto lateral de la comprobación de error y el retorno de un mensaje formateado.

### 5. Extraer `compactExpectedAndActual()` [G30]

La función debe hacer una sola cosa: el cuerpo del `if` se extrae a un método separado. `compactExpected` y `compactActual` se promueven a variables miembro para mantener consistencia de retorno [G11].

### 6. Exponer el acoplamiento temporal [G31]

`findCommonSuffix` dependía de que `findCommonPrefix` se ejecutara antes. Solución: fusionar en `findCommonPrefixAndSuffix()`, que llama a `findCommonPrefix` internamente antes de calcular el sufijo.

### 7. Renombrar `suffixIndex` → `suffixLength` [N1, G33]

`suffixIndex` era en realidad una longitud 1-based que introducía `+1` artificiales en `computeCommonSuffix`. Al renombrarlo y ajustar la aritmética, los `+1` desaparecen y `compactString` puede simplificarse a:

```java
private String compactString(String source) {
    return computeCommonPrefix()
        + DELTA_START
        + source.substring(prefixLength, source.length() - suffixLength)
        + DELTA_END
        + computeCommonSuffix();
}
```

## Versión final (Listing 15-5)

El resultado es una clase con ~10 métodos pequeños, cada uno con un nombre que dice lo que hace. Los métodos `startingEllipsis()`, `startingContext()`, `delta()`, `endingContext()` y `endingEllipsis()` componen el resultado de forma legible en `compact(String s)`.

## Reglas clave

| Código | Regla aplicada |
|--------|---------------|
| N1 | Nombres descriptivos |
| N6 | Evitar encodings (prefijo `f`) |
| N7 | Los nombres deben describir los efectos secundarios |
| G9 | Eliminar código muerto / sentencias redundantes |
| G11 | Consistencia en convenciones |
| G28 | Encapsular condicionales |
| G29 | Evitar condicionales negativos |
| G30 | Las funciones deben hacer una sola cosa |
| G31 | Exponer acoplamientos temporales |
| G33 | Eliminar los `+1` artificiales con nombres adecuados |

## Resumen

El capítulo demuestra que incluso código bien escrito admite mejoras. A través de pequeños pasos —cada uno guiado por una heurística concreta— la clase `ComparisonCompactor` pasa de ser *buena* a ser *limpia*: más expresiva, más cohesiva y sin acoplamientos ocultos.