---
author: Xavier Salvador
title: 17.- Heuristics and systems
page_order: 17
date: 2025-02-25
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

El capítulo 17 es el catálogo definitivo de olores y heurísticas del libro. Recoge todas las razones concretas que guiaron las refactorizaciones de los capítulos anteriores, agrupadas en siete categorías: Comentarios, Entorno, Funciones, General, Java, Nombres y Tests.

<!--more-->

## Comentarios

| Código | Nombre | Descripción |
|--------|--------|-------------|
| C1 | Información inapropiada | Metadatos como historial de cambios, autores o números de ticket no deben estar en comentarios; pertenecen al sistema de control de versiones. |
| C2 | Comentario obsoleto | Comentarios que ya no corresponden al código son peores que no tener comentarios: desorientan. Deben actualizarse o eliminarse. |
| C3 | Comentario redundante | Si el código ya es claro, el comentario que lo repite solo añade ruido: `i++; // increment i`. |
| C4 | Comentario mal escrito | Un comentario que vale la pena escribir merece estar bien escrito: gramaticalmente correcto, breve y preciso. |
| C5 | Código comentado | El código comentado se pudre. Nadie lo borra porque cree que otro lo necesita. Bórralo; el control de versiones lo recuerda. |

## Entorno

| Código | Nombre | Descripción |
|--------|--------|-------------|
| E1 | Build en más de un paso | Construir el proyecto debe ser un solo comando trivial. |
| E2 | Tests en más de un paso | Ejecutar todos los tests debe ser un solo comando. |

## Funciones

| Código | Nombre | Descripción |
|--------|--------|-------------|
| F1 | Demasiados argumentos | Cero es lo mejor; uno, dos o tres son aceptables; más de tres es muy cuestionable. |
| F2 | Argumentos de salida | Los argumentos deben ser entradas, no salidas. Si hay que cambiar estado, que sea el del objeto receptor. |
| F3 | Argumentos bandera | Un `boolean` como argumento declara que la función hace más de una cosa. |
| F4 | Función muerta | Los métodos que nadie llama deben eliminarse; el control de versiones los recuerda. |

## General

### G1–G10: Estructura y abstracción

- **G1 Varios lenguajes en un fichero**: Lo ideal es un solo lenguaje por fichero. Java + HTML + JavaScript en el mismo fichero dificulta la lectura.
- **G2 Comportamiento obvio no implementado**: Siguiendo el Principio de Mínima Sorpresa, una función debe implementar lo que un programador razonablemente esperaría.
- **G3 Comportamiento incorrecto en límites**: No confíes en la intuición: escribe tests para cada condición de contorno.
- **G4 Saltarse salvaguardas**: Deshabilitar tests o ignorar warnings del compilador es jugar con fuego.
- **G5 Duplicación**: Toda duplicación representa una abstracción perdida. La forma más sutil es el `switch/case` que aparece una y otra vez: reemplázalo con polimorfismo.
- **G6 Código al nivel de abstracción incorrecto**: Las constantes, variables o funciones propias de una implementación concreta no deben estar en la clase base.
- **G7 Clase base depende de sus derivadas**: En general, las clases base no deben conocer a sus subclases.
- **G8 Demasiada información**: Las interfaces bien definidas son pequeñas. Pocos métodos, pocas variables de instancia, bajo acoplamiento.
- **G9 Código muerto**: Código que no se ejecuta (ramas imposibles, `catch` vacíos, funciones no llamadas) debe eliminarse.
- **G10 Separación vertical**: Las variables y funciones deben definirse cerca de donde se usan.

### G11–G20: Convenciones y claridad

- **G11 Inconsistencia**: Si usas `response` para `HttpServletResponse` en una función, úsalo en todas.
- **G12 Clutter**: Constructores vacíos, variables sin usar, comentarios sin información: todo esto debe eliminarse.
- **G13 Acoplamiento artificial**: No pongas enums o constantes de propósito general dentro de clases específicas.
- **G14 Feature Envy**: Un método que usa intensivamente los datos de otro objeto debería estar en ese otro objeto.
- **G15 Argumentos selector**: Un `false` al final de una llamada es un mal olor. Mejor dividir la función en dos.
- **G16 Intención oscura**: Las expresiones densas, la notación húngara y los números mágicos ocultan la intención. Usa variables intermedias con nombres expresivos.
- **G17 Responsabilidad mal ubicada**: El código debe estar donde el lector esperaría encontrarlo.
- **G18 Estático inapropiado**: Prefiere métodos de instancia a estáticos cuando exista posibilidad de comportamiento polimórfico.
- **G19 Variables explicativas**: Descomponer cálculos en variables intermedias con nombres significativos mejora la legibilidad de forma espectacular.
- **G20 El nombre debe decir qué hace**: Si hay que leer la implementación para entender el nombre, el nombre está mal elegido.

### G21–G30: Algoritmos y diseño

