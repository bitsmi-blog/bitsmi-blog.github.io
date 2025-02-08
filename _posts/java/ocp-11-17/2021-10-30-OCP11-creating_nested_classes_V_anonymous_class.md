---
author: Xavier Salvador
title: OCP11 - Creating nested classes (V) - Defining an Anonymous Class
date: 2021-10-30
categories: [ "java", "ocp-11-17" ]
tags: [ "ocp-11", "ocp-17" ]
layout: post
excerpt_separator: <!--more-->
---

A ** anonymouys class** is a specialized form of a local class that does not have a name.

It is declared and instantiated all in one statement using the new keyword, a type name with parenthesis, and a set of braces {}.

Anonymous classes are required to extend an existing class or implement an existing interface.

Example using an **Abstract** class:
```java
  public class ZooGiftShop {
     abstract class SaleTodayOnly {
        abstract int dollarsOff();
     }
     public int admission(int basePrice) {
        SaleTodayOnly sale = new SaleTodayOnly() {
           int dollarsOff() { return 3; }
        };  // Don't forget the semicolon!
        return basePrice - sale.dollarsOff();
} }
```
**Line 2 through 4** define an abstract class through .
**Line 6 through 8** define the anonymous class (it hasn't a name).
The code says to instantiatea new **SaleTodayOnly** object. It is abstract but it is ok because we provide the class body right there - anonymously. 
In this example, writing an anonymous class is equivalent to writing a local class with an unspecified name that extends **SaleTodayOnly** and then immediately using it.
**Line 8** specifically we are declaring a local variable on these lines. Local variable declarations are required to end with semicolons, just like ohter java statements - even if they are long and happen to contain an anonymous class.

<!--more-->

Same example bus using an interace:
```java 
public class ZooGiftShop {
     interface SaleTodayOnly {
        int dollarsOff();
     }
     public int admission(int basePrice) {
        SaleTodayOnly sale = new SaleTodayOnly() {
           public int dollarsOff() { return 3; }
        };
        return basePrice - sale.dollarsOff();
 } }
```
**Lines 2 through 4** declare an interface instead of an abstract class. 
**Line 7** is public instead of using default access since interfaces require public methods. And that is it. The anonymous class is the same whether you implement an interface or extend a class! Java figures out which one you want automatically. 
**Line 6** - in this second example, an instance of a class is created in this line , not an interface.

But what if we want to implement both an interface and extend a class? You can't with an anonymous class, unless the class to extend is **java.lang.Object**. The **Object** class doesn't count in the rule. Remember that an **anonymous class** is just an **unnamed local class**. 

You can write a local class and give it a name if you have this problem. Then you can extend a class and implement as many interfaces as you like. If your code is this complex, a local class probably isn't the most readable option anyway.

# Anonymous classes outside a method body
You can even define anonymous classes outside a method body. The following may look like we are instantiating an interface as an instance variable, but the {} after the interface name indicates that this is an anonymous inner class implementing the interface.
Example:
```java
public class Gorilla {
   interface Climb {}
   Climb climbing = new Climb() {};
}
```
