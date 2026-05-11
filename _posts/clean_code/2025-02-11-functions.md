---
author: Xavier Salvador
title: 3.- Functions
page_order: 03
date: 2025-02-11
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

## Overview

Functions are the first line of organisation in any program. This chapter describes what makes a function clean: how small it should be, what it should do, how many arguments it should take, and how it should handle errors.

<!--more-->

## Small

- Functions should be small — at most 20 lines, and usually much shorter.
- They are the main unit of organisation in a program.

## Blocks and Indenting

`if`, `else`, and `while` blocks should be one line long — ideally a function call. This keeps the function short and adds documentary value through the name of the called function. The indent level of a function should not be greater than one or two levels.

## Do One Thing

Functions should:
- Do **one thing**.
- Do it well.
- Do it only.

**How to check**: if you can extract another function from it without it being a mere restatement of the implementation, the original function is doing more than one thing.

## Sections Within Functions

A function that does one thing cannot be reasonably divided into sections. Sections are a sign that the function is doing more than one thing.

## One Level of Abstraction per Function

All statements in a function should be at the same level of abstraction. Mixing high-level concepts with low-level details in the same function is always confusing, and tends to attract more details over time.

## Reading Code from Top to Bottom: The Stepdown Rule

Code should read like a top-down narrative. Every function should be followed by those at the next level of abstraction so the program can be read descending one level at a time. This is the **Step-down Rule**.

Making code read like a set of TO paragraphs is an effective technique for keeping abstraction levels consistent.

## Switch Statements

By their nature, switch statements always do N things. They cannot be made to do only one thing. The rule is:

- Bury switch statements in the basement of an **Abstract Factory** — never let anything else see them.
- Use the switch to create polymorphic objects; dispatch behaviour through interfaces or abstract classes.
- **One switch per type selection** — no repeated switch on the same type elsewhere in the system.

```java
// Bad: switch exposed, violates SRP and OCP
public Money calculatePay(Employee e) throws InvalidEmployeeType {
    switch (e.type) {
        case COMMISSIONED: return calculateCommissionedPay(e);
        case HOURLY:       return calculateHourlyPay(e);
        case SALARIED:     return calculateSalariedPay(e);
        default:           throw new InvalidEmployeeType(e.type);
    }
}

// Good: switch hidden in factory; behaviour dispatched polymorphically
public abstract class Employee {
    public abstract boolean isPayday();
    public abstract Money calculatePay();
    public abstract void deliverPay(Money pay);
}

public class EmployeeFactoryImpl implements EmployeeFactory {
    public Employee makeEmployee(EmployeeRecord r) throws InvalidEmployeeType {
        switch (r.type) {
            case COMMISSIONED: return new CommissionedEmployee(r);
            case HOURLY:       return new HourlyEmployee(r);
            case SALARIED:     return new SalariedEmployee(r);
            default:           throw new InvalidEmployeeType(r.type);
        }
    }
}
```

## Use Descriptive Names

- Do not be afraid to make a name long — a long descriptive name is better than a short enigmatic one.
- Spend time choosing a name; try several alternatives.
- Use the same phrases, nouns, and verbs consistently across function names in a module.

## Function Arguments

Preferred number of arguments (in order):
1. **Niladic** — zero (ideal)
2. **Monadic** — one (good)
3. **Dyadic** — two (acceptable)
4. **Triadic** — three (requires justification)
5. **Polyadic** — four or more (avoid)

Arguments make functions harder to read and harder to test (more combinations to cover).

### Common Monadic Forms

Two valid reasons to pass a single argument:
1. Asking a question about the argument: `boolean isFileValid(File f)`
2. Transforming the argument and returning the result: `InputStream openFile(String path)`

### Flag Arguments

Passing a boolean flag to a function is a bad practice. It proclaims that the function does two things — one for `true`, one for `false`. Split the function instead.

### Dyadic Functions

Two-argument functions are harder to read. The first argument tends to be absorbed and the second ignored. When possible, convert a dyadic function to a monadic one. Some cases legitimately require two arguments: `new Point(x, y)`.

### Triads

Harder than dyadic. Most triads can be avoided by wrapping arguments into an object.

### Argument Objects

When a function needs more than two or three arguments, some of those arguments should be wrapped in a class:

```java
// Polyadic — hard to read
Circle makeCircle(double x, double y, double radius);

// Dyadic — cleaner
Circle makeCircle(Point center, double radius);
```

### Argument Lists

Variable argument lists (`Object... args`) are treated as a single argument of type `List` for arity purposes.

## Have No Side Effects

A function that promises to do one thing but secretly does something else (modifies a global, changes a parameter, calls an unrelated method) is a lie. Side effects create temporal couplings and hidden dependencies.

## Output Arguments

Output arguments (where the function modifies a passed-in object instead of returning a result) are confusing. In OO code, `this` is the natural output argument — if state must change, change the state of the owning object.

## Command Query Separation

**Functions should either do something or answer something — not both.**

Combining a command and a query in one function creates ambiguity. Separate commands from queries.

## Prefer Exceptions to Returning Error Codes

Using exceptions instead of error codes separates the happy path from error handling:

```java
try {
    deletePage(page);
    registry.deleteReference(page.name);
    configKeys.deleteKey(page.name.makeKey());
} catch (Exception e) {
    logger.log(e.getMessage());
}
```

## Extract Try/Catch Blocks

The body of `try` and `catch` blocks should be extracted into their own functions. This keeps error handling and normal processing separate and readable:

```java
public void delete(Page page) {
    try {
        deletePageAndAllReferences(page);
    } catch (Exception e) {
        logError(e);
    }
}

private void deletePageAndAllReferences(Page page) throws Exception {
    deletePage(page);
    registry.deleteReference(page.name);
    configKeys.deleteKey(page.name.makeKey());
}

private void logError(Exception e) {
    logger.log(e.getMessage());
}
```

## Error Handling Is One Thing

A function that handles errors should do nothing else. If the keyword `try` appears in a function, it should be the first word — and there should be nothing after the `catch`/`finally` blocks.

## The Error.java Dependency Magnet

Using a shared `Error` enum forces every class that uses errors to import and depend on it. When the enum changes, all dependent classes must be recompiled and redeployed.

```java
public enum Error {
    OK, INVALID, NO_SUCH, LOCKED, OUT_OF_RESOURCES, WAITING_FOR_EVENT;
}
```

When you use exceptions rather than error codes, new exceptions are derivatives of the exception class and can be added without forcing any recompilation or redeployment.

## Don't Repeat Yourself (DRY)

Duplication is the root of all evil in software. When the same algorithm appears in multiple places, any change to it requires changes in every copy — and it is easy to miss one. Identify duplication, extract it into a function, and call that function from all the places that need it.

## Quick Reference

| Principle | Guidance |
|-----------|----------|
| Small | Max ~20 lines; usually much shorter |
| Do one thing | Can you extract another function? Then it does too much |
| One abstraction level | All statements at the same level |
| Stepdown rule | Read top to bottom, descending one abstraction level at a time |
| Switch | Bury in factory; use polymorphism everywhere else |
| Arguments | 0-1 preferred; 2 acceptable; 3 requires justification; 4+ avoid |
| No flag args | Split the function instead |
| No side effects | Functions should do exactly what they say |
| CQS | Either do or answer — never both |
| Exceptions > error codes | Exceptions decouple error handling from happy path |
| Extract try/catch | Error handling and logic in separate functions |
| DRY | No duplicated algorithms; extract and reuse |