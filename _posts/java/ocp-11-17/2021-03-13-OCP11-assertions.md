---
author: Antonio Archilla
title: OCP11 - Assertions
date: 2021-03-13
categories: [ "java", "ocp-11-17" ]
tags: [ "ocp-11", "ocp-17" ]
layout: post
excerpt_separator: <!--more-->
---

**Assertion** is a mechanism that allows you to check assumptions in the code that help you to confirm the proper functioning of the code and that it is free of errors. The following post shows its basic operations and the situations in which its use is appropriate and in which it is not.

An assertion expression is identified by the `assert` keyword. Its syntax is as follows:
```
assert <expression> [: <message>]
```

Where:

- **expression**: Boolean expression that indicates whether the assumption is satisfied or not. In case it is not fulfilled, an `AssertionError` type error will be thrown.
- **message**: Optional. If a message is specified in the expression, it will be attached to the produced `AssertionError`. 

<!--more-->

The use of assertions in code is not always appropriate. Some of the most common cases in which this type of construction can be used are listed below: 

- **Precondition checks**: Conditions that must be met when a method is invoked (only in case of NON-public methods). 
- **Post-condition checks**: Conditions that must be met when a method is successfully executed. 
- **Lock-status checks**: To be used in methods designed for multithreaded environments, it is possible to check the precondition of whether the current thread has obtained the **lock** on a given object. As in the case of the preconditions, this must be done only in the non-public API of the class, the code being the following: 
```java
assert Thread.holdsLock(this);
```
- **Invariant flow checks**: An assertion can be added in places where it is expected to be impossible to access. 
For example:
```java 
private void doStuff(int input){
 // Se prevé que el valor de entrada sea siempre par
 if(input%2==0){
  …
  return;
 }
 assert false;
}
```

**CONSIDERATION FOR THE EXAM**: It must be taken into account that if the `assert` statement is in an inaccessible code block, the compiler will generate a compilation error, so you must be careful when using this pattern. 

The following cases show situations where assertions should **NOT** be used: 

- **Checking for preconditions in public methods**: Since these checks constitute a contract between the public API of the class with an external component, their validity must always be checked and this is not achieved through assertions, since they can be disabled (by default). For example, to indicate that an input parameter is invalid, the unchecked exception `IllegalArgumentException` can be used.

**Assertions are not active by default**. It is necessary to execute the program indicating the *-ea* (enable assertions) options and, optionally, the classes to which it applies: 

- **No arguments**: Enables assertions to all classes, except for system ones, e.g. `java -ea MainProgram`.
- **package[...]**: Enables assertions to the classes of the indicated package and all its subpackages (specifying the optional ellipsis `...`), e.g. `java -ea: com.example... MainProgram`.
- **Class name**: Enables assertions only in the specified class.

It is possible to set *filters* on classes or packages in which you do not want to enable assertions by combining the previous option with `–da` (**disable assertions**), accepting the same parameterization. If, for example, you want to enable all the assertions of the package **com.example**, including subpackages, except for the class **com.example.SimpleClass**, the statement would be like the following:

```java 
java -ea:com.ejemplo -da:com.example.SimpleClass MainProgram
```

In case of specifying a package or class as an argument, assertions about system classes will be enabled or disabled in case you refer to them. Assertions for system classes can be explicitly enabled or disabled using the `-esa` (**enable system assertions**) and `–dsa` (**disable system assertions**) options. By default it is desirable to keep them disabled. 

These options can be specified multiple times, being evaluated in the order in which they are specified.

## References

- [Assert statement in Java11 Language Specification](https://docs.oracle.com/javase/specs/jls/se11/html/jls-14.html#jls-14.10)
- [Programming with assertions Java8 Technote](https://docs.oracle.com/javase/8/docs/technotes/guides/language/assert.html)
