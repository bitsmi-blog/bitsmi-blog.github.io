---
author: Xavier Salvador
title: OCP7 10 – E/S de archivos Java – Parte 2 – Interfaz FileVisitor
date: 2015-12-02
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

<!--more-->

## Operaciones recursivas

La classe `Files` ofrece un método para recorrer el árbol de archivos en busca de operaciones recursivas, como de copia y de supresión.

### Interfaz FileVisitor<T>

La interfaz `FileVisitor<T>` permite realizar el recorrido de un nodo raíz de forma recursiva. 
Puede encontrarse la implementación en la API del JDK 7 en el siguiente [enlace](https://docs.oracle.com/javase/7/docs/api/java/nio/file/FileVisitor.html).

Para poder llevar a cabo el recorrido recursivo mencionado con anterioridad se detallan los siguientes métodos, representando puntos clave del recorrido recursivo. 
Son métodos a los que se vaya llamando cada vez que se visita uno de los nodos del árbol:

- `FileVisitResult preVisitDirectory(T dir, BasicFileAttributes attrs)`: Se invoca en un directorio antes de que se visiten las entradas del directorio.
- `FileVisitResult visitFile(T file, BasicFileAttributes attrs)`: Se invoca cuándo se visita un archivo.
- `FileVisitResult postVisitDirectory(T dir, IOException exc)`: Se invoca después que se hayan visitado todas las entradas un directorio y sus descendientes.
- `FileVisitResult visitFileFailed(T dir, IOException exc)`: Se invoca cuándo un archivo no ha podido ser visitado.

El objeto `FileVisitResult` es el tipo de retorno para la interfaz `FileVisitor`. 
Contiene cuatro constantes  que permiten procesar el archivo visitado e indicar que debe ocurrir en el próximo archivo 
(`Enum FileVisitResult` – para un mayor detalle se puede consultar directamente la API de JDK 7 en este enlace). 
Estas constantes representan  las acciones que tomar tras alcanzar un nodo (antes o después):

- `CONTINUE`: Se debe continuar la visita del siguiente nodo en el árbol de directorios.
- `SKIP_SIBLINGS`: Señala que se debe continuar el recorrido sin visitar a los hermanos del archivo o directorio.
- `SKIP_SUBTREE`: Señala que se debe continuar el recorrido de los nodos sin visitar las entradas de este directorio.
- `TERMINATE`: Indica la finalización del proceso de visita.

A continuación se muestra un código Java que ilustra la utilización de los cuatro métodos definidos con anterioridad:

```java
package recursiveoperations;
 
import java.io.IOException;
import java.nio.file.FileVisitResult;
import static java.nio.file.FileVisitResult.CONTINUE;
import java.nio.file.FileVisitor;
import java.nio.file.Path;
import java.nio.file.attribute.BasicFileAttributes;
 
public class PrintTree implements FileVisitor<Path> {
 
    @Override
    public FileVisitResult preVisitDirectory(Path dir, BasicFileAttributes attr) {
        System.out.print("preVisitDirectory: ");
        System.out.println("Directory : " + dir);
        return CONTINUE;
    }
 
    @Override
    public FileVisitResult visitFile(Path file, BasicFileAttributes attr) {
        System.out.print("visitFile: ");
        System.out.print("File : " + file);
        System.out.println("(" + attr.size() + " bytes)");
        return CONTINUE;
    }
 
    @Override
    public FileVisitResult postVisitDirectory(Path dir, IOException exc) {
        System.out.print("postVisitDirectory: ");
        System.out.println("Directory : " + dir);
        return CONTINUE;
    }
 
    @Override
    public FileVisitResult visitFileFailed(Path file, IOException exc) {
        System.out.print("vistiFileFailed: ");
        System.err.println(exc);
        return CONTINUE;
    }
}
```

A continuación se muestra un código de ejemplo utilizando la clase `PrintTree`:

```java
Path path = Paths.get("D:/Test");
try{
    Files.walkFileTree(path, new PrintTree())
} catch (IOException e) {
    System.out.println("Exception: "+e);
}
```

En este ejemplo la clase `PrintTree` implanta cada uno de los métodos en `FileVisitor` e imprime el tipo, nombre y el tamaño del directorio y el archivo de cada nodo.

### Búsqueda de archivos

**Clase PathMatcher**

En `java.nio.file` se incluye la interfaz `PathMatcher` la cuál define el método `matches(Path path)`. 
Éste método  permite determinar si un objeto `Path` coincide con una cadena de búsqueda especificada.
Cada implantación de sistema de archivos proporciona un objeto `PathMatcher` recuperable mediante `FileSystems`:

```java
PathMatcher matcher = FileSystems.getDefault().getPathMatcher(String syntaxPattern);
```

La cadena `syntaxPattern` presenta la siguiente forma sintaxis:patrón dónde sintaxis puede ser `glob` o `regex`. Cúando la sintaxis es `regex`, 
el componente patrón es una expresión regular definida por la clase `Pattern`.

Se incluye el siguiente código Java. Esta clase se utiliza para recorrer el árbol en busca de coincidencias entre el archivo y el archivo alcanzado por el método `VisitFile`.

```java
package findingfiles;
 
import java.io.IOException;
import java.nio.file.FileVisitResult;
import static java.nio.file.FileVisitResult.CONTINUE;
import java.nio.file.FileVisitor;
import java.nio.file.Path;
import java.nio.file.PathMatcher;
import java.nio.file.attribute.BasicFileAttributes;
 
public class Finder implements FileVisitor<Path> {
     
    private Path root;
    private PathMatcher matcher;
     
    Finder(Path root, PathMatcher matcher) {
        this.root = root;
        this.matcher = matcher;
         
    }
     
    private void find(Path file) {
        Path name = file.getFileName();
        if (name != null && matcher.matches(name)) {            
            System.out.println(file);
        }
    }
     
    @Override
    public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) {
        find(file);
        return CONTINUE;
    }
     
    @Override
    public FileVisitResult preVisitDirectory(Path dir, BasicFileAttributes attrs) {
        return CONTINUE;
    }
     
    @Override
    public FileVisitResult postVisitDirectory(Path dir, IOException exc) {
        return CONTINUE;
    }
     
    @Override
    public FileVisitResult visitFileFailed(Path file, IOException exc) {
       return CONTINUE;
    }
}
```

Una vez definido el tipo, se instancia en una clase `MyClass` y se ejecuta.

```java
package findingfiles;
 
import java.io.IOException;
import java.nio.file.*;
 
public class MyClass {
 
    public static void main(String[] args) {
 
        Path root = Paths.get("C:\JavaTest");
 
        PathMatcher matcher = FileSystems.getDefault().getPathMatcher
                                                              ("glob:*.{java,class}");
         
        Finder finder = new Finder(root, matcher);
        try {
            Files.walkFileTree(root, finder);
        } catch (IOException e) {
            System.out.println("Exception: " + e);
        }
        
    }
}
```

El primer argumento se prueba para ver si es un directorio. El segundo argumento se usa para crear una instancia `PatchMatcher` con una expresión regular mediante 
la _factory_ `FileSystems.Finder` es un clase que implanta la interfaz `FileVisitor`, de modo que se puede transferir a un método `walkFileTree`. 
Esta clase se usa para llamar al método de coincidencia en todos los archivos visitados en el árbol.
