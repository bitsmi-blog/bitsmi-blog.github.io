---
author: xavsal
title: OCP 11 - Language Enhancements (Java Fundamentals - Enumerations)
date: 2021-09-27
categories: [ "java", "ocp-11-17" ]
tags: [ "ocp-11", "ocp-17" ]
layout: post
excerpt_separator: <!--more-->
---

Generally speaking an *Enumeration* is like a fixed set of constants. But in Java an *enum* (short for enumerated type) can be a top-level type like a class or a interface, as well as a nested type like an inner class.

Using an enum is much better than using a lot of constants because it provides **type safe checkline**. With numeric or Strings contants you can pass an invalid value and not find out until runtime. On the other hand, with enums it is impossible to create an invalid value without introducing a compiler error.

<!--more-->

### Creating simple enums
To create and enum, use the enum keyword. Then list all of the valid types for that enum:

```java
public enum Season {
	WINTER, SPRING, SUMMER, FALL
}
```

**NOTE**: Enum values are considered constants and are commonly written using snake case (*snake_case*). 

Behind the scenes, an enum is a type of a class that mainly constains static members. It also includes some helper methods like *name()*.
Example of using an enum:
```java
Season s = Season.SUMMER;
System.out.println(Season.SUMMER); // SUMMER
System.out.println(s == Season.SUMMER); // true
```

As it is seen in the example, enums print the name of the enum when *toString()*. They can be compared using == because they are like *static final* constants.
In other words, you can use equals() or  == to compare enums, since each enum is initialized only once in the JVM.

***values()***: method allows to get an array of all of the values. Each value in the enum has a corresponding int value and values are listed in the order they are declared.

**NOTE-FOR EXAM**: You can't compare an int and enum value directly anyway since an enum is a type (like a Java class) and int is a primitive type.
Example - not compiling:
```java
if ( Season.SUMMER == 2) { }; // DOES NOT COMPILE
```

***valueOf()***: It is helpful when working with older source code. The String passed in must match eh enum value exactly.
Example:
```java
// (1) 
Season s = Season.valueOf("SUMMER");  // SUMMER
// (2) 
Season t = Season.valueOf("summer");  // Throws an exception at runtime
```
(1) is assigning the proper enum value to s. Consider that it is not creating an enum value, at least not directly.
Each enum value is created once when the enum is first loaded, when it is possible to retrieve each enum value.

(2) encounters a problem becuase there is no enum value for name given. In this case Java throws an **IllegalArgumentException**:
```java
Exception in thread "main" java.lang.IllegalArgumentException:
   No enum constant enums.Season.summer
```

**NOTE - FOR EXAM**: It is not possible to extend an enum. The values in an enum are all that are allowed.
```java
public enum ExtendedSeason extends Season { } // DOES NOT COMPILE
```

### Using Enums in Switch statements
Enums can be used in switch statements. Pay attention to the case values in this example:
```java
Season summer = Season.SUMMER;
switch (summer) {
   case WINTER:
      System.out.println("Get out the sled!");
      break;
   case SUMMER:
      System.out.println("Time for the pool!");
      break;
   default:
      System.out.println("Is it summer yet?");
}
```
In each case statement we just typed the value of the enum rather than writing `Season.WINTER`. After all, the compiler already knows that the only possible matches can be enum values. **Java treats the enum type as implicit.**
Example which shows us in this example:
```java
Season summer = Season.SUMMER;
switch (summer) {
   case Season.FALL:	// (1) DOES NOT COMPILE
      System.out.println("Rake some leaves!");
      break;
   case 0:				// (2) DOES NOT COMPILE
      System.out.println("Gedt out the sled!");
      break;
}
```
(1) does not compile because `Season` is used in the case value. If we changed `Season.FALL` to just `FALL`, the line would compile.

(2) It is not possible to compare enums with primitive type int (**NOTE - FOR EXAM**). 

