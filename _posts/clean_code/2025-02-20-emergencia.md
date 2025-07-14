---
author: Xavier Salvador
title: 12.- Emergencies
page_order: 12
date: 2025-02-20
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

Getting Clean via Emergent Design
What if by following these rules you gained insights into the structure and design of your code, making it easier to apply principles such as SRP and DIP?

According to Kent, a design is “simple” if it follows these rules:

• Runs all the tests

• Contains no duplication

• Expresses the intent of the programmer

• Minimizes the number of classes and methods

The rules are given in order of importance.

Simple Design Rule 1: Runs All the Tests

A system that is comprehensively tested and passes all of its tests all of the time is a testable system.

Tight coupling makes it difficult to write tests

Simple Design Rules 2–4: Refactoring

The fact that we have these tests eliminates the fear that cleaning up the code will break it!

final three rules of simple design: Eliminate duplication, ensure expressiveness, and minimize the number of classes and methods.

No Duplication
Duplication is the primary enemy of a well-designed system



The TEMPLATE METHOD2 pattern is a common technique for removing higher-level duplication

Add EXTRA info about template method. xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx




Expressive
You can express yourself by choosing good names
You can also express yourself by keeping your functions and classes small
You can also express yourself by using standard nomenclature
By using the standard pattern names, such as COMMAND or VISITOR, in the names of the classes that implement those patterns, you can succinctly describe your design to other developers
Well-written unit tests are also expressive



Minimal Classes and Methods
Our goal is to keep our overall system small while we are also keeping our functions and classes small.
Remember, however, that this rule is the lowest priority of the four rules of Simple Design.

Conclusion
Following the practice of simple design can and does encourage and enable developers to adhere to good principles and patterns that otherwise take years to learn