- **G21 Entiende el algoritmo**: No basta con que los tests pasen. Debes entender cómo funciona la solución.
- **G22 Dependencias lógicas → físicas**: No hagas suposiciones sobre otro módulo; pregúntale explícitamente lo que necesitas.
- **G23 Polimorfismo > if/else o switch/case**: Regla "ONE SWITCH": para un tipo de selección, como máximo un `switch`, que cree objetos polimórficos.
- **G24 Seguir convenciones estándar**: El equipo elige un estándar y todos lo siguen sin excepciones.
- **G25 Reemplazar números mágicos por constantes con nombre**: `SECONDS_PER_DAY` en lugar de `86400`.
- **G26 Ser preciso**: Las decisiones de diseño deben tomarse con precisión: comprueba `null`, usa enteros para moneda, añade bloqueos si hay concurrencia.
- **G27 Estructura > convención**: Una clase abstracta con métodos abstractos obliga a implementarlos; una convención de nombres no.
- **G28 Encapsular condicionales**: `if (shouldBeDeleted(timer))` es más claro que `if (timer.hasExpired() && !timer.isRecurrent())`.
- **G29 Evitar condicionales negativos**: `if (buffer.shouldCompact())` es más fácil de leer que `if (!buffer.shouldNotCompact())`.
- **G30 Las funciones deben hacer una sola cosa**: Un bucle con condición y lógica de pago debe dividirse en tres métodos.

### G31–G36: Acoplamientos y configuración

- **G31 Acoplamientos temporales ocultos**: Si B debe llamarse antes que A, hazlo evidente en la firma: `findCommonPrefixAndSuffix()` llama a `findCommonPrefix()` internamente.
- **G32 No ser arbitrario**: Si el código parece arbitrario, otros lo cambiarán. Haz que la estructura tenga razón de ser.
- **G33 Condiciones de límite**: Encapsula los cálculos de límites; no los disperses por todo el código.
- **G34 Las funciones deben descender un solo nivel de abstracción**: Mezclar lógica de alto y bajo nivel en la misma función dificulta la lectura.
- **G35 Constantes de configuración en el nivel más alto**: Las constantes configurables deben vivir en el nivel superior de la jerarquía y pasarse hacia abajo.
- **G36 Evitar navegación transitiva**: `a.getB().getC().doSomething()` crea arquitecturas rígidas. Ley de Demeter: un módulo solo debe conocer a sus colaboradores inmediatos.

## Java

| Código | Nombre | Descripción |
|--------|--------|-------------|
| J1 | Evitar listas largas de imports | Usar `import paquete.*` en lugar de importar clase a clase cuando se usan dos o más clases del mismo paquete. |
| J2 | No heredar constantes | Heredar de una interfaz para obtener constantes es un truco sucio. Usa `static import`. |
| J3 | Constantes vs enums | Ahora que Java tiene enums (Java 5), úsalos: son más expresivos que `public static final int`. |

## Nombres

| Código | Nombre | Descripción |
|--------|--------|-------------|
| N1 | Nombres descriptivos | Los nombres son el 90% de lo que hace el código legible. Tómate el tiempo necesario. |
| N2 | Nivel de abstracción correcto | No uses `phoneNumber` en una interfaz `Modem`; usa `connectionLocator`. |
| N3 | Nomenclatura estándar | Si usas el patrón DECORATOR, usa "Decorator" en el nombre. |
| N4 | Nombres inequívocos | `doRename` que contiene `renamePage` no dice nada sobre la diferencia entre ambas. |
| N5 | Nombres largos para ámbitos largos | `i` es perfecto en un bucle de 5 líneas; para ámbitos amplios usa nombres completos. |
| N6 | Evitar encodings | Los prefijos `m_`, `f`, `I_` son ruido en entornos modernos. |
| N7 | Los nombres deben describir los efectos secundarios | `getOos()` que crea el objeto si no existe debería llamarse `createOrReturnOos`. |

## Tests

| Código | Nombre | Descripción |
|--------|--------|-------------|
| T1 | Tests insuficientes | Una suite debe testear todo lo que podría fallar. |
| T2 | Usa una herramienta de cobertura | Las herramientas de cobertura revelan qué ramas no se han testeado. |
| T3 | No omitas tests triviales | Son fáciles de escribir y su valor documental supera el coste. |
| T4 | Un test ignorado es una pregunta | `@Ignore` o un test comentado expresan ambigüedad en los requisitos. |
| T5 | Testea las condiciones de límite | Los límites son donde más fallan los algoritmos. |
| T6 | Testea exhaustivamente cerca de los bugs | Los bugs se agrupan. Si encuentras uno, busca más en la misma función. |
| T7 | Los patrones de fallo son reveladores | Ordenar los tests y observar los patrones de rojo/verde puede apuntar a la causa raíz. |
| T8 | Los patrones de cobertura son reveladores | El código no cubierto por los tests que pasan da pistas sobre los que fallan. |
| T9 | Los tests deben ser rápidos | Un test lento es un test que no se ejecutará cuando haya presión de tiempo. |

## Resumen

El catálogo del capítulo 17 no pretende ser exhaustivo: es un sistema de valores. El código limpio no se escribe siguiendo una lista de reglas, sino cultivando el juicio profesional que permite reconocer los olores y saber cómo eliminarlos.