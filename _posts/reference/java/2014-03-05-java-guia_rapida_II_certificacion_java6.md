---
author: Xavsal
title: Java – Guía rápida – 2ª parte - Certificación Java 6
date: 2014-03-05
categories: [ "references", "java" ]
tags: [ "reference", "java" ]
layout: post
excerpt_separator: <!--more-->
---

<!--more-->

## Hilos

Declarar un método `synchronized` junto con `static` asegura que dicho método será ***thread-safe***.

Es posible sincronizar métodos estáticos y el método Object.wait() sólo puede invocarse des de un contexto de sincronización.

El método Object.notify() escoge arbitrariamente que hilo notificar.

Para ordenar las claves de un HashMap de la interfície Set debe emplearse `TreeSet`.

```java
Set s  =  props.keySet();
s =  new TreeSet(s);
```

## java.io.Serializable

- Un objeto serializado en una JVM puede ser correctamente deserializado en otra JVM
- Los valores en los campos asignados con el modificador `transient` no sebreviven al proceso de serialización / deserialización
- Es legal serializar un objecto de un tipo que tiene un supertipo que no implementa `java.io.Serializable`

## Final

Si se intenta modificar un valor de un atributo de tipo final, no se mantiene el valor del atributo si no que se produce un error de compilación.

## Object puede contener arrays de tipos primitivos

Ambas asignaciones son correctas en el siguiente ejemplo.

```java
Object obj = new int[]{1,2,3};
int[] someArray = (int[])obj;
```

## Console

```java
// Get a console object
//
Console console = System.console();

//
// Read username from the console
//
String username = console.readLine("Username: ");

// Other ways to read something from console
String s = console.readline();
String s = console.readline(“%s”,  “name ”);

// Read password, the password will not be echoed to the console screen // and returned as an array of characters.
char[] password = console.readPassword("Password: ");

if(username.equals("admin") && String.valueOf(password).equals("secret")) { console.printf("Welcome to Java Application %1$s.\n", username);

//
// Clear the password after validation successful
//
        Arrays.fill(password, ' ');
   } else {
        console.printf("Invalid username or password.\n");  
   }
}
```

## $ y _

En la declaración de variables, `$` y `_` pueden utilizarse como primera letra de la variable.

```java
int $age=10; Double _doble;
```

## Static

Recordar que los métodes estaticos siempre necesitan el nombre de la clase para ser accedicos desde `main`. Pasa lo mismo tambien con los atributos o variables de referencia estáticas

- Las construcciones por herencia siempre llaman al constructor padre desde el construtor hijo.
- Una interfaz se puede implementar utilizando directamente `new Interfaz()`. Es una interfaz anónima.
- Herencia: **Recordar**. Siempre que se utilizan constructores, siempre se ejecuta primero los de la superclase y después los de la clase hija
- Utilizando la interfaz `Runnable`, es posible sobreescribir la implementación del método `run()` dentro de la próxima declaración del `Thread` incluso habiendo definido con anterioridad el método
en una implementación de `run()`.

## Synchronized.

Declaración correcta de tres métodos sincronizados distintos:

```java
public synchronized void go() {}

void go() { synchronized(Object.class) {} }

void go() {  Object o = new Object(); synchronized(o); {}}
```

## SCJP exam

- What are some potential trips/traps in the SCJP exam?
- Two top-level public classes cannot be in the same source file.
- main() cannot call an instance (non-static) method.
- Methods can have the same name as the constructor(s).
- Watch for thread initiation with classes that don’t have a run() method.
- Local classes cannot access non-final variables.
- Case statements must have values within permissible range.
- Watch for Math class being an option for immutable classes.
- instanceOf is not the same as instanceof.
- Constructors can be private.
- Assignment statements can be mistaken for a comparison; e.g., if(a=true)…
- Watch for System.exit() in try-catch-finally blocks.
- Watch for uninitialized variable references with no path of proper initialization.
- Order of try-catch-finally blocks matters.
- main() can be declared final.
- 0.0 == 0.0 is true.
- A class without abstract methods can still be declared abstract.
- Map does not implement Collection.
- Dictionary is a class, not an interface.
- Collection (singular) is an Interface, but Collections (plural) is a helper class.
- Class declarations can come in any order (e.g., derived first, base next, etc.).
- Forward references to variables gives a compiler error.
- Multi-dimensional arrays can be "sparse" — i.e., if you imagine the array as a matrix, every row need not have the same number of columns.
- Arrays, whether local or class-level, are always initialized. Sort realiza una ordenación natural de un array de elementos de tipo primitivo o tipo Object.
- Strings are initialized to null, not empty string.
- An empty string is not the same as a null reference.
- A declaration cannot be labelled.
- continue must be in a loop (e.g., for, do, while). It cannot appear in case constructs.

## Primitive array types

- Primitive array types can never be assigned to each other, even though the primitives themselves can be assigned. For example, ArrayofLongPrimitives = ArrayofIntegerPrimitives gives compiler error even though longvar = intvar is perfectly valid.
- A constructor can throw any exception.
- Initializer blocks are executed in the order of declaration.
- Instance initializers are executed only if an object is constructed.
- All comparisons involving NaN and a non-NaN always result in false.
- Default type of a numeric literal with a decimal point is double. int and long operations / and % can throw an ArithmeticException, while float and double / and % never will (even in case of division by zero).
- == gives compiler error if the operands are cast-incompatible.

## Object casting

- You can never cast objects of sibling classes (sharing the same parent).
- equals() returns false if the object types are different. It does not raise a compiler error.
- No inner class (non-static inner class) can have a static member.
- File class has no methods to deal with the contents of the file.
- InputStream and OutputStream are abstract classes
- In Enum the expressions (One==One) and One.equals(One) are both guaranteed to be truth.

## Priority Queue:

Cola de proridades ordenada por orden natural de sus elementos. Dispone de tres métodos:

-  Offer(Elemento): Añade nuevos elementos a la cola.
- Poll(): Recupera el primer elemento de la cola.
- Peek(): Recupera el primer elemento de la cola y lo elimina de la cola.

En métodos la notación

```java
<? extends BaseClass> o <N extends Number> o <N extends Integer>
```

Implica que puede recibir cómo parámetro un elemento de la clase derivada o de la clase base

## Question about list and generics

When you have a List<? extends String> you can read Strings from it, but you can’t add anything to it.
When you have a List<? super String> you can add Strings to it, but you can only read Objects from it.

In short
With <? super X> you can add anything that IS-A X.
With <? extends X> you can only add null.

## SCJP exam

What are some potential trips/traps in the SCJP exam?

- Two top-level public classes cannot be in the same source file.
- main() cannot call an instance (non-static) method.
- Methods can have the same name as the constructor(s).
- Watch for thread initiation with classes that don’t have a run() method.
- Local classes cannot access non-final variables.
- Case statements must have values within permissible range.
- Watch for Math class being an option for immutable classes.
- instanceOf is not the same as instanceof.
- Constructors can be private.
- Assignment statements can be mistaken for a comparison; e.g., if(a=true)…
- Watch for System.exit() in try-catch-finally blocks.
- Watch for uninitialized variable references with no path of proper initialization.
- Order of try-catch-finally blocks matters.
- main() can be declared final.
- 0.0 == 0.0 is true.
- A class without abstract methods can still be declared abstract.
- Map does not implement Collection.
- Dictionary is a class, not an interface.
- Collection (singular) is an Interface, but Collections (plural) is a helper class.
- Class declarations can come in any order (e.g., derived first, base next, etc.). 
- Forward references to variables gives a compiler error.
- Multi-dimensional arrays can be "sparse" — i.e., if you imagine the array as a matrix, every row need not have the same number of columns. Arrays, whether local or class-level, are always initialized 
- Strings are initialized to null, not empty string.
- An empty string is not the same as a null reference.
- A declaration cannot be labelled.
- continue must be in a loop (e.g., for, do, while). It cannot appear in case constructs.
- Primitive array types can never be assigned to each other, even though the primitives themselves can be assigned. For example, ArrayofLongPrimitives = ArrayofIntegerPrimitives gives compiler error even though longvar = intvar is perfectly valid.
- A constructor can throw any exception.
- Initializer blocks are executed in the order of declaration.
- Instance initializers are executed only if an object is constructed.
- All comparisons involving NaN and a non-NaN always result in false.
- Default type of a numeric literal with a decimal point is double.
- int and long operations / and % can throw an ArithmeticException, while float and double / and % never will (even in case of division by zero).
- == gives compiler error if the operands are cast-incompatible.
- You can never cast objects of sibling classes (sharing the same parent).
- equals() returns false if the object types are different. It does not raise a compiler error.
- No inner class (non-static inner class) can have a static member.
- File class has no methods to deal with the contents of the file.
- InputStream and OutputStream are abstract classes

## Hereditary topics

Cuándo se realizan asignaciones entre clases padre e hija debe tenerse en cuenta lo siguiente:

- On es poden veure les correctes assignacions. Revisar, doncs s’hi troba l’explicació de quines operacions es poden fer i quines no.
- Object[] myObjects = {new Integer(12), new String("Foo"), new Integer(5), new Boolean(true)}; Arrays.sort(myObjects);
- Genera un error de compilación ClassCastException doncs no és possible convertir un String en un Integer dentro del método Sort.
- classe derivada ha de cridar al constructor de la classe PARE PER NASSOS en el seu constructor. La típica crida a la classe base pot ser super(); o al constructor definit a la classe pare.
- Un constructor de una clase puede disponer de los modificadores public, private o protected como tipo previo.

```java
protected/public/private Constructor() {...}
```

- En programación orientada a objetos siempre se persigue un BAJO ACOPLAMIENTO (baja dependencia entre unas clases y otras) entre clases y una ALTA COHESIÓN () en las clases.
- Amb post i preincrements, el següent codi

```java
System.out.println("x = "+x++ );
```

printa el valor original de X no l’increment. Això indica que en el pre i en el postincrement és necessari assignar prèviament el valor a una variable abans d’imprimir-la.

- Si Classpath apunta a “.” fa referència al directori actual. per tant el següent java -classpath /apps com.company.application.MainClass can ran from any directory.
- El -d permet especificar en quina carpeta deixarem el *.class obtingut.
- Per imports static es suficient amb realitzar l’import de import static utils.Repetition.nom_metode on nom_metode ha estat declarat com a estàtic.
- Dins un mètode estàtic no es poden fer referències a mètodes o variables no estàtic, només a mètodes o variables estàtic.
- A més, la implementació i declaració d’un mètode no estàtic pot no estar estar associat a una classe. Aquest exemple és correcte:

```java
Comparable –> int compareTo(Object obj). Comparator –> int compare(T o1, T o2)
```

- Hash code method es fa servir per testejar la desigualtat de la classe que el té implementat però no la igualtat. De la mateixa manera, el fa servir java.Set.HashSet collection class per agrupar els elements dins del set en capses de hash ique permeten una recuperació directa.
- El fet de només implementar l’equals però no hashCode implica que per exemple, pel codi següent:
- un HashSet podría contenir múltiples objectes de tipus Person amb el mateix nom.
- Quan es disposa d’un constructor amb un tipus primitiu int i des del mai es crida al constructor passant el tipus d’objecte equivalent, Integer, es produeix un NullPointerException perquè el mètode espera un tipus primitiu no l’objecte tot i ser equivalents.
- RunTimeException no és necessari capturarla
- Cal recordar que la implementació d’una interfície en una clase base no implica que les classes derivades la implementin. Això vol dir que només es pot fer un cast cap al tipus de la interficie d’aquella classe que l’implementi.
- StringBuffer threadSafe. String builder no threadsafe.

Scenarios safe to replace StringBuilder by StringBuffer:

- When using the java.io class StringBufferInputStream
- When you plan to reuse the StringBuffer to build more than one String.

Scenarios NOT safe to replace StringBuilder by StringBuffer: 

- When using versions of Java Technology earlier than 5.0
- When sharing a StringBuffer among multiple Threads.

–java.io.FileWriter és l’únic que escriu una línia de separació a un stream obert.
–DateFormat object fa servir mètode df.parse i llença una excepció de tipus ParseException.
–Date d = new Date(0L); significa que la data construïda es January 1, 1970 on OL is the number 0. The L makes the number along type.
	- No és possible fer un cast a tipus String de qualsevol altra classe complexa.
	- En herència cal vigilar quan s’assignen tipus de clases derivades a classes bases doncs el mètode que es crida sempre és el de la clase derivada no la del tipus contenidor.

pe. ClasseBase bb = new ClaseDerivada

on ambdues tenen un ClasseBase:public void print("base") i derivada ClasseBase:public void print("derivada"). S’imprimirà "derivada".

- Recordar que els mètodes estatics SEMPRE necessiten EL NOM DE LA CLASSE per ser accedits des del MAIN. Passa el mateix també amb els atributs o variables de referencia estàtiques.
- Les construccions per herencia SEMPRE criden al constructor pare des del contructor fill.
- Una interficie es pot implementar fent directament new Interficie(). Es una interficie anonima.

[Etiquetas en Java](https://www.developer.com/java/data/understanding-the-java-labeled-statement.html)
Ejemplo rápido:

```java
// It is not a keyword it is a label.
// Usage:
    label1:
    for (; ; ) {
        label2:
        for (; ; ) {
            if (condition1) {
                // break outer loop
                break label1;
            }
            if (condition2) {
                // break inner loop
                break label2;
            }
            if (condition3) {
                // break inner loop
                break;
            }
        }
    }
```
	