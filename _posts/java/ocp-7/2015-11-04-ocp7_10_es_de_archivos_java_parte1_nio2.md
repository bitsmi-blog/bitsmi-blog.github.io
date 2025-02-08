---
author: Xavier Salvador
title: OCP7 10 – E/S de archivos Java – Parte 1 – NIO.2 (New Input Output 2)
date: 2015-11-04
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

<!--more-->

## NIO

Es el acrónimo de **_New Input Output_**.

**NIO.2** del Jdk 1.7 implementa un nuevo paquete `java.nio.file` con dos subpaquetes:

– `java.nio.file.attribute`: Que permite un acceso masivo a los atributos  de los archivos.
– `java.nio.file.spi`: Dónde SPI significa Service Provider Interface. Es una interfície que permite establecer la conexión de la implementación de varios sistemas de archivos, 
permitiendo al desarrollador crear su propia versión del proveedor de sistema de archivos si así lo requiere.

## La clase FileSystem

Proporciona un método de intercomunicación con un sistema de archivos y un mecanismo para la creación de objetos usados para la manipulación de archivos y directorios.

## Interface Path – java.nio.file.Path

Un objeto Path representa la **ubicación relativa o absoluta de un archivo o directorio**. 
A su vez, permite definir métodos para la localización de archivos o directorios dentro de un sistema de archivos.

- En **Windows** nodo raíz `c:`
- En **Unix** nodo raíz empieza con `/`

