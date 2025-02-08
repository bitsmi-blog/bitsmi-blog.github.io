---
author: Xavier Salvador
title: OCP7 09 – Pricipios básicos de E/S
date: 2014-07-03
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

## Streams

El término define una **corriente de datos de una fuente a un destino**.

Todos los datos fluyen a través de un ordenador desde una entrada (fuente) hacia una salida (destino).

Los fuentes y destinos de datos son **nodos de los flujos** en la comunicación del ordenador. Todos los flujos presentan el mismo modelo a todos los programas Java que los utilizan:

- **flujo de entrada**: para **leer secuencialmente datos desde una fuente** (un archivo, un teclado por ejemplo). Llamado también como input stream.
- **flujo de salida**: para **escribir secuencialmente datos a un destino** (una pantalla, archivo, etc). Llamado también como outputstream.
Estos nodos pueden ser representados por una fuente de datos, un programa, un flujo, etc..

### Flujos de Datos (Bytes y carácteres)

La tecnología Java admite dos tipos de datos en los flujos: bytes y carácteres.

![](/assets/posts/java/ocp-7/2014-07-03-ocp7_09_principios_basicos_de_es_fig1.jpg)

En el lenguaje Java los flujos de datos se detallan mediante clases que forman jerarquías según sea el tipo de dato **char** Unicode de 16 bits o **byte** de 8 bits.

A su vez, las clases se agrupan en jerarquías según sea su función de lectura (Read) o de escritura (Write).

La mayoría de las clases que se utilizan con `Streams` se encuentran ubicadas en el paquete `java.io`. En la cabecera del código fuente debe escribirse el importe del paquete import `java.io.*`;

