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
# Data abstraction

Approaching OOP development we are exposing the implementation.
```java
public class Point {
public double x;
public double y;
}
```

but using interface development we are hiding this implementation
```java
public interface Point {
double getX();
double getY();
void setCartesian(double x, double y);
double getR();
double getTheta();
void setPolar(double r, double theta);
}
```

The methods enforce an access policy. You can read the individual coordinates independently, but you must set the coordinates together as an atomic operation.

We do not want to expose the details of our data. Rather we want to express our data in abstract terms.

_The worst option is to blithely add getters and setters_.

# Data/Object Anti-Symmetry
Fundamental dichotomy between objects and data structures

Procedural code (code using data structures) makes it easy to add new functions without changing the existing data structures. OO code, on the other hand, makes it easy to add new classes without changing existing functions.

The complement is also true:

Procedural code makes it hard to add new data structures because all the functions must change. OO code makes it hard to add new functions because all the classes must change.

So, the things that are hard for OO are easy for procedures, and the things that are hard for procedures are easy for OO!

Mature programmers know that the idea that everything is an object is a myth. Sometimes you really do want simple data structures with procedures operating on them.

Law of Demeter  says a module should not know about the innards of the objects it manipulates

More formal description

_A method f of a class C should only call the methods of these_:
1. C
2. An object created by f
3. An object passed as an argument to f
4. An object held in an instance variable of C

The method should not invoke methods on objects that are returned by any of the allowed functions. In other words, talk to friends, not to strangers.

# Train Wrecks
Better follow chains of calls that approach in the example:
```java
Options opts = ctxt.getOptions();
File scratchDir = opts.getScratchDir();
final String outputDir = scratchDir.getAbsolutePath();
```

Sometimes it seems that the Demeter law has been broken but it depends on the nature of the chain method calls.

The use of accessor functions confuses the issue. If the code had been written as follows, then we probably wouldn’t be asking about Demeter violations.
```java
final String outputDir = ctxt.options.scratchDir.absolutePath;
```
Main reason why is because all the variables used in the accessor line know what is the context of the real call in the line.

# Hybrids
This confusion sometimes leads to unfortunate hybrid structures that are half object and half data structure. 

They have functions that do significant things, and they also have either public variables or public accessors and mutators that, for all intents and purposes, make the private variables public, tempting other external functions to use those variables the way a procedural program would use a data structure.

Avoid creating them.

# Hiding Structure

The author illustrates the principle of hiding the internal structure of objects (Law of Demeter).

1. **Detected Problem**

   * In the code, absolute paths are obtained by chaining calls like `ctx.getScratchDirectoryOption().getAbsolutePath()`.
   * This reveals internal details: paths, directories, and other low-level elements are exposed externally.

2. **Insufficient Options**

   * **Option 1**: Adding many accessor methods (e.g., `ctxt.getAbsolutePathOfScratchDirectoryOption()`) clutters the object's interface.
   * **Option 2**: Returning data structures (not objects) forces the client to "navigate" through them, violating the Law of Demeter.

3. **Real Reason**

   * What is really needed is not the path, but to **create a temporary file**. 
   * The example in the following lines demonstrates this with manual construction of paths and output streams.
    ```java
    String outFile = outputDir + “/” + className.replace('.', '/') + “.class”;
    FileOutputStream fout = new FileOutputStream(outFile);
    BufferedOutputStream bos = new BufferedOutputStream(fout);
    ```
4. **Proposed Solution**

   * Ask the context object directly to do the job:
     ```java
     BufferedOutputStream bos = ctxt.createScratchFileStream(classFileName);
     ```

   * This way:
      * The object **hides its internal structure**.
      * The client **does not manipulate directory or file details**.
      * A message-oriented design is favored (“tell the object to do something”) instead of one based on examining its state (“ask it and do it yourself”).

**Key Idea**: objects should expose meaningful behaviors, not their guts. 
When external code needs something low-level, consider whether it really just wants “something to happen”; if so, delegate that task to the object itself to preserve encapsulation and code clarity.

# Data Transfer Objects
The quintessential form of a data structure is a class with public variables and no functions. 

This is sometimes called a data transfer object, or DTO. DTOs are very useful structures, especially when communicating with databases or parsing messages from sockets, and so on. 

They often become the first in a series of translation stages that convert raw data in a database into objects in the application code.

Beans have private variables manipulated by getters and setters. 

The quasi-encapsulation of beans seems to make some OO purists feel better but usually provides no other benefit.

Bean example
```java
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
```

# Active Record
**Active Records** are special forms of DTOs. 

They are data structures with public (or bean-accessed) variables; but they typically have navigational methods like save and find. 

Typically these **Active Records** are direct translations from database tables, or other data sources.

Mixing data structures and objects is not recommended.

The solution, of course, is to treat the **Active Record** as a data structure and to create separate objects that contain the business rules and that hide their internal data (which are probably just instances of the **Active Record**).


# Conclusion
Objects expose behavior and hide data. 

This makes it easy to add new kinds of objects without changing existing behaviors - it also makes it hard to add new behaviors to existing objects. 

Data structures expose data and have no significant behavior -this makes it easy to add new behaviors to existing data structures but makes it hard to add new data structures to existing functions.

In any given system we will sometimes want the flexibility to add new data types, and so we prefer objects for that part of the system. 

Other times we will want the flexibility to add new behaviors, and so in that part of the system we prefer data types and procedures. 

Good software developers understand these issues without prejudice and choose the approach that is best for the job at hand.