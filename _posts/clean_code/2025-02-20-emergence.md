---
author: Xavier Salvador
title: 12.- Emergence
page_order: 12
date: 2025-02-20
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

## Getting Clean via Emergent Design

What if by following these rules you gained insights into the structure and design of your code, making it easier to apply principles such as SRP and DIP?

According to Kent Beck, a design is “simple” if it follows these four rules:

- Runs all the tests
- Contains no duplication
- Expresses the intent of the programmer
- Minimises the number of classes and methods

The rules are given in order of importance.

## Simple Design Rule 1: Runs All the Tests

A system that is comprehensively tested and passes all of its tests all of the time is a testable system. Tight coupling makes it difficult to write tests.

## Simple Design Rules 2–4: Refactoring

Having a comprehensive test suite eliminates the fear that cleaning up the code will break it. The final three rules of simple design are: eliminate duplication, ensure expressiveness, and minimise the number of classes and methods.

### No Duplication

Duplication is the primary enemy of a well-designed system.

The TEMPLATE METHOD pattern is a common technique for removing higher-level duplication.

Consider a system with two classes — `VacationPolicy` for US employees and `VacationPolicy` for EU employees — both implementing an `accrueVacation()` method that shares identical steps but differs in one detail: legal minimums vary by jurisdiction. The duplicated structure can be eliminated by defining the common algorithm in a base class and delegating only the variable step to subclasses:

```java
abstract public class VacationPolicy {
    public void accrueVacation() {
        calculateBaseVacationHours();
        alterForLegalMinimums();   // subclass provides jurisdiction-specific logic
        applyToPayroll();
    }

    private void calculateBaseVacationHours() { ... }
    abstract protected void alterForLegalMinimums();
    private void applyToPayroll() { ... }
}

public class USVacationPolicy extends VacationPolicy {
    @Override protected void alterForLegalMinimums() { /* US rules */ }
}

public class EUVacationPolicy extends VacationPolicy {
    @Override protected void alterForLegalMinimums() { /* EU rules */ }
}
```

The skeleton of the algorithm lives in `VacationPolicy`; the subclasses fill in only the parts that differ. No duplication of the common steps remains.

### Expressive

You can express yourself by choosing good names, by keeping your functions and classes small, and by using standard nomenclature. By using standard pattern names — such as COMMAND or VISITOR — in the names of the classes that implement those patterns, you can succinctly describe your design to other developers. Well-written unit tests are also expressive.

### Minimal Classes and Methods

The goal is to keep the overall system small while also keeping individual functions and classes small. Remember, however, that this rule is the lowest priority of the four rules of Simple Design.

## Conclusion

Following the practice of simple design encourages and enables developers to adhere to good principles and patterns that might otherwise take years to learn.