- Métodos básicos de lectura de Streams
	- Clase [InputStream](http://docs.oracle.com/javase/7/docs/api/java/io/InputStream.html) (Bytes)
		- int read()
		- int read(byte[] buffer)
		- int read(byte[] buffer, int offset, int length)
	- Clase [Reader](http://docs.oracle.com/javase/7/docs/api/java/io/Reader.html) (Caracteres)
		- int read()
		- int read(char[] buffer)
		- int read(char[] buffer, int offset, int length)
- Métodos básicos de escritura de Streams 
	- Clase [OutputStream](http://docs.oracle.com/javase/7/docs/api/java/io/OutputStream.html) (Bytes)
		- void write(int c)
		- void write(byte[] buffer)
		- void write(byte[] buffer, int offset, int length)
	- Clase [Writer](http://docs.oracle.com/javase/7/docs/api/java/io/Writer.html) (Caracteres)
		- void write(int c)
		- void write(char[] buffer)
		- void write(char[] buffer, int offset, int length)
		- void write(String string)
		- void write(String string, int offset, int length)
		
### Lectura/escritura en ficheros

Los tipos fundamentales de nodos o elementos a los que puede entrar y salir un flujo de datos que se pueden encontrar en el JDK 1.7 de Java son los siguientes:

![](/assets/posts/java/ocp-7/2014-07-03-ocp7_09_principios_basicos_de_es_fig2.jpg)

Todos los flujos deben cerrarse una vez haya finalizado su uso, forzando un `close` dentro de la cláusula `finally`.

### Flujos en Memoria Intermedia

Para la lectura de archivos cortos de texto es mejor utilizar `FileInputStream` en conjunción con `FileReader`. A continuación se añaden algunos ejemplos con código fuente para la memoria intermedia.

Ejemplo `TestBufferedStreams`

```java
package bufferedstreams;
 
import java.io.*;
 
public class TestBufferedStreams {
 
    public static void main(String[] args) {
        try (
           BufferedReader bufInput = 
       new BufferedReader(new FileReader("src\bufferedstreams\file1.txt"));
           BufferedWriter bufOutput = 
       new BufferedWriter(new FileWriter("src\bufferedstreams\file2.txt"))
        ){
            String line = bufInput.readLine();
            while (line != null) {
                
                bufOutput.write(line, 0, line.length());
                bufOutput.newLine();               
                line = bufInput.readLine();                
            }
        } catch (IOException e) {
            System.out.println("Exception: " + e);
        }
    }
}
```

Ejemplo `TestCharactersStreams`

```java
package bufferedstreams;
 
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
 
public class TestCharactersStreams {
 
    public static void main(String[] args) {
        try (FileReader input = new FileReader("src\bufferedstreams\file1.txt");
             FileWriter output = new FileWriter("src\bufferedstreams\file2.txt")) {
 
            int charsRead;
            while ((charsRead = input.read()) != -1) {
                output.write(charsRead);
            }
        } catch (IOException e) {
            System.out.println("IOException: " + e);
        }
    }
}
```

### Entrada y salida estándar

Existen en Java 7 tres flujos estándar principales:

- System.in. Campo estático de entrada de tipo InputStream lo que permite leer desde la entrada estándar.
- System.out. Campo estático de salida de tipo PrintStream lo que permite escribir en la salida estándar.
- System.err. Campo estático de salida de tipo PrintStream lo que permite escribir en el error estándar.

A continuación se indican los métodos principales `print` y `println` de la clase `PrintStream`

- Métodos `print` con parámetros distintos
	- void print(boolean b)
	void print(char c)
	void print(char[] s)
	void print(double d)
	void print(float f)
	void print(int i)
	void print(long l)
	void print(Object obj)
	void print(String s)
- Métodos `println` con parámetros distintos
	void println()
	void println(boolean x)
	void println(char x)
	void println(char[] x)
	void println(double x)
	void println(float x)
	void println(int x)
	void println(long x)
	void println(Object x)
	void println(String x)

Ambos métodos son métodos sobrecargados de la clase PrintStream. A continuación se añade un ejemplo con código fuente para la entrada y salida estándar.

Ejemplo `KeyboardInput`

```java
import java.io.*;
 
public class KeyboardInput {
 
    public static void main(String[] args) {
 
        try (BufferedReader in = new BufferedReader(new InputStreamReader(System.in))) {
            String s = "";
            while (s != null) {
                System.out.print("Type xyz to exit: ");
                s = in.readLine().trim();                
                System.out.println("Read: " + s);
                System.out.println("");
 
                if (s.equals("xyz")) {
                    System.exit(0);
                }
            }
        } catch (IOException e) {
            System.out.println("Exception: " + e);
        }
    }
}
```

## Persistencia

La persistencia consiste en el proceso de serialización (secuencia de bytes) y la deserialización (reconstrucción del objeto obteniendo una copia a partir de los bytes) de un objeto en Java.

Un objeto tiene capacidad de persistencia cuándo puede almacenarse en disco o mediante cualquier otro dispositivo de almacenamiento o enviado a otra máquina y mantener su estado actual correctamente.

Dentro de una aplicación Java, cualquier clase que quiera ser serializada debe implementar la interfaz java.io.Serializable, marcador utilizado para indicar que la clase puede ser serializada.

Puede producirse la excepción NotSerializableException cuándo un objeto no se puede serializar.

Los campos marcados con los modificadores static o transient no pueden ser serializados por lo que al deserializar un objeto dichos campos **apuntaran a un valor nulo o cero al finalizar la reconstrucción del objeto**. 
A continuación se añade un ejemplo con código fuente para obtener la persistencia de los datos de un estudiante. Se incluyen la definición del objeto Student, y las clases para la persistencia junto a la clase de ejecución.

Ejemplo `DeserializeMyClass`

```java
package persistence;
 
import java.io.FileInputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
 
public class DeserializeMyClass {
 
    public static void main(String[] args) {
         
        MyClass myclass = null;
         
        try (ObjectInputStream in = new ObjectInputStream(new FileInputStream("file1.ser"))) {
            myclass = (MyClass) in.readObject();
             
        } catch (ClassNotFoundException | IOException e) {
            System.out.println("Exception deserializing file1.ser: " + e);
        }
        System.out.println("a = " + myclass.a);
        System.out.println("b = " + myclass.b);
        System.out.println("cad1 = " + myclass.getCad1());
        System.out.println("cad2 = " + myclass.getCad2());
    }
}
```

Ejemplo `MyClass`

```java
package persistence;
 
import java.io.Serializable;
 
public class MyClass implements Serializable {
 
    public int a = 0;
    private String cad1 = "";
    static int b = 0;    
    private transient String cad2 = "";
    Student student = new Student();
 
    public String getCad1() {
        return cad1;
    }
 
    public void setCad1(String cad1) {
        this.cad1 = cad1;
    }
 
    public String getCad2() {
        return cad2;
    }
 
    public void setCad2(String cad2) {
        this.cad2 = cad2;
    }
}
```

Ejemplo `SerializeMyClass`

```java
package persistence;
 
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectOutputStream;
 
public class SerializeMyClass {
 
    public static void main(String[] args) {
         
        MyClass myclass = new MyClass();
        myclass.a = 100;
        myclass.b = 200;
        myclass.setCad1("Hello World");
        myclass.setCad2("Hello student");
 
        try (ObjectOutputStream o = new ObjectOutputStream(new FileOutputStream("file1.ser"))) {
            o.writeObject(myclass);
             
        } catch (IOException e) {
            System.out.println("Exception serializing file1.ser: " + e);
        }
    }
}
```

Ejemplo `Student`

```java
package persistence;
 
public class Student {
 
    String name = "Darío";
    int age = 3;
}
```

## Recordatorio

Las clases `BufferedReader` y `BufferedWriter` aumentan la eficacia de las operaciones de entrada y salida. 
Estas clases permiten gestionar el búfer y escribir o leer línea por línea. 
A continuación se añade un ejemplo sencillo utilizando un `BufferedReader` para leer la cadena `xyz` y finalizar la ejecución.1.-Ejemplo utilizando `BufferedReader`

```java
try (BufferedReader in = new BufferedReader(
  new InputStreamReader(system.in)))) {
   String s = "";
   System.out.print("Type xyz to exit");
   s = in.readline().trim();
   System.out.print("Read "+s);
 
   // ...
}
```