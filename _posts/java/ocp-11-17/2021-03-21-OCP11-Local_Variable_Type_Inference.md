---
author: Xavier Salvador
title: OCP11 - Local Variable Type Inference
date: 2021-03-21
categories: [ "java", "ocp-11-17" ]
tags: [ "ocp-11", "ocp-17" ]
layout: post
excerpt_separator: <!--more-->
---

## Working with Local Variable Type Inference

After Java 10 we can use the keyword **var** instead of the type for **local variables** (like the primitive or the reference type) under certain conditions within a code block.

```java
public void whatTypeAmI {
    var name = "Hello";
    var size = 7;
}
```

The formal name of this feature is ***local variable type inference*** but we have to consider two main parts for this feature.

<!--more-->

### Local variable.

This feature **can only be used with local variables only**.

```java
public class VarKeyword {
    var tricky = "Hello";
}
```

**IMPORTANT -> Exam trick** This code **won't compile** because it exists a difference between **instance variable** (the tricky from class) and **local variable**.

Var feature **local variable type inference** *only works with local variables and not instance variables*.

### Type Inference of var

When you type var, **you are instructing the compiler to determine the type for you**. The compiler looks at the code on the line of the declaration and uses it to infer the type.

```java
public void reassignment() {
    var number = 7; // (1)
    number = 4;     // (2)
    number = "five";  // (3) DOES NOT COMPILE
}
```

On (1) it will work as expected with the compiler determining that we want is an *int* variable. On (2) it will work without any problem. On (3) it does not work because we are trying to assign an **String** to an *int*. Its similar to do *int number = "five"*;

**IMPORTANTE TO CONSIDER** **var** is a specific type from Java **defined at compile time** but it does **not change type at runtime**.

Despite we cannot change the type, we are able to manage the value following this example:

```java
var apples = (short) 10; // (1)
apples = (byte) 5; // (2)
apples = 1_000_000;  // (3) DOES NOT COMPILE
```

On (1) we are creating an apples var of *short* type. On (2) we are assigning a byte to the apples var. **We are not changing its type but its value**. We can do that because the *byte* value can be fit inside the *short* value. **Important** - We are storing a *short* not a *byte* (by using var instead of *short* we are delegating the type management to the **compiler**). On (3) the code does not compile because 1 M is beyond the limits of short type. The compiler will manage the value as an int and when it tries to assign the value into the short, it reports an error indicating that we can\'t assign the value to apples.

**As a general rule we consider that the var variable declaration and its initialization value is done in a single line.**

### Examples with var

#### Do this code compile?

```java
public void doesThisCompile(boolean check) {
    var question;   // (1)
    question = 1;
    var answer;     // (2)
    if (check) {
        answer = 2;
    } else {
        answer = 3;
    }
    System.out.println(answer);
}
```

The code **won't compile**. Main reason is due to that the compiler only looks at the line with the declaration. Doing it separately will produce a **compilation error** because ***question and answer*** are not **assigned when defined**.

But what about the if/else structure? We are in the same situation as before, we are not doing the assignment on the same line as the declaration so it won't count for var.

#### Does this code compile?

```java
public void twoTypes {
    int a, var b= 3;    // (1) DOES NOT COMPILE
    var n = null;       // (2) DOES NOT COMPILE
}
```

On (1) it won't compile because all the types declared on a single line must be the same type and share the same declaration. We can't write

```java
    int a, int b = 3;
    // or 
    var a = 2, b = 3;
```

**General Rule - Java does not allow var in multiple-variable declarations**.

On (2) we have a single line where the compiler is being asked to infer the type *null*. This means that it could be any reference type but the only choice the compiler could make is **Object**.

### Var and null

A var **cannot be initialized with a null value** but later we *can assign this null value after its declaration*.

#### Does this compile?

```java
var n = myData; // We declare and assign the var
n = null;           // but we assign to it a null value
```

We can do this in this way because the real data type for ***n*** is an object (**String** type in this example).

It exists a way in which we can assign a null value directly to var but it requires an object type and a cast transformation. Example:

```java
var p = (String) null;
```

The reason why we **can apply this transformation** is because the type is provided so the compiler and the compiler is able to apply the inference and set the type of var to be String.

#### Does this compile?

On the other hand, when we work with primitive types like int, float, etc.... we cannot assign a null value to them.

```java
var m = 4;
m = null; // (1) DOES NOT COMPILE
```

On (1) it **won\'t compile** because despite the use of var type, we are trying *to assign a null value to a primitive type* (in in the example).

#### Does this compile?

```java
public int addition(var a, var b) { // DOES NOT COMPILE
    return a+b;
}
```

In this example we have ***a*** and ***b*** being method parameters not local variables.

**IMPORTANTE NOTE TO CONSIDER - Exam Trick** **Var is only used for local variable type inference**.

If you see var used in **constructors**, **method parameters** or **instance variables** you will get a **compilation error**.

#### Does this compile?

```java
package class Var {
    public void var() {
        var var = var;
    }
    public void Var() {
        Var var = new Var();
    }
}
```

**Yes** this code compiles because Java being case sensitive does not introduce any conflict using the class name Var in the example. It is **highly recommended not to use** this development style to avoid confusions, ease the readiness of the code and remove ambiguity.

#### Does this compile?

Var is not a **reserved word** in Java (and is used as an identifier) but it is considered a ***reserved type name*** which it means it **cannot be** use to **define a class, enum or interface**.

```java
public class var() {    // (1) DOES NOT COMPILE
    public var(){
    }
}
```

On (1) it **won't compile** due to the **error** on the **class name**, because being var a **reserved type name** it can not be used in class name.

#### Does this code compile?

The use of var in the real world helps developers to **read** the source code in an easy way.

```java
// From the original implementation like....
PileOfPapersToFileInFilingCabinet pileOfPapersToFileInFilingCabinet = new PileOfPapersToFileInFilingCabinet();
// to use var we see a big difference when reading the source code
var pileOfPapersToFileInFilingCabinet = new PileOfPapersToFileInFilingCabinet()
```

## Var general rules
0. Var is widely used in the exam because it allows tricky questions, so **learning** this var general rules **is a must**. It is also recommended to follow this programming style description [link](https://openjdk.java.net/projects/amber/LVTIstyle.html) .
1. A var is **used** as a **local variable** in a **constructor**, **method** or **initializer** block.
2. A var **cannot be used** in **constructor or method params**, **instance or class variables**.
3. A var is **always initialized on the same line** (or statement) where it is **declared**.
4. The **value** of a var **can** **change** but the **type don't**.
5. A var cannot *be **initialized** with a null value without a type*.
6. A var is **not permitted in a multiple-variable declarations**.
7. A var is a ***reserved type name*** but not a **reserved word** meaning it *can be used* as an **identifier** **except for class, enum or interface**.

## Var examples

Several examples could be found here.

