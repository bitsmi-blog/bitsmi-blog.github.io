---
author: Xavier Salvador
title: OCP11 - Creating nested classes (I)
date: 2021-10-30
categories: [ "java", "ocp-11-17" ]
tags: [ "ocp-11", "ocp-17" ]
layout: post
excerpt_separator: <!--more-->
---

A ***nested class*** is a class that is defined within another class. We have **four** different nested classes types:

1. **Inner** class: A *non-static* type defined at the member level of a class.
2. **Static** nested class: A static type defined at the member level of a class.
3. **Local** class: A class defined within a method body.
4. **Anonymous** class: A special case of a local class that does not have a name.

By convention we use the term **inner** or **nested class** to apply to other Java types, including enums and interfaces.

**Interfaces** and **enums** can be declared as both **inner classes** and **static nested classes** but **not** as **local** or **anonymous** classes.

We will explain each one of these nested classes in a different post and we will use this post to show which are the syntax rules permitted in Java for nested classes in three tables.


<!--more-->

## Modifiers in Nested Classes

|  Permitted modifiers | Inner class  | static nested class  | Local class  | Anonymous class  |
| ------------ | ------------ | ------------ | ------------ | ------------ |
| Access modifiers  | All  | All  | None  | None  |
| abstract  | Yes  | Yes  | Yes  | No  |
| final  | Yes  | Yes  | Yes | No  |

## Members in Nested Classes

|  Permitted modifiers | Inner class  | static nested class  | Local class  | Anonymous class  |
| ------------ | ------------ | ------------ | ------------ | ------------ |
| Instance methods  | Yes  | Yes  | Yes  | Yes  |
| Instance variables | Yes  | Yes  | Yes  | Yes  |
| static methods  | No  | Yes  | No | No  |
| static variables  | Yes (if final)  | Yes  | Yes (if final) | Yes (if final)  |

## Nested classes access rules

|  Permitted modifiers | Inner class  | static nested class  | Local class  | Anonymous class  |
| ------------ | ------------ | ------------ | ------------ | ------------ |
| Can extend any class or implement any number of interfaces  | Yes  | Yes  | Yes  | No - must have exactly one superclass or one interface  |
| Can access instance members of enclosing class without a reference  | Yes  | No  | Yes (if declared in an instance method)  | Yes (if declared in an instance method)  |
| Can access local variables of enclosing method  | N/A  | N/A  | Yes (if final or effectively final) | Yes (if final or effectively final)  |


