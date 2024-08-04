---
author: Antonio Archilla
title: NoClassDefFoundError en la inicialización de una clase Java
date: 2020-03-20
categories: [ "references", "java", "error reference" ]
tags: [ "java" ]
layout: post
excerpt_separator: <!--more-->
---

Los **bloques de código estático** en el lenguaje de programación Java són un mecanismo de **inicialización de los recursos estáticos** de una clase
que se ejecuta en el momento en que se interactua con dicha clase por primera vez. Un fallo producido dentro de dichos bloques estáticos puede provocar
errores inesperados en la ejecución del programa. En este post se habla de una de la posibles consecuencias de un error de este tipo y de cómo puede
ser identificado.   

## Introducción al problema

Cuando la máquina virtual de Java ejecuta el código de una aplicación, el sistema de **Classloaders** es el encargado de recuperar e inicializar 
las clases incluidas en el classpath según se van requiriendo. 

El proceso de carga de una clase comprende tanto la lectura del fichero **\*.class** correspondiente cómo la inicialización de esta, lo que incluye:

* Inicialización de miembros estáticos de la clase (variables, clases anidadas...)
* Ejecución de bloques estáticos de inicialización

Por ejemplo, en el seguiente de código define la clase `StaticResource` que ejecuta un código de inicialización dentro de un **bloque static**
en el mismo momento en que la máquina virtual carga la clase.

```java
public class StaticResource
{
    /* Ejecutado durante la carga de la clase */
    static {
        System.out.println("INICIALIZACIÓN StaticResource");
        // Puede lanzar una RuntimeException
        initializeStatic();
    }
    
    public static String getResourceName(int index)
    {
        System.out.println("GET RESOURCE NAME " + index);
        return "Resource " + index;
    }
    
    private static void initializeStatic()
    {
        throw new RuntimeException("Error en la inicialización de StaticResource");
    }
}
```

Cómo se puede ver, es perfectamente posible que el código del **bloque static** lance un error. Este hecho hace que la inicialización de toda la clase
falle y por consiguiente, la carga de esta si no se trata correctamente el error.

## Análisis del error

Para analizar las trazas producidas por una situación así, se dispone del código expuesto abajo. En el se llama al método estático 
`StaticResource.getResourceName` varias veces para mostrar los efectos de un fallo de este tipo:

```java
    public static void main(String... args)
    {
        try {
            String resourceName = StaticResource.getResourceName(1);
            System.out.println("RESULT 1: " + resourceName);                
        }
        catch(Throwable e){
            System.err.println("ERROR 1: " + e.getMessage());
            e.printStackTrace();
        }       
        
        // ...
        
        try {
            String resourceName = StaticResource.getResourceName(1);
            System.out.println("RESULT 2: " + resourceName);                
        }
        catch(Throwable e){
            System.err.println("ERROR 2: " + e.getMessage());
            e.printStackTrace();
        }
    }
```

Cómo resultado de la ejecución del código anterior se obtienen las siguientes trazas:

```
INICIALIZACIÓN StaticResource
ERROR 1: null
java.lang.ExceptionInInitializerError
    at MainProgram.main(MainProgram.java:7)
Caused by: java.lang.RuntimeException: Error en la inicialización de StaticResource
    at StaticResource.initializeStatic(MainProgram.java:44)
    at StaticResource.<clinit>(MainProgram.java:33)
    ... 1 more
ERROR 2: Could not initialize class StaticResource
java.lang.NoClassDefFoundError: Could not initialize class StaticResource
    at MainProgram.main(MainProgram.java:18)
```

En ellas se puede observar el siguiente comportamiento:

* La primera vez que se llama al método `getResourceName`, la máquina virtual intenta cargar e inicializar la clase asociada `StaticResource`
y cómo resultado del error producido en el bloque de incializació estático, se produce un error de tipo `java.lang.ExceptionInInitializerError`
* El error es capturado por el **bloque try/catch** y se prosigue con la ejecución del programa. **NOTA:** Aquí se ha intentado simular el caso que el error
sea suprimido por algun tipo de sistema de tratamiento de errores o por un **catch silencioso**, es decir, que no propague el error. Se trata de una
mala práctica hacer **catch** de `java.lang.Error` dado que representan errores fatales en la ejecución.
* Las posteriores llamadas al método `getResourceName` dan como resultado un error de tipo `java.lang.NoClassDefFoundError`. Este tipo de errores ocurre
cuando una clase en particular está presente en tiempo de compilación pero no lo está en tiempo de ejecución y esto es justo lo que ha pasado: 
La clase ha fallado y la máquina virtual no es capaz de cargar la definición en posteriores accesos, por lo que a efectos prácticos es como si esta 
no existiera, aunque el mensaje que acompaña al error nos da una pista de que ha sucedido por un error en la inicialización de la clase:
`Could not initialize class StaticResource`.

## Corregir y prevenir el error

Segun lo visto en el apartado anterior, en los casos que se produce un error de tipo `java.lang.NoClassDefFoundError` debido a una inicialización fallida de una
clase, esta irá acompañada de un error de tipo `java.lang.ExceptionInInitializerError` anterior. En caso de que no se pueda identificar este último en las trazas de log
de la aplicación, es posible que se tenga que revisar los diferentes niveles del código implicado buscando una posible supresión del error, cómo por ejemplo un *catch silencionso*,
o bien añadir nuevas trazas de log que permitan descubrir la existencia del error. Una vez se tiene la certeza de que se tratade un error de incialización, se deberá identificar 
la causa del error y proceder en consecuencia, por ejemplo, realizando las siguientes modificaciones: 

* **Utilizar bloques try/catch:** Si se trata de un error recuperable, se puede ejecutar el código alternativo de inicialización dentro del bloque **catch**
* **Propagar el error adecuadamente:** Si se trata de un error fatal, se debe asegurar que el error de inicialización se propague correctamente por los diferentes 
niveles del `stacktrace` hasta la parte del código encargada de reportarlo e incluso permitir la finalización de la la ejecución del programa. 
* **Registrar el error:** Se debe poder identificar el primer error `java.lang.ExceptionInInitializerError` rápidamente una vez sucede y por ellos es muy
importante que las trazas del error se reporten en el sistema de alertas adecuando (Fichero de log especifico, plataforma de alertas del sistema...) de una forma clara
y entendible.
* **Revisar la idoneidad de la inicialización estática:** Se debe considerar la posibilidad de mover el bloque de código problemático de la inicialización estática de la clase,
por ejemplo, convirtiendolo en código no estático que se ejecute durante la instanciación de objetos de dicha clase, o bien mediante una *inicialización diferida* que se ejecute
una sóla vez. El código de esto último se muestra a continuación:

```java
public class StaticResource
{
    public static String getResourceName(int index)
    {
        System.out.println("GET RESOURCE NAME " + index);
        return "Resource " + index;
    }
    
    public static void initializeStatic()
    {
        // En el siguiente código se puede producir un error
        // ...
    }
}

// ...

public static void main(String... args)
{
    try {
        // Ejecutado una sóla vez
        String resourceName = StaticResource.initializeStatic();        
    }
    catch(Throwable e){
        System.err.println("INITILIZATION ERROR: " + e.getMessage());
        e.printStackTrace();
        
        /* En este caso, si la inicialización no es correcta, no tiene sentido seguir
         * y por ello se termina la ejecución de la aplicación 
         */
        System.exit(1);
    }       
    
    // ...
        
    String resourceName = StaticResource.getResourceName(1);
    System.out.println("RESULT: " + resourceName);                  
}
```
