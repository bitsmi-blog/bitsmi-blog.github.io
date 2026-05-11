---
author: Xavier Salvador
title: Appendix B.- org.jfree.date.SerialDate
page_order: APENDICE_B
date: 2025-02-27
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

El Apéndice B contiene el listado completo del código fuente de `org.jfree.date.SerialDate`, extraído de la librería de código abierto JCommon. Su presencia en el libro tiene un propósito didáctico muy concreto.

<!--more-->

## Qué contiene el apéndice

El apéndice reproduce íntegramente el fichero `SerialDate.java` y los ficheros relacionados de JCommon tal como existían antes de que el autor los refactorizase en el capítulo 16. Se incluyen:

- `SerialDate.java`: la clase abstracta base (~900 líneas)
- `MonthConstants.java`: interfaz con las constantes de los meses
- `SpreadsheetDate.java`: implementación concreta de `SerialDate`
- `RelativeDayOfWeekRule.java`: regla auxiliar que usa `SerialDate`
- El listado refactorizado final (`DayDate.java` y clases asociadas)

## Por qué está en el libro

El capítulo 16 analiza `SerialDate` línea a línea y propone decenas de cambios. Para que el lector pueda seguir ese análisis con el código delante —y ver exactamente a qué líneas se refiere el autor cuando cita "línea 98", "línea 326" o "línea 638"— el apéndice proporciona la fuente original numerada.

Sin el apéndice, las referencias del capítulo 16 a números de línea concretos resultarían opacas. Con él, el lector puede verificar cada decisión de refactorización en su contexto original.

## Relación con el capítulo 16

El flujo de lectura recomendado es:

1. Leer el capítulo 16 con el apéndice abierto como referencia.
2. Seguir cada cambio propuesto (renombrar clase, convertir constantes en enums, mover métodos, eliminar código muerto) sobre el listado original.
3. Comparar el resultado con el listado refactorizado final que también incluye el apéndice.

Este ejercicio ilustra cómo un código perfectamente funcional puede mejorarse sustancialmente en claridad, cohesión y adherencia a los principios del Código Limpio sin cambiar su comportamiento externo.

## Resumen

El Apéndice B no es lectura autónoma: es el material de referencia del caso de estudio del capítulo 16. Su valor está en permitir que el lector sea partícipe activo de la refactorización, comprobando cada heurística aplicada contra el código original de JCommon.