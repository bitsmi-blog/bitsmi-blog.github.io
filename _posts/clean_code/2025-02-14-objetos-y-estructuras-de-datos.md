---
author: Xavier Salvador
title: 6.- Objects and Data Structures
page_order: 06
date: 2025-05-14
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

Objects and data structures
Data abstraction

Approaching OOP development we are exposing the implementation.
public class Point {
public double x;
public double y;
}


but using interface development we are hiding this implementation
public interface Point {
double getX();
double getY();
void setCartesian(double x, double y);
double getR();
double getTheta();
void setPolar(double r, double theta);
}
but
The methods enforce an access policy. You can read the individual coordinates independently, but you must set the coordinates together as an atomic operation.

We do not want to expose the details of our data. Rather we want to express our data in abstract terms.

The worst option is to blithely add getters and setters.

Data/Object Anti-Symmetry
fundamental dichotomy between objects and data structures

Procedural code (code using data structures) makes it easy to add new functions without changing the existing data structures. OO code, on the other hand, makes it easy to add new classes without changing existing functions.

The complement is also true:

Procedural code makes it hard to add new data structures because all the functions must change. OO code makes it hard to add new functions because all the classes must change.

So, the things that are hard for OO are easy for procedures, and the things that are hard for procedures are easy for OO!

Mature programmers know that the idea that everything is an object is a myth. Sometimes you really do want simple data structures with procedures operating on them.

Law of Demeter  says a module should not know about the innards of the objects it manipulates

More formal description
A method f of a class C should only call the methods of these:

• C

• An object created by f

• An object passed as an argument to f

• An object held in an instance variable of C

The method should not invoke methods on objects that are returned by any of the allowed functions. In other words, talk to friends, not to strangers.

Train Wrecks
Chains of calls like this are generally considered to be sloppy style and should be avoided.
Netter follow that approach in the example:
Options opts = ctxt.getOptions();
File scratchDir = opts.getScratchDir();
final String outputDir = scratchDir.getAbsolutePath();

Sometimes it seems that the Demeter law has been broken but it depends on the nature of the chain method calls.

The use of accessor functions confuses the issue. If the code had been written as follows, then we probably wouldn’t be asking about Demeter violations.

final String outputDir = ctxt.options.scratchDir.absolutePath;

Main reason why is because all the variables used in the accessor line know what is the context of the real call in the line.

Hybrids
This confusion sometimes leads to unfortunate hybrid structures that are half object and half data structure. They have functions that do significant things, and they also have either public variables or public accessors and mutators that, for all intents and purposes, make the private variables public, tempting other external functions to use those variables the way a procedural program would use a data structure.

Avoid creating them.

Hiding Structure

**Resumen en español del fragmento (Capítulo 6, *Clean Code*)**

El autor ilustra el principio de ocultar la estructura interna de los objetos (Ley de Demeter).

1. **Problema detectado**

    * En el código se quieren obtener rutas absolutas encadenando llamadas como `ctx.getScratchDirectoryOption().getAbsolutePath()`.
    * Esto revela detalles internos: rutas, directorios y otros elementos de bajo nivel quedan expuestos al exterior.

2. **Opciones insuficientes**

    * **Opción 1**: Añadir muchos métodos de acceso (p. ej. `ctxt.getAbsolutePathOfScratchDirectoryOption()`) recarga la interfaz del objeto.
    * **Opción 2**: Devolver estructuras de datos (no objetos) fuerza al cliente a “navegar” por ellas, violando la Ley de Demeter.

3. **Motivo real**

    * Lo que realmente se necesita no es la ruta, sino **crear un archivo temporal**. El ejemplo las líneas posteriores lo demuestran con la construcción manual de rutas y streams de salida.

4. **Solución propuesta**

    * Pedirle directamente al objeto contexto que haga el trabajo:

      ```java
      BufferedOutputStream bos = ctxt.createScratchFileStream(classFileName);
      ```
    * Así:

        * El objeto **oculta su estructura interna**.
        * El cliente **no manipula detalles de directorios ni archivos**.
        * Se favorece un diseño orientado a mensajes (“dile al objeto que haga algo”) en lugar de uno basado en indagar su estado (“pregúntale y hazlo tú”).

**Idea clave**: los objetos deben exponer comportamientos significativos, no sus tripas. Cuando el código externo necesita algo de bajo nivel, plantéate si en realidad solo quiere que “algo suceda”; entonces, delega esa tarea al propio objeto para mantener el encapsulamiento y la claridad del código.
Data Transfer Objects
The quintessential form of a data structure is a class with public variables and no functions. This is sometimes called a data transfer object, or DTO. DTOs are very useful structures, especially when communicating with databases or parsing messages from sockets, and so on. They often become the first in a series of translation stages that convert raw data in a database into objects in the application code.

The quintessential form of a data structure is a class with public variables and no functions. This is sometimes called a data transfer object, or DTO. DTOs are very useful structures, especially when communicating with databases or parsing messages from sockets, and so on. They often become the first in a series of translation stages that convert raw data in a database into objects in the application code.

Beans have private variables manipulated by getters and setters. The quasi-encapsulation of beans seems to make some OO purists feel better but usually provides no other benefit.

Bean example
public class Address {
private String street;
private String streetExtra;
private String city;
private String state;
private String zip;

     public Address(String street, String streetExtra,
                     String city, String state, String zip) {
       this.street = street;
       this.streetExtra = streetExtra;
       this.city = city;
       this.state = state;
       this.zip = zip;
     }

     public String getStreet() {
       return street;
     }

     public String getStreetExtra() {
       return streetExtra;
     }

     public String getCity() {
       return city;
     }

     public String getState() {
       return state;
     }

    public String getZip() {
      return zip;
    }
}

Active Record
Active Records are special forms of DTOs. They are data structures with public (or bean-accessed) variables; but they typically have navigational methods like save and find. Typically these Active Records are direct translations from database tables, or other data sources.

MIxing data structures and objects is not recommended.

The solution, of course, is to treat the Active Record as a data structure and to create separate objects that contain the business rules and that hide their internal data (which are probably just instances of the Active Record).


Conclusion
Objects expose behavior and hide data. This makes it easy to add new kinds of objects without changing existing behaviors. It also makes it hard to add new behaviors to existing objects. Data structures expose data and have no significant behavior. This makes it easy to add new behaviors to existing data structures but makes it hard to add new data structures to existing functions.

In any given system we will sometimes want the flexibility to add new data types, and so we prefer objects for that part of the system. Other times we will want the flexibility to add new behaviors, and so in that part of the system we prefer data types and procedures. Good software developers understand these issues without prejudice and choose the approach that is best for the job at hand.