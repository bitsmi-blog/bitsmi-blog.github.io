---
author: Xavier Salvador
title: OCP11 - Creating nested classes (IV) - Writing a local class
date: 2021-10-30
categories: [ "java", "ocp-11-17" ]
tags: [ "ocp-11", "ocp-17" ]
layout: post
excerpt_separator: <!--more-->
---

A **local class** is a **nested class defined within a method**. 

Like local variables, a local class declaration does not exist until the method is invoked and it goes out of scope when the method returns.

This means you can create instances only from within the method. Those instances can still be returned from the method. This is how local variables work.

**IMPORTANT NOTE TO CONSIDER FOR THE EXAM**: Local classes are not limited to being declared only inside methods. They can be declared inside constructors and initializers too. For simplicity, we limit our discussion to methods.

Local Classes have the following properties:
- They do not have an access modifier.
- They cannot be declared **static** and cannot declare static fields or methods, except for **static final** fields.
- They have access to all fields and methods of the enclosing class (when defined in an instance method).
- They can access local variables if the variables are **final** or effectively final.

**IMPORTANT NOTE TO CONSIDER FOR THE EXAM**: ***Effectively final*** refers to a local variable whose value does not change after it is set. A simple test for ***effectively final***  is to add the **final** modifierto the local vairable declaration. If it still compiles, then the local variable is ***effectively final***.

Example - Multiply two numbers in a complicated way:
```java
1:  public class PrintNumbers {
2:     private int length = 5;
3:     public void calculate() {
4:        final int width = 20;
5:        class MyLocalClass {
6:           public void multiply() {
7:              System.out.print(length * width);
8:           }
9:        }
10:       MyLocalClass local = new MyLocalClass();
11:       local.multiply();
12:    }
13:    public static void main(String[] args) {
14:       PrintNumbers outer = new PrintNumbers();
15:       outer.calculate();
16:    }
17: }
```
Line 5 is the local class.
Line 7 refers to an instance variable and a final local variable, so both variables references are allowed from within the local class.
Line 9 is the local class.
Line 12 is the place where the class' scope ends.

## Local variables references are allowed if they are final or effectively final
The compile is generatinga .class file from the local class. A separate class has no way to refer to local variables. 

If the local variable is final, Java can handle it by passing it to the constructor of the local class or by storing it in the .class file. 

If it weren't  effectively final, these tricks wouldn't work becuase the value could change after the copy was made.

Example:
```java
public void processData() {
   final int length = 5;
   int width = 10;
   int height = 2;
   class VolumeCalculator {
      public int multiply() {
         return length * width * height; // DOES NOT COMPILE
      }
   }
   width = 2;  // Variable reassignation - origin of the error compilation
}
```
The **length** and **height** variables are **final** and **effectively final**, respectively, so neither causes a compilation issue.

On the other hand, the **width** variable is reassigned during the method so it cannot be effectively final. This is the reason why the local class declaration does not compile.
