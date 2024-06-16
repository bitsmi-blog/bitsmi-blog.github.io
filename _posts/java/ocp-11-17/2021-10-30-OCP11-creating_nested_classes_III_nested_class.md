---
author: xavsal
title: OCP11 - Creating nested classes (III) - Creating an static nested class
date: 2021-10-30
categories: [ "java", "ocp-11-17" ]
tags: [ "ocp-11", "ocp-17" ]
layout: post
excerpt_separator: <!--more-->
---

A ***static nested class*** is a **static type**  defined at the member level. Unlike an inner class, a **static nested class** can be instantiated without an instance of the ecnlosing class. 

The trade-off though, is it can't access instance variables or methods in the outer class directly. It can be done but it requires an explicit reference to an outer class variable. It is like a top-level class except for:

- The nesting creates a namespace because the cnlosing class name must be used to refer it.
- It can be made **private** or use one of the other access modifiers to encapsulate  it.
- The enclosing class can refer to the fields and methods of the **static nested class**.

Example:
```java
1: public class Enclosing {
2:    static class Nested {
3:       private int price = 6;
4:    }
5:    public static void main(String[] args) {
6:       Nested nested = new Nested();
7:       System.out.println(nested.price);
8: } }
```
**Line 6** instantiates the nested class. Since the class is static, you don't need an instance of Enclosing to use it.
**Line 7** allows you to access private instance variables.

## Importing a *static* Nested Class
Importing a **static** nested class is done using the regular **import**.
```java
  // Toucan.java
    package bird;
    public class Toucan {
       public static class Beak {}
    }
    // BirdWatcher.java
    package watcher;
    import bird.Toucan.Beak; // regular import ok
    public class BirdWatcher {
       Beak beak;
    }
```
Since it is static you can also use a **static import**:
```java 
import  static  bird.Toucan.Beak;
```
**IMPORTANT TO CONSIDER HERE FOR THE EXAM**: Java treats the cnsloing class as if were a namespace.