### Adding constructors, Fields and Methods
Enums can have more in them than just a list of values. Look for this example:
```java
1: public enum Season {
2:    WINTER("Low"), SPRING("Medium"), SUMMER("High"), FALL("Medium");
3:    private final String expectedVisitors;
4:    private Season(String expectedVisitors) {
5:       this.expectedVisitors = expectedVisitors;
6:    }
7:    public void printExpectedVisitors() {
8:       System.out.println(expectedVisitors);
9:    } }
```
Things to notice in this example:
- Line 2. 
The list of enum values ends with a semi colon. While this is optional when our enum is composed solely of a list of values, it is required if there is anything in the enum besides the values.
- Line 3-9. Regular java code where marking final the variable we ensure that we consider our enum values as immutable (despite not being obligatory, it is a good practice to follow). It also ensures that none of the value inside the enum will be modified by any process from the JVM.


#### Creating immutable objects
The *immutable objects pattern* is an object-oriented design pattern in which an object cannot be modified after it is created. Instead of modifyng an object you create a new object that contains any properties from the original object you copied over.

Many java libraries contain immutable objects like String or classes in java.time package. Immutable objects are invaluable in concurrent applications since the state of the object cannot change or be corrupted by a rogue thread (it will detailed in section **Concurrency**).

### Enum constructors
Al enum constructors are generally private with the modifier being optional. So an enum constructor will not compile if it contains a public or protected modifier.
Example on how can we call an enum method:
```java
Season.SUMMER.printExpectedVisitors();
```
We are not calling the constructor. We are saying that we just want the enum value. The first time that we ask for any of the enum values, java constructs all of the enum values. After that, java just returns the already constructed enmum values.
Example where we can see why the constructor is called once:
```java
Season.SUMMER.printExpectedVisitors();
```

**How it works**: The first time we ask for any enum vlaue, Java constructs all of the enum values. After that, Java just returnsthe already constructed enum values. Following this explanation now it is described why the constructor is only called **once**. Example:
```java
public enum OnlyOne {
   ONCE(true);
   private OnlyOne(boolean b) {
      System.out.print("constructing,");
   }   
}
 
public class PrintTheOne {
   public static void main(String[] args) {
      System.out.print("begin,");
      OnlyOne firstCall = OnlyOne.ONCE;  // prints constructing,
      OnlyOne secondCall = OnlyOne.ONCE; // doesn't print anything
      System.out.print("end");
   }
}
```
and it prints
```java
begin, constructing, end
```

**Detailed explanation**: If the **OnlyOne** enum was used earlier and initialize sooner, then the line that declares the `FirstCall` variable would not print anything.

This technique of a **constructor and state** allows you to combine logic with the benefit of a list of values. Several times we need to add more information in the enum. For example, in previous `Season` example enum we can keep track of the daylight hours through instance variables:
```java
public enum Season {
   WINTER {
      public String getHours() { return "10am-3pm"; }
   },
   SPRING {
      public String getHours() { return "9am-5pm"; }
   },
   SUMMER {
      public String getHours() { return "9am-7pm"; }
   },
   FALL {
      public String getHours() { return "9am-5pm"; }
   };
   public abstract String getHours(); (1)
}
```
**Deeper explanation**: We have created an abstract class and several tiny subclasses. The enum itself has an **abstract** method (1). It really means that each and every enum value is required to implement this method. **Note for the exam**: If we forget to implement the method for one of the values, we will get a compiler error.

**Conclusion**: The enum constant WINTER must implement the abstract method getHours()

In case we don't want to force each enum value to have a method we have to remove the *abstract* keyword and just add a default implementation.
Example:
```java
public enum Season {
   WINTER {
      public String getHours() { return "10am-3pm"; }
   },
   SUMMER {
      public String getHours() { return "9am-7pm"; }
   },
   SPRING, FALL;
   public String getHours() { return "9am-5pm"; }
}
```
Following this approach we only use method in cases we want. Another thing to consider is if we want to overwrite **getHours()** we don't have to use the *final* classifier. 

General rule is to **keep the enums we create as simple as we can**. Being long makes it difficult to read.

**Note-for-exam**: In enums the list of values came first so the **compiler always requires that the list of values must be always declared first** despite the enum is short or long.
