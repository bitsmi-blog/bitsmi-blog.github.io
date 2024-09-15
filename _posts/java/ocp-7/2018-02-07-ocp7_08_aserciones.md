---
author: Antonio Archilla
title: OCP7 08 – Aserciones
date: 2018-02-07
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

La aserción es un mecanismo que permite comprobar suposiciones en el código que ayudan a confirmar el buen funcionamiento del mismo y que este está libre de errores. 
En el siguiente post se muestra su funcionamiento básico y las situaciones en las que es apropiado su uso y en las que no.
Una expresión de tipo aserción se identifica por la palabra clave assert. Su sintaxis es la siguiente:

```
assert <expression> [: <message>]
```

Where:

- **expression**: Expresión booleana que indicará si la suposición se cumple o no. En caso de que no se cumpla, se lanzará un error de tipo `AssertionError`
- **message**: Opcional. Si se indica un valor en la expresión, este será adjuntado en el error `AssertionError` producido.

<!--more-->

El uso de las aserciones en el código no siempre es apropiada. A continuación se enumeran algunos de los casos más habituales en las que se puede utilizar este tipo de construcción:

- **Comprobación de precondiciones**: Condiciones que deben cumplirse cuando un método es invocado. (sólo en caso de métodos **NO** públicos).
- **Comprobación de poscondiciones**: Conditions that must be met when a method is successfully executed. 
- **Comprobaciones de Lock-status**: En métodos diseñados para entornos multihilo, es posible comprobar la precondición de si el hilo actual ha obtenido el **Lock** sobre un objeto determinado. 
Como en el caso de las precondiciones, <u>ésto se debe hacer sólo en la API no pública de la clase</u> siendo el código el siguiente:

```java
assert Thread.holdsLock(this);
```
- **Comprobaciones de flujo invariante**: Se puede añadir una aserción en lugares donde, por la lógica aplicada, se prevea que sea imposible que se acceda. Por ejemplo:
For example:
```java 
private void doStuff(int input){
 // Se prevé que el valor de entrada sea siempre par
 if(input%2==0){
  …
  return;
 }
 assert false;
}
```

Se tiene que tener en cuenta que si la sentencia `assert` se encuentra en un bloque de código no accesible, el compilador generará un error de compilación, 
por lo que se debe ir con cuidado al utilizar este patrón. 

Los siguientes casos muestran situaciones en las que **NO** se deben utilizar aserciones:

- **Comprobación de precondiciones en métodos públicos**: Dado que dichas comprobaciones constituyen un contrato entre la API publica de la clase con un componente externo, 
la validez de estas se debe comprobar siempre y esto no se consigue mediante las aserciones, ya que pueden estar deshabilitadas (por defecto). 
Por ejemplo, para indicar que un parámetro de entrada no es válido, se puede utilizar la excepción no comprobada `IllegalArgumentException`..

**Las aserciones no se encuentran activas por defecto.** Es necesario ejecutar el programa indicando las opciones `-ea` (enable assertions) y, opcionalmente, las clases a las que aplica:

- **Sin argumentos**:  Habilita las aserciones a todas las clases, a excepción de las de sistema, e.g. `java -ea MainProgram`
- **package[...]**: Habilita las aserciones a las clases del package indicado y todos sus subpackages, e.g. `java -ea:com.ejemplo… MainProgram`.
- **Nombre Class**: Habilita las aserciones sólo en la clase especificada

Es posible establecer filtros sobre clases o packages en los que no se quiera habilitar las aserciones combinando la opción anterior con `–da`(**disable assertions**), 
aceptando esta la misma parametrización. Si por ejemplo se quieren habilitar todas las aserciones del package `com.ejemplo`, incluyendo subpackages, a excepción de la clase `com.ejemplo.SimpleClass`, 
la sentencia seria como la siguiente:

```java 
java -ea:com.ejemplo -da:com.example.SimpleClass MainProgram
```

Estas opciones pueden especificarse múltiples veces, siendo evaluadas en el orden en que se hayan especificado. 

En caso de especificar un *package* o clase como argumento, se habilitaran o deshabilitaran las aserciones sobre clases de sistema en caso de que haga referencia a ellas. 
Será posible habilitar o deshabilitar explícitamente las aserciones para las clases de sistema mediante las opciones `-esa` (**enable system assertions**) y `–dsa` (**disable system assertions**). 
Por defecto es deseable mantenerlas deshabilitadas. 


## References

- [Documentación oficial](https://docs.oracle.com/javase/7/docs/technotes/guides/language/assert.html)
