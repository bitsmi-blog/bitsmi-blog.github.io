---
author: Xavier Salvador
title: Java – Guía rápida – 1ª parte
date: 2014-03-05
categories: [ "references", "java" ]
tags: [ "reference", "java" ]
layout: post
excerpt_separator: <!--more-->
---

<!--more-->

## Libros recomendados

- [Head First Design Patterns](http://shop.oreilly.com/product/9780596007126.do)
- [Effective java programming language guide](https://www.amazon.com/Effective-Java-Programming-Language-Guide/dp/0201310058)

## Palabras reservadas en Java

- `double`: Double precision floating point de 64 bits
- `float`: Single precision floating point de 32 bits
- `true`, `false`, `null`: No son palabras reservadas de Java sino literales y no se pueden utilizar como identificadores de cualquier tipo.
- `const`: *actualmente no se utiliza a nivel profesional.
- `final`: aplicado a distintos conceptos:
	- En variable -> no se puede modificar.
	- En método -> no se puede redefinir.
	- En clase -> no se puede heredar y es immutable (no se puede modificar).
- `native`: Permite indicar que el método esta implementado en un lenguaje programación distinto de Java.

## Conceptos

### Solid
- **S**: Single Responsibility Principle. Un objeto sólo debe tener una sola responsabilidad.
- **O**: Open/Closed principle. Entitades abiertas a la extensión pero cerradas a la modificación.
- **L**: Principio de sustitución de liskov. Objetos de un programa pueden ser reemplazables por instancias de sus subtipos sin alterar el correcto funcionamiento de un programa.
- **I**: Principio de segregación de la interfaz. Muchas interfaces cliente específicas son mejores que una interfaz de propósito general.
- **D**: Principio de la inversión de dependencia Se debe depender de abstracciones.

Para aplicar extensionalidad en una clase A que no puede ser heredada (caso de ejemplo, implementación de una interfície) es necesario que una clase B implemente 
la misma interfície y disponga de una variable que ea del tipo de la clase A.

### DRY

**Do not Repeat Yourself**

No repetir la misma lógica en distintos lugares.

### Kiss

**Keep It Simple Stupid**. Diseño lo más sencillo posible sin entrar en complejidades no necesarias.

### Clean code

El mensaje principal del libro me encanta. El código limpio (clean code), no es algo recomendado o deseable, es algo vital para las compañías y los programadores. 
La razón es que cada vez que alguien escribe código enmarañado y sin pruebas unitarias (código no limpio), otros tantos programadores pierden mucho tiempo intentando comprenderlo. 
Incluso el propio creador de un código no limpio si lo lee a los 6 meses será incapaz de comprenderlo y por tanto de evolucionarlo.

Para evitar este problema el autor Robert C. Martin propone seguir una serie de guías y buenas prácticas a la hora de escribir el código. En concreto se centra en el más bajo de los niveles,
por ejemplo, en el formato, estilo, nomenclaturas, convenciones, etc. El libro no trata casi nada sobre patrones de diseño, arquitecturas ni tecnologías concretas.
Aunque los ejemplos están en Java, se puede aplicar perfectamente a otros lenguajes.
 
### Synchronized

En su origen se utilizaba a nivel de método pero actualmente se usa a nivel de bloques para el código fuente puro..

- No se recomienda su uso pues en nuevas versiones posteriores a Java 6 la sincronización se gestiona de forma diferente.
– **Object**. Aunque generalmente se pasa un this para indicar que el Thread Safe es a nivel del mismo objeto, es posible pasarle otros objetos.
- Funcionamiento a nivel de semáforos.
- Hay que tener cuidado con los deadlocks y con los solapamientos lectura/escritura. 

### Volatile

Esencialmente, volátil se utiliza para indicar que el valor de una variable será modificado por diferentes hilos.

Declarar una variable volátil de Java significa:

- El valor de esta variable nunca será almacenado en la memoria local: todas las lecturas y escrituras irán directamente a la "memoria principal";
- El acceso a la variable actúa como si estuviera encerrada en un bloque sincronizado, sincronizado en sí mismo.

**En la ejecución de Hilos.**

```java
boolean lock='<valor>'
cache lock1      cache lock2
```

La aplicación de `Volatile` en una variable implica que al acceder a esta variable su valor se recupera de la memoria principal forzosamente no de la cache.

De este modo se puede recuperar el valor real en lugar del valor cacheado (pues otro este valor puede haberse modificado en cache por otro hilo).

Además implica que distintos hilos de ejecución pueden acceder y recuperar el valor original de la variable.

**Con las variables Volatile solo es posible realizar operaciones atómicas.**

```java
volatile int=0;
```

Una operació no atómica es i++.

`Double` y `long` no son operaciones atómicas por lo que son excepciones y volatile no funciona correctamente con estos tipos.

Para lectura/escritura de una variable Long es necesario utilizar la clase AtomicLong, pues de este modo se pueden realizar las operaciones atómicas con este tipo.

**Añadir volatile dentro de un método:**

```java
method{
// Se asegura que todas las líneas de código añadidas hasta la posición de volatile serán ejecutadas
// en el orden establecido por el código fuente.
volatile xxxx
// El resto del código fuente después de volatile será reordenado y optimizado automáticamente por la MV de Java antes de continuar con la ejecución.
// Esto implica que no se puede asegurar el orden de ejecución según el codigo fuente escrito posteriormente a la declaración de volatlie
}
```

### Diferencias entre Synchronized y Volatile

En otras palabras, las principales diferencias entre sincronizado y volátil son:

- Una variable primitiva puede ser declarada volatile (mientras que no se puede sincronizar en una primitiva con sincronizada).
- El acceso a una variable volatile **nunca tiene el potencial de bloquearse**: sólo hacemos una simple lectura o escritura, por lo que, a diferencia de un bloque sincronizado, nunca nos aferraremos a ningún bloqueo.
- Porque el acceso a una variable volatile nunca retiene un bloqueo, no es adecuado para los casos en que queremos leer-actualizar-escribir como una operación atómica (a menos que estemos preparados para "perder una actualización");
- Una variable volatile que es una referencia de objeto puede ser null (porque se está sincronizando efectivamente en la referencia, no en el objeto real).

Intentar sincronizar en un objeto nulo lanzará una excepción de `NullPointerException`.

### Transient

Relación con la interfície `Serializable`.

Contiene un id para contener el versionado de las serializaciones de los objetos en los distintos estados que este objeto pueda encontrarse.

Al declarar una variable como `transient` dentro del objeto serializado se está indicando que esta variable no estará incluïda en el proceso de serialización del objeto. 
Al realizar la deserialización del objeto, éste tendrá un valor nulo.

### Object

**equals**

- Detecta la igualdad entre dos objectes a partir de la dirección de memoria de este objeto.
- Dentro del equals NUNCA se debe incluir una clave primária.
- Dos objetos solament son idénticos si se encuentran en la misma dirección de memória.

**hashCode**

Utilizado con objetos MapSet (Java Collections).

- El algoritmo retorna una representación de la dirección de memória del objeto.
- Devuelve un valor entero random que identifica de forma única la instáncia del objecto.

**Proceso de ambos métodos**

Se llama al método equals y si los dos objetos son iguales, es entonces cuándo también se llama al hashCode dónde ambos objetos deberían devolver el mismo valor entero. 
Si se cumplen las dos condiciones se confirma que los objetos son idénticos.

### Exceptions

- `RuntimeException`: Gestión de excepciones no recuperables.
- `Exception`: Gestión de excepcions recuperables. Este tipo de excepciones están vinculadas a errores de ámbito funcional.

A nivel de uso hay muchos desarrolladores que encapsulan la gestión de todas las excepciones con excepciones del tipo RuntimeException, aunque éstas sean realmente recuperables.

## Estructura de memoria de Java

![](/assets/posts/reference/java/2014-03-05-java-guia_rapida_I_fig1.jpg)

- **HeapMemory**: Utilizada para almacenar objetos.
- **Tenured**: El SO habilita memoria para el proceso.

Un **Minor GC** consiste en:

- Reclamar la memoria de **Young Generation Space**
- Es un proceso **Stop the world**. Este proceso se realiza mediante una ejecución.
- El **Heap** contiene principalmente direccionamentos de memoria dinámica.

### Descripciones

**Meta Space**

Fuera de la memoria del Heap y parte de la memória nativa.

Por defecto no tiene fijado un límite superior. (También es conocida como memoria "PermGen Space").

Se utiliza para cargar/almacenar las definiciones de las clases cargadas mediante los class loaders.

Si se crea más que la memoria física disponible, el SO utilizará entonces el método de la memòria virtual.

**Code Cache**

La JVM incorpora un interprete de bytecode convertiendolo en código màquina dependiente.

Como mejora se introdujo el compilador JIT, permitiendo que los bloques de código más accedidos frecuentemente se compilen mediante JIT y almacenando en la memoria de Code Cache, sin necesidad de ser reinterpretados.

**Stacks**

- Parte de la memoria dónde se guardan las variables temporales (principalmente creadas por las funciones).
- Usado en la ejecución de un hilo dónde puede contener valores de vida muy corta así como referencias a otros objetos.
- Uso de la estructura LIFO.
- La memoria del Stack acostumbra a ser más pequeña que la del Heap porque cuándo un método finaliza su ejecución todas las variables del stack vinculadas con el método son eliminadas.
- Uso de alocaciones estáticas principalmente.
- Almacenamiento de variables locales sin poder modificar el tamaño del stack.
- Almacemamiento de referéncias a objetos ubicados en el Heap o también valores de tipo primitivo.

**Shared Libraries**

Las bibliotecas compartidas son archivos utilizados por múltiples aplicaciones. Cada biblioteca compartida consiste en un nombre simbólico, una ruta de clase Java 
y una ruta nativa para cargar las bibliotecas de Java Native Interface (JNI). Puede utilizar las bibliotecas compartidas para reducir el número de archivos de biblioteca duplicados en su sistema.

### Proceso de la memoria en Java

![](/assets/posts/reference/java/2014-03-05-java-guia_rapida_I_fig2.jpg)

### Ejecución del Garbage Collector

La JVM utiliza un demonio ejecutándose en un hilo independiente para la GC.

Cuándo una aplicación crea un objeto, primero la JVM intenta obtener el espació de memoria del espacio Eden.

La **GC** es equivalente a la **minor GC** más la **major GC**.

**Iteraciones**

En la primera iteración, en la minor GC, se realizan los siguientes pasos:

- Se activa cuándo la JVM detecta que no puede obtener más memoria del espacio **Eden**.
- En este punto, los objetos que no se pueden recuperar se marcan para ser recogidos.
- La JVM selecciona uno de los dos **Survivor Space** (p.e. SO) y lo selecciona como a **To Space**.
- La JVM copia todos los objetos recuperables a este **To Space** y a cada uno de los objectos se le incrementa la edad en una unidad.
- Si no se pueden copiar todos los objetos recuperables en el **To Space** por falta de espacio, se colocan directamente en la **Tenure Space**. Eso se conoce como **Promoción Prematura**.

Todos los objetos recuperables se denominan **GC Roots**, los cuáles no son eliminados por el GC. 
Es entonces cuándo en esta primera iteración el GC libera los objetos no recuperables y vacía el espacio del Eden.

En la segunda iteración del **minor GC** se realizan las siguientes acciones:

- El GC marca los objetos no recuperables del Eden y del **To Survivor Space** (del SO que se haya seleccionado).
- Copia los **GC Roots** del otro **Survivor Space S1** e incrementa el estado de los objetos.
- Este proceso se repirte para cada **minor GC** y cuándo un objeto llega al umbral máximo establecido en la JVM, estos objetos se copian en la Tenured Space.

Por definición un **minor GC**:

- Reclama la memoria de **Young Generation Space**.
- Es un proceso **stop the world**. Se lleva a cabo en la ejecución de un hilo simple o multihilo.

Si e ejecuta en varias ocasiones un **minor GC**, el **Tenured Space** acabará lleno y se requerirá más espacio de memoria en el GC.

En este punto, es cuándo se produce el **major GC**:

- Es conocido también como **Full GC**.
- La JVM reclama la memoria del espacio Meta. Si no hay objetos en el Heap, entonces las clases cargadas serán eliminadas del espacio Meta.
- Qué puede lanzar un **major GC**:
	- System.gc() o Runtime.getRuntime()gc().
	- Que la JVM indique que no se dispone de suficiente espacio.
	- Durante un proceso de **minor GC** si la JVM no puede obtener más espacio del **Eden** o del **Survivor Space**.
	- Si se fijado un valor para la variable de la JVM **MaxMetaspaceSize** y no se dispone de espacio suficiente para cargar nuevas clases.
