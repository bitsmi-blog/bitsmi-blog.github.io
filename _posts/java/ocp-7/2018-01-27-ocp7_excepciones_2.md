---
author: Xavier Salvador
title: OCP7 08 – Excepciones (II)
date: 2018-01-27
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

## Extensión de los tipos de excepción estándar

En la medida de lo posible se deberá hacer uso de la jerarquía de excepciones provistas por la JDK. En caso de querer crear nuevos tipos, se deberán tener en cuenta los siguientes puntos:

- Extender de `RuntimeException` o una de sus subclases en caso de definir un tipo de error no recuperable (**Excepción no comprobada**).
- Extender de `Exception` o una de sus subclases (a excepción de RuntimeException) en caso de definir un tipo de error recuperable (**Excepción comprobada**) 
que debe ser explícitamente declarado y capturado.
- No extender directamente de la clase `Throwable`, ya que la mayoría de tratamientos de errores mediante bloques `try/catch` se hace como mínimo a nivel de `Exception`. 
En estos casos, las excepciones derivadas directamente de `Throwable` no serían capturadas por estos bloques lo que podría provocar efectos no previstos.

## Tratamiento y propagación de excepciones

Se puede encontrar más información [aquí](http://www.oracle.com/technetwork/articles/java/java7exceptions-486908.html).

### Propagación entre métodos

Cuándo se gestionan las excepciones, hay ocasiones que se desea relanzar una excepción que está siendo gestionada. Un programador novicio cree que el código siguiente puede hacer esto:

```java
public class EjemploExceptionRethrow {
    public static void demoRethrow()throws IOException {
    try {
         
        // Se fuerza el lanzamiento de una IOException cómo ejemplo,
        // Normalmente la excepción es disparada por la ejecución de código.
        throw new IOException(“Error”);
    }
    catch(Exception exception) {
         
     /* Se trata la excepción y se relanza */
     throw exception;
    }
   }
 
    public static void main(String[] args) {
        try {
            demoRethrow();
        } catch (IOException exception) {
            System.err.println(exception.getMessage());
        }
    }
}
```

El código anterior no compilará correctamente en caso de hacerse con versiones de Java anteriores a 7 ya que el método `demoRethrow` explicitamente especifica en su firma que la excepción 
lanzada es de tipo `IOException`, mientras que el bloque `catch` declara la excepción capturada y relanzada de tipo `Exception`. 
En este caso el compilador no es capaz de inferir el tipo real de la excepción. En caso de la compilación del código se realice sobre la versión 7 o posterior, 
el código anterior será válido y compilará correctamente. En este caso, el compilador sí es capaz de inferir el tipo final al que pertenece de la excepción relanzada analizando las excepciones 
lanzadas dentro del bloque `try`.

El siguiente ejemplo muestra otro modo de gestionar la excepción y propagarla.

```java
public class EjemploAntiguoExceptionRethrow {
    public static demoRethrow() {
    try {
     throw new IOException("Error");
    }
    catch(IOException exception) {
     /*
       * Se trata la excepción y se relanza
       */
     throw new RuntimeException(exception);
    }
   }
 
    public static void main(String[] args) {
        try {
            demoRethrow();
        } catch (RuntimeException exception) {
            System.err.println(exception.getCause().getMessage());
        }
    }
}
```

El problema con el código anterior es que realmente no está relanzando la excepción original. La está encapsulando con otra excepción, lo que implica que el código del `catch` del `main` necesita gestionar 
la excepción con la que se ha encapsulado el `catch` original.

### Captura de excepciones mediante bloque try/catch/finally

Java 7 permite capturar múltiples excepciones en un mismo bloque `catch`. Este mecanismo es llamado **multicatch**.

```java
try {
 
    // Ejecución que puede generar uno de los errores catch
 
} catch(SQLException e) {
    System.out.println(e);
} catch(IOException e) {
    System.out.println(e);
} catch(Exception e) {
    System.out.println(e);
}
```

A partir de Java 7 se puede implementar el **multicatch**.

```java
try {
    // Ejecución que puede generar uno de los errores catch
} catch(SQLException | IOException e) {
    System.out.println(e);
} catch(Exception e) {
    System.out.println(e);
}
```

A destacar la utilización del carácter pipe `|` para separar los nombres de las clases. El carácter pipe `|` entre los nombres de las excepciones es el mecanismo 
cómo se declaran las múltiples excepciones a ser capturadas por el mismo `catch`.

Para un mayor detalle en el siguiente enlace se puede  encontrar más información sobre la implementación del **multicatch**.

### Bloque try with resources

Implementación de la interfaz `Closeable`. Para evitar que recursos como ficheros, comunicaciones con la BBDD u otros servicios queden en un estado indeterminado tras un error, 
Java cuenta con mecanismos para evitar este tipo de situaciones, uno de los cuáles es el **try-with-resources**, Similar al `try` pero con las siguientes diferencias:

- Diferencia de que entre paréntesis se declaran aquellos recursos que se desean proteger.
- Un recurso siempre debe ser cerrado después de que termine el programa.
- Un recurso es cualquier objeto que implemente la clase `java.lang.AutoCloseable`.

Los recursos de este bloque de código deben implementar la interfaz `java.io.Closeable` (que hereda de `AutoCloseable` – se recomienda mejor utilizar este objeto). 
Utilizando este bloque de código el programador no tiene que preocuparse de cerrar los recursos utilizados dentro del **try-with-resources**.

Una de las ventajas de `Autocloseable` consiste en poder llamar varias veces a su método `close()` obteniendo siempre el mismo resultado. 
Las excepciones generadas durante el proceso de cierre de un recurso son totalmente ignoradas.

Es importante indicar que **el orden del cierre de recursos es el opuesto al orden de apertura de esos recursos**: el primer recurso en abrirse es el último recurso en cerrarse.

Ejemplo para definir un nuevo objeto **try-with-resources**

```java
package TryWithResources;
 
public class NewResource implements AutoCloseable{
     
    String closingMessage;
  
    public NewResource(String closingMessage) {
        this.closingMessage = closingMessage;
    }
  
    public void doSomeWork(String work) throws ExceptionA{
        System.out.println(work);
        throw new ExceptionA("Exception thrown while doing some work");
    } 
 
    @Override
    public void close() throws ExceptionB{
        System.out.println(closingMessage);
        throw new ExceptionB("Exception thrown while closing");
    }
  
    public void doSomeWork(NewResource res) throws ExceptionA{
        res.doSomeWork("Wow res getting res to do work");
    }
}
```

Ejemplo de su utilización en la ejecución de un programa

```java
package TryWithResources;
 
public class TryWithRes {
 public static void main(String[] args) {
   
        try(NewResource res = new NewResource("Res1 closing")) {
            res.doSomeWork("Listening to podcast");
    
        } catch(Exception e) {
            System.out.println("Exception: "+e.getMessage()
    +" Thrown by: "+e.getClass().getSimpleName());
        }
    }
}
```

Ejemplo cuándo existen recursos anidados ambos derivando de `AutoCloseable`.

```java
package TryWithResources;
 
public class TryWithResV2 {
 
    public static void main(String[] args) {
 
        try (NewResource res = new NewResource("Res1 closing");
                 NewResource res2 = new NewResource("Res2 closing")) {
 
         try (NewResource nestedRes = new NewResource("Nestedres closing")) {
                nestedRes.doSomeWork(res2);
         }
        } catch (Exception e) {
            System.out.println("Exception: " + e.getMessage() 
                + " Thrown by: " + e.getClass().getSimpleName());
        }
    }
}
```

Nótese el uso del carácter » ; » cómo separador en la declaración de los recursos dentro del bloque **try-with-resources**.

### Tratamiento de excepciones no capturadas

En el procesado de hilos (**Threads**) puede producirse que su ejecución termine de forma abrupta debido a que se ha producido una excepción y ésta no ha sido capturada.
Java dispone a partir de la versión 5 de la *Interface* `UncaughtExceptionHandler` perteneciente al paquete java.lang. Esta interface es invocada cuándo un hilo (**Thread**) 
termina abruptamente su ejecución debido a una excepción no capturada. 

El siguiente código de ejemplo muestra la utilización de esta *Interface*.

```java
public class MultiplexUncaughtExceptionHandler implements UncaughtExceptionHandler {
    private final UncaughtExceptionHandler[] handlers;
 
    public MultiplexUncaughtExceptionHandler(UncaughtExceptionHandler... handlers) {
        super();
        this.handlers = Arrays.copyOf(handlers, handlers.length);
    }
 
    public void uncaughtException(Thread t, Throwable e) {
        for (UncaughtExceptionHandler handler : handlers) {
            try {
                handler.uncaughtException(t, e);
            } catch (Throwable th) {
                th.printStackTrace();
            }
        }
    }
}
```

Se puede encontrar más información en [este enlace](https://docs.oracle.com/javase/7/docs/api/java/lang/Thread.UncaughtExceptionHandler.html) oficial de Oracle.

