---
author: xavsal
title: OCP 11 - Language Enhancements (Java Fundamentals - Final modifier)
date: 2021-06-02
categories: [ "java", "ocp-11-17" ]
tags: [ "ocp-11", "ocp-17" ]
layout: post
excerpt_separator: <!--more-->
---

## Introduction
**Final** modifier can be applied to *variables, methods and classes*.
Marking a:
1. **Variable** final means the value cannot be changed after it is assigned.
2. **Method** or a **class** means it cannot be overridden (for methods) or extended (for classes).

## Declaring final local variables
For **final** variables there are several aspects to consider.

We do not need to assign a value to the final variable when we declare it. What we have to assure is the a value has been assigned to it before this final variable is used. We will get a compilation error in case we don't follow this rule. Example which illustrates this:
```java
private void printZooInfo(boolean isWeekend) {
    final int giraffe = 5;
    final long lemur;
    if (isWeekend) lemur = 5;
    giraffe = 3; // DOES NOT COMPILE   
    System.out.println(giraffe+" "+lemur); // DOES NOT COMPILE
}
```
Here we have **two** compilation errors:
1. The ***giraffe*** variable has an assigned value so we can't assign a new value because it has been declared as **final**. We will get a compilation error.
2. When attempting to use ***lemur*** variable we will get a compilation error. If condition ***isWeekend*** is *false* we can't assign the value to ***lemur*** so we will the error the error compilation because a local variable to has to be declared and assigned before using it (despite the fact of being declared as **final** or not).

When we mark a variable as **final** it does not mean that the object associated with it cannot be modified. Example to illustrate this:
```java
final StringBuilder cobra = new StringBuilder();
cobra.append("Hssssss");
cobra.append("Hssssss!!!");
```
We have declared the variable as constant but the content of the class can be modified.

## Adding final to Instance and static variables
**Instance** and **static** class variables can be marked as **final** too.

When we mark as **final** a:
1. **Instance** variable which it means that it must be assigned a value when it is declared or when the object is instantiated (Remember: We can only assign once, like Local Variables). Example to illustrate this:
```java
public class PolarBear {
   final int age = 10;
   final int fishEaten;
   final String name;

   { fishEaten = 10; }

   public PolarBear() {
      name = "Robert";
   }
   public PolarBear(int height) {
      this();
   }
}
```
Does this code compile?  Yes. Everything. Exercise: Explain why.

2. **Static** variable which it means they have to use ***static*** initializers instead of ***instance*** initializers. Example to illustrate this:
```java
public class Panda {
  // We assign a value when we declare the final variable
  final static String name = "Ronda";
  static final int bamboo;
  static final double height; // DOES NOT COMPILE - Why? Because we do not have assign any value to height variable  
  // It will work because we are initializing a final static variable through an static initializer
  static { bamboo = 5;}}
```  

## Writing final methods
Methods marked as **final** cannot be overriden by a **subclass**. This avoids polymorphic behavior and always ensures that it is always called the same version method. Be aware because a method can have **abstract** or **final** modifier but not both at the same time.

When we combine *inheritance with **final** methods* we always get an error compilation.

We cannot declare a method **final** and **abstract** at the same time. It is not allowed by the compiler and of course we will get a compilation error.
Example to illustrate this:
```java
abstract class ZooKeeper {   
	public abstract final void openZoo(); // DOES NOT COMPILE
}
```

## Marking Classes final
A **final** class is one class that *cannot be extended*. In fact we will get a compilation error if we tried. Example to illustrate this:
```java
public final class Reptile {}
public class Snake extends Reptile {} // DOES NOT COMPILE
```
We cannot use abstract and final modifiers at the same time. 
```java
public abstract final class Eagle {} // DOES NOT COMPILE
```   
It also happens the same for interfaces.
```java
public final interface Hawk {} // DOES NOT COMPILE
```
We will get a compilation error in both cases.