Puede encontrarse informació más detallada en la API [oficial](http://docs.oracle.com/javase/7/docs/api/java/nio/file/Path.html). 

Métodos principales de la interfaz `Path` (se pueden encontrar más métodos en la URL oficial):

- `getFileName()`: Devuelve el nombre del archivo o del elemento más alejado del nodo raíz en la jerarquía de directorios.
- `getParent()`: Devuelve la ruta del directorio padre.
- `getNameCount()`: Devuelve el número de elementos que componen la ruta sin contar al elemento raíz.
- `getRoot()`: Devuelve el elemento raíz.
- `normalize()`: Elimina cualquier elemento redundante en la ruta.
- `toUri()`: Convierte una ruta en una cadena que puede ser introducida en la barra dirección web de un navegador.
- `subpath(1, 3)`: Devuelve un objeto Path que representa una subsecuencia de la ruta origen. (Los números hacen referencia a los identificadores situados entre las / separadoras empezando por el 0).
- `relativize(new Path())`: Crea una ruta relativa entre la ruta y una ruta indicada. 
Caso de ejemplo: en un entorno UNIX, si la ruta  es "/a/b" y la ruta indicada es `/a/b/c/d` entonces la ruta relativa resultante será `c/d`.

## La clase Files – java.nio.file.Files

Esta clase contiene métodos estáticos los cuáles podemos utilizar para realizar operaciones en archivos o en directorios. 

Puede encontrarse información más detallada en la API [oficial](http://docs.oracle.com/javase/7/docs/api/java/nio/file/Files.html).

La clase `Files` es sumamente importante para poder realizar operaciones con objetos Path tales como:

- Verificar un archivo o directorio.
	- `exists()`
	- `notExists()`
- `isReadable(Path path)`: Comprobar si el archivo o directorio dispone de permisos de lectura.
- `isWritable(Path path)`: Comprobar  si el archivo o directorio dispone de permisos de escritura.
- `isExecutable(Path path)`: Comprobar si el archivo o directorio dispone de permisos de ejecución.
- `setAttribute(Path path, String attribute, Object value, LinkOption… options)`: Permite aplicar distintos atributos a ficheros en el sistema DOS.
Ejemplo: `Files.setAttribute(new Path(), «dos:readonly», true)`.

El siguiente código ejemplifica su utilización.

```java
package filesclass;
 
import java.io.IOException;
import java.nio.file.*;
import java.util.Set;
 
public class FilesClass {
   
    public static void main(String[] args) {
 
        Path p1 = Paths.get("C:\JavaCourse\src\Example.java");
 
        System.out.println("exists: " + Files.exists(p1));
        System.out.println("isReadable: " + Files.isReadable(p1));
        System.out.println("isWritable: " + Files.isWritable(p1));
        System.out.println("isExecutable: " + Files.isExecutable(p1));
 
        //Set<PosixFilePermission> perms = PosixFilePermissions.fromString("rwxr-x---");
        //FileAttribute<Set<PosixFilePermission>> attr = PosixFilePermissions.asFileAttribute(perms);
 
        try {
            //Path f1 = Paths.get("C:\JavaCourse\src\Hello.txt");
            //Files.createFile(f1, attr);             
            Files.setAttribute(p1, "dos:readonly", true);
            System.out.println("Example.java isWritable: " + Files.isWritable(p1));
            System.out.println(Files.createTempFile("test", ".temp"));
 
        } catch (IOException e) {
            System.err.println(e);
        }
    }
}
```

Adicionalmente se puede comprobar y modificar el nivel de accesibilidad de un archivo o directorio mediante los siguientes métodos

- `createTempFile`
	- `createTempFile(Path dir, String prefix, String suffix, FileAttribute<?>… attrs)`
	Crea un nuevo fichero vacío en el directorio especificado, utilizando los textos de prefixo y sufijo facilitados en la llamada de la función para generar su nombre.
	- `static Path createTempFile(String prefix, String suffix, FileAttribute<?>… attrs)`
	Crea un nombre vacío en el directorio temporal por defecto, utilizando el prefijo y sufijo facilitados para generar su nombre.
- `copy: Permite copiar un archivo de una ruta a otra.
	- `copy(InputStream in, Path target, CopyOption… options)`
	Copia todos los bytes de un flujo de datos de entrada (Stream) a un fichero.
	- `copy(Path source, OutputStream out)`
	Copia todos los byters de un fichero a un flujo de datos de salida(Stream).
	- `copy(Path source, Path target, CopyOption… options)`
	Copia un fichero a otro fichero.
- `delete(Path path): Permite borrar archivos físicos o lógicos.
- `move(): Permite mover un archivo de una ruta a otra.
- `newDirectoryStream(new Path()): Permite obtener una interfaz DirectoryStream que al heredar de Iterable permite iterar sobre todos los archivos o subdirectorios situados en el nodo raíz. 
Debe utilizarse `try-with-resources` o lo finalizaremos explícitamente. Puede lanzar la excepción  `DirectoryIteratorException` o `IOException`.

El siguiente código muestra un caso de ejemplo de borrado, copia y pegado de ficheros en Java7.

```java
package filesclass;
 
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.NoSuchFileException;
import java.nio.file.Path;
import java.nio.file.Paths;
import static java.nio.file.StandardCopyOption.REPLACE_EXISTING;
 
 
public class FilesClass2 {
 
    public static void main(String[] args) {
 
        Path f1 = Paths.get("C:\JavaCourse\src\Hello.txt");
        Path f2 = Paths.get("C:\student\Hello2.txt");
         
         
        try {
                         
            Files.copy(f1,f2,REPLACE_EXISTING);
            Files.delete(f1);
            Files.move(f2,f1,REPLACE_EXISTING);
             
            System.out.println("Hello.txt exists: " + Files.exists(f1));
            System.out.println("Hello2.txt exists: " + Files.exists(f2));
 
        } catch (NoSuchFileException n) {
            System.err.println(n);
             
        } catch (IOException e) {
            System.err.println(e);
        }
    }
}
```

## Relación y conversión entre  Path y File

Entre la Interface `Path` y la classe `File` existen mecanismos para obtener una representación de un tipo a el otro. 
En el JDK7 no es necesario realizar operaciones de conversión complejas solamente es necesario recurrir al método `toFile` de cada uno de ellos:
	
	- `path.toFile()`: Retorna un objeto File representando su ruta.
	- `file.toPath()`: Retorna un objeto de tipo Path construido desde una ruta abstracta. El objeto Path resultante se encuentra asociado con el sistema de archivos por defecto.
	
Código fuente de ejemplo:

```java
File file = path.toFile();
Path file = file.toPath();
```
