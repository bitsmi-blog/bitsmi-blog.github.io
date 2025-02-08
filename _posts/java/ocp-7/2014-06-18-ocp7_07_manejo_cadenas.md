---
author: Xavier Salvador
title: OCP7 07 – Manejo de Cadenas
date: 2014-06-18
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

## Argumentos y formatos de cadenas

El método main contiene el parámetro `String[] args`. Puede recibir **cero** o **más argumentos**.
La implementación de la clase es la siguiente.

```java
public class Echo {
 public static void main(String[] args) {
  for (String s: args) {
   System.out.println(s);
  }
 }
}
```

La clase `Echo` puede recibir los siguientes parámetros por línea de consola de comandos.

```sh
java Echo Enero Febrero Marzo Abril
```

Pasándole como argumentos en la línea de comandos los cuatro primeros meses del año.

Cada uno de los meses separados por un salto de línea. Esto es así debido a que el carácter espacio se utiliza para separar los parámetros unos de otros mediante un salto de línea entre cada uno.

Si se quiere **mostrar un frase o texto completo**, por ejemplo

```sh
java Echo "Enero, Febrero, Marzo, Abril son los cuatro primeros meses..."
```

se debe indicar la apertura y el cierre del texto mediante comillas dobles `""`.

Debe tenerse en cuenta que los arrays **SIEMPRE empiezan con el valor 0, nunca con el 1**. 
Para recuperar los parámetros recibidos mediante el método main se utilizan los indices del vector. 
Así con el código `args[0]` se recupera el primer parámetro, con `args[1]` se recupera el segundo, etc.

Adicionalmente, si una aplicación necesita recibir argumentos de tipo numérico, debe convertirse el argumento de tipo `String` a un argumento que represente un número, 
como por ejemplo el `34`, a su valor numérico equivalente, el `34`.

Este snippet transforma un argumento de consola de comandos en un tipo entero:

```java
int primerArg;
if (args.length > 0) {
    try {
        primerArg = Integer.parseInt(args[0]);
 
System.out.println("Se ha convertido la cadena "+args[0]+" en el número siguiente -> "+primerArg);
    } catch (NumberFormatException e) {
        System.err.println("Argumento " + args[0] + " debe ser un número entero.");
        System.exit(1);
    }
}
```

`primerArg` lanza una excepción del tipo NumberFormatException si el formato de `args[0]` no es valido. 
Todas las clases de tipo `Number` — `Integer`, `Float`, `Double` y demás — disponen de métodos de conversión que transforman un String representando un número en un objeto de su tipo específico.

## Formatos de cadena

Los distintos argumentos de conversión que podemos utilizar para modificar el aspecto de una objeto String son los siguientes:

![](/assets/posts/java/ocp-7/2014-06-18-ocp7_07_manejo_cadenas_fig1.png)

Cómo ejemplo inicial para **limitar el número de caracteres** que se visualizan por pantalla es suficiente con utilizar `%2.2x` dónde `x` **corresponde al argumento de conversión que se haya pasado**. 

## PrintWriter

`PrintWriter` es una nueva clase de impresión bastante similar a `Printf` perteneciente a la librería `java.io`. Puede encontrarse su Javadoc [aquí](http://docs.oracle.com/javase/7/docs/api/java/io/PrintWriter.html).

```java
PrintWriter pw = new PrintWriter(System.io, true);
 
pw.printf("Texto escrito mediante Pw");
```

## Procesamiento de Cadenas

Dentro del JDK en su versión del Java 7 existen varias clases Java que permiten manipular y tratar los elementos de tipo cadena. Son clases ya existentes en versiones anteriores del JDK.

### String 

Representa una cadena de caracteres **inalterable**. Al modificar un objeto `String` lo que estamos haciendo en realidad es crear otro objeto `String`. No es la más eficiente ni la mejor. 
Ideal para tratar con cadenas de texto cuyo valor sabemos que no se modificará: mensajes de alerta, texto, informativo, etc.

### StringBulider / StringBuffer

Debe utilizarse cuándo debamos trabajar con cadenas de texto que deban modificar su contenido en tiempo de ejecución. 
Ambas disponen del mismo API de desarrollo.
Como norma general utilizaremos `StringBuilder` en lugar de `StringBuffer`.

**Razón:** Los métodos de `StringBuffer` son **sincronizados** por lo que pueden ser utilizados de forma segura en un ambiente multihilo.
Los métodos de `StringBuilder` **no son sincronizados** por lo que su uso implica un mejor rendimiento cuándo se usan localmente.

En general, la concatenación de Strings ocurre con variables locales a un método por lo que es recomendable utilizar de forma general `StringBuilder` en lugar de `StringBuffer`.

**Cuan rápido es StringBuilder sobre StringBuffer?**

`StringBuilder` puede resultar un 50% más rápido para concatenar `String`.

Para esta implementación.

```java
public class StringBuilder_vs_StringBuffer {
 
    public static void main(String[] args) {
        StringBuffer sbuffer = new StringBuffer();
        long inicio = System.currentTimeMillis();
 
        for (int n = 0; n < 1000000; n++) {
            sbuffer.append("zim");
        }
 
        long fin = System.currentTimeMillis();
        System.out.println("Time using StringBuffer: " + (fin - inicio));
 
        StringBuilder sbuilder = new StringBuilder();
 
        inicio = System.currentTimeMillis();
 
        for (int i = 0; i < 1000000; i++) {
            sbuilder.append("zim");
        }
 
        fin = System.currentTimeMillis();
        System.out.println("Time using StringBuilder: " + (fin - inicio));
 
 
    }
}
```

Obteniendo casi una mejora del **50%** utilizando `StringBuilder`.

![](/assets/posts/java/ocp-7/2014-06-18-ocp7_07_manejo_cadenas_fig2.png)

## Clases Auxiliares en la Manipulación de cadenas

### StringTokenizer

Extrae información (en forma de tokens) de una cadena de texto cuyos caracteres están separados por un carácter o símbolo especial o separador. 
Recorre la cadena de texto y obtiene las cadenas obtenidas (tokens) a partir del símbolo especial o separador indicado en la llamada al método.

```java
// Inicialización
StringTokenizer  st = new StringTokenizer("this is a test");
 
// Utilización
while(st.hasMoreTokens())  {
      System.out.println(st.nextToken())
}
```

Puede encontrarse información más detallada dentro de la API de Java 7 en la siguiente [dirección](https://docs.oracle.com/javase/7/docs/api/java/util/StringTokenizer.html).

### Scanner

Extrae información de una cadena o flujo de datos como StringTokenizer. Cambia el  tipo de dato a las divisiones mientras se itera sobre ellas (`StringTokenizer` no puede), 
es decir, ante un flujo de datos podremos capturar enteros, decimales, etc en función de nuestro método de iteración utilizando `Scanner`.

