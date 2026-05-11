---
author: Xavier Salvador
title: 16.- SerialDate refactor
page_order: 16
date: 2025-02-24
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

El capítulo 16 es un caso de estudio sobre la clase `org.jfree.date.SerialDate` de la librería JCommon. El autor primero la hace funcionar correctamente y luego la refactoriza en profundidad, aplicando un amplio catálogo de heurísticas de código limpio.

<!--more-->

## Primer paso: hacer que funcione

Al ejecutar los tests existentes contra `SerialDate`, varios fallan. El análisis revela dos problemas:

- Un error de límite en `getFollowingDayOfWeek`: la condición de ajuste era incorrecta para ciertos días de la semana.
- Los métodos `weekInMonthToString` y `relativeToString` devolvían strings de error en lugar de lanzar `IllegalArgumentException`.

Tras corregir estos errores, todos los tests de JCommon pasan.

## Segundo paso: hacerlo bien

A continuación, se recorre la clase de arriba a abajo aplicando mejoras.

### Eliminar el historial de cambios [C1]

El largo bloque de comentarios con historial de versiones es un vestigio del pasado. Los sistemas de control de versiones modernos ya almacenan esa información.

### Renombrar `SerialDate` → `DayDate` [N1, N2]

El nombre "SerialDate" describe una implementación concreta (representación por número serial), pero la clase es abstracta. Un nombre abstracto como `DayDate` es más apropiado para una clase base.

### Reemplazar `MonthConstants` por un enum `Month` [J2]

Heredar de una interfaz para obtener constantes es un mal truco de Java. Se reemplaza con un enum propio:

```java
public static enum Month {
    JANUARY(1), FEBRUARY(2), ..., DECEMBER(12);
    public final int index;
    public static Month make(int monthIndex) { ... }
}
```

Esto elimina `isValidMonthCode` y toda la validación manual de códigos de mes [G5].

### Convertir otros conjuntos de constantes en enums [J3]

- `WeekInMonth`: FIRST, SECOND, THIRD, FOURTH, LAST
- `DateInterval`: CLOSED, CLOSED_LEFT, CLOSED_RIGHT, OPEN (nomenclatura matemática más clara [N3])
- `WeekdayRange`: LAST, NEXT, NEAREST

### Mover constantes al nivel correcto [G6]

`EARLIEST_DATE_ORDINAL` y `LATEST_DATE_ORDINAL` solo los usa `SpreadsheetDate`, así que se mueven allí. `MINIMUM_YEAR_SUPPORTED` y `MAXIMUM_YEAR_SUPPORTED` también se desplazan a la subclase.

### Introducir `DayDateFactory` [G7]

Una clase base no debe conocer a sus derivadas. Se introduce el patrón ABSTRACT FACTORY:

```java
public abstract class DayDateFactory {
    private static DayDateFactory factory = new SpreadsheetDateFactory();
    public static DayDate makeDate(int ordinal) { return factory._makeDate(ordinal); }
    public static int getMinimumYear()          { return factory._getMinimumYear(); }
    // ...
}
```

### Extraer `Day` a su propio fichero [G13]

El enum `Day` es suficientemente grande e independiente de `DayDate` como para vivir en su propio fichero fuente.

### Mover métodos al lugar correcto [G14, Feature Envy]

- `monthCodeToQuarter` → método `quarter()` en el enum `Month`
- `monthCodeToString` / `weekdayCodeToString` → métodos `toString()` y `toShortString()` en los enums correspondientes
- `stringToMonthCode` → `Month.parse(String s)`
- `stringToWeekdayCode` → `Day.parse(String s)`

### Mejoras adicionales

- `isLeapYear` se reescribe de forma más expresiva con variables intermedias [G16]
- `leapYearCount` se mueve a `SpreadsheetDate` donde realmente se usa [G6]
- `addDays` deja de ser estático y pasa a ser un método de instancia [G18]
- Se eliminan Javadocs redundantes y comentarios obsoletos [C2, C3]
- Se eliminan `final` en argumentos y variables locales (añaden ruido sin valor) [G12]

## Reglas clave

| Código | Regla aplicada |
|--------|---------------|
| C1–C3 | Comentarios: eliminar historial, obsoletos, redundantes |
| G5 | No duplicar: usar enums en lugar de validación manual |
| G6 | Código al nivel de abstracción correcto |
| G7 | Las clases base no deben conocer a sus derivadas |
| G12 | Eliminar clutter (constructores vacíos, `final` innecesarios) |
| G13 | Evitar acoplamiento artificial |
| G14 | Evitar Feature Envy: mover métodos a donde pertenecen |
| G16 | Variables intermedias para claridad |
| G18 | Preferir métodos de instancia a estáticos |
| J2–J3 | No heredar constantes; usar enums |
| N1–N3 | Nombres descriptivos, nivel de abstracción correcto, nomenclatura estándar |

## Resumen

La refactorización de `SerialDate` es un ejemplo completo de cómo convertir una clase funcional pero mejorable en una clase limpia. La estrategia "primero hazlo funcionar, luego hazlo bien" permite aplicar cambios con confianza, respaldados en todo momento por los tests.