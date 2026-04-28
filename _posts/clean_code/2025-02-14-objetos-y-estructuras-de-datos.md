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

## Overview

Chapter 6 explores the fundamental dichotomy between objects and data structures. Objects hide their data and expose behaviour; data structures expose their data and have no significant behaviour. Understanding when to use each is a key skill for building flexible, maintainable systems. The chapter also introduces the Law of Demeter and covers Data Transfer Objects and Active Records.

<!--more-->

## Data Abstraction

Exposing implementation details through public fields breaks encapsulation:

```java
public class Point {
  public double x;
  public double y;
}
```

Hiding implementation behind an interface allows the internal representation to change without affecting callers:

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

The methods enforce an access policy -- coordinates can be read independently but must be set as an atomic operation. We do not want to expose the details of our data; rather, we want to express data in abstract terms. *The worst option is to blithely add getters and setters.*

## Data/Object Anti-Symmetry

There is a fundamental dichotomy between objects and data structures:

- **Procedural code** (code using data structures) makes it easy to add new functions without changing the existing data structures. But it makes it hard to add new data structures because all the functions must change.
- **OO code** makes it easy to add new classes without changing existing functions. But it makes it hard to add new functions because all the classes must change.

So, the things that are hard for OO are easy for procedures, and vice versa. Mature programmers know that the idea that *everything is an object* is a myth. Sometimes you really do want simple data structures with procedures operating on them.

## Law of Demeter

A method `f` of a class `C` should only call the methods of:

1. `C` itself
2. An object created by `f`
3. An object passed as an argument to `f`
4. An object held in an instance variable of `C`

The method should *not* invoke methods on objects returned by any of the allowed functions. In other words: **talk to friends, not to strangers.**

### Train Wrecks

Chains like `ctxt.getOptions().getScratchDir().getAbsolutePath()` are called train wrecks and should be avoided. Split them:

```java
Options opts = ctxt.getOptions();
File scratchDir = opts.getScratchDir();
final String outputDir = scratchDir.getAbsolutePath();
```

Whether this violates Demeter depends on whether the objects in the chain are data structures or objects. If they are pure data structures, the rule does not apply.

### Hybrids

Hybrid structures that are half object and half data structure -- with significant functions *and* public variables or exposed accessors -- get the worst of both worlds. Avoid creating them.

### Hiding Structure

When you need something like a temporary file path, do not ask the object to expose its internals -- tell it to do the work:

```java
// Bad: navigating through internals
String outFile = outputDir + "/" + className.replace('.', '/') + ".class";
FileOutputStream fout = new FileOutputStream(outFile);

// Good: delegate to the object
BufferedOutputStream bos = ctxt.createScratchFileStream(classFileName);
```

Objects should expose meaningful behaviours, not their guts.

## Data Transfer Objects

The quintessential form of a data structure is a class with public variables and no functions -- a **Data Transfer Object (DTO)**. DTOs are useful when communicating with databases or parsing messages from sockets. They often represent the first stage in a series of translations that convert raw database data into application objects.

**Beans** are DTOs with private variables and getter/setter pairs. The quasi-encapsulation of beans satisfies OO purists but usually provides no other benefit.

## Active Record

**Active Records** are DTOs with navigational methods such as `save` and `find`. They are typically direct translations of database tables.

Do not mix business logic into Active Records. Treat them as data structures and create separate objects to hold the business rules.

---

## Key Rules / Quick Reference

- Objects hide data and expose behaviour; data structures expose data and have no significant behaviour.
- Choose objects when you anticipate adding new types; choose data structures when you anticipate adding new functions.
- Law of Demeter: talk to friends, not to strangers -- call methods only on immediate collaborators.
- Avoid train wrecks: split long chains of calls into separate variables.
- Avoid hybrids: don't mix significant behaviour with public data.
- Tell objects to do work; don't ask them to expose internals.
- DTOs and Active Records are data structures -- keep business logic out of them.

## Summary

There is no universally correct choice between objects and data structures. Good software developers understand the trade-offs and choose the approach that best fits the problem. Use objects to encapsulate types that will vary; use data structures to encapsulate algorithms that will vary. The two are complementary tools, not competing philosophies.