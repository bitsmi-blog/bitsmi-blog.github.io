---
author: Xavier Salvador
title: 7.- Handling errors
page_order: 07
date: 2025-02-15
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

## Overview

Chapter 7, written by Michael Feathers, addresses error handling as a first-class concern of clean code. Many codebases are dominated by error-handling logic scattered throughout the business code, making the real algorithm nearly invisible. The goal is to separate error handling from the main logic so each can be understood independently.

<!--more-->

## Use Exceptions Rather Than Return Codes

Before exceptions existed, error reporting relied on flags or return codes that callers had to check immediately after each call. This clutters the caller and makes it easy to forget the check entirely.

Using exceptions separates the happy path from the error path:

```java
// Before: error code clutters the caller
public void sendShutDown() {
    DeviceHandle handle = getHandle(DEV1);
    if (handle != DeviceHandle.INVALID) {
        retrieveDeviceRecord(handle);
        if (record.getStatus() != DEVICE_SUSPENDED) {
            pauseDevice(handle);
            clearDeviceWorkQueue(handle);
            closeDevice(handle);
        } else {
            logger.log("Device suspended. Unable to shut down");
        }
    } else {
        logger.log("Invalid handle for: " + DEV1.toString());
    }
}

// After: algorithm and error handling are separated
public void sendShutDown() {
    try {
        tryToShutDown();
    } catch (DeviceShutDownError e) {
        logger.log(e);
    }
}
```

## Write Your Try-Catch-Finally Statement First

`try` blocks are like transactions: the `catch` must leave the program in a consistent state no matter what happens inside the `try`. Start by writing the `try-catch-finally` structure, then use TDD to build up the logic inside it. This ensures the transaction scope is established first and maintained throughout.

```java
public List<RecordedGrip> retrieveSection(String sectionName) {
    try {
        FileInputStream stream = new FileInputStream(sectionName);
        stream.close();
    } catch (FileNotFoundException e) {
        throw new StorageException("retrieval error", e);
    }
    return new ArrayList<RecordedGrip>();
}
```

## Use Unchecked Exceptions

Checked exceptions seem appealing -- they force callers to handle errors -- but they violate the Open/Closed Principle. If a low-level method throws a checked exception, every method in the call chain above it must either catch it or declare it, propagating a cascading signature change all the way up. This breaks encapsulation.

For general application development the dependency costs of checked exceptions outweigh their benefits. C#, Python, and Ruby have no checked exceptions yet support robust software. Prefer unchecked (runtime) exceptions in application code.

## Provide Context with Exceptions

A stack trace alone does not tell you the *intent* of the failed operation. Create informative error messages and pass them with your exceptions. Mention what operation was being attempted and what type of failure occurred.

## Define Exception Classes in Terms of a Caller's Needs

When an external API can throw many different exception types for essentially the same kind of failure, wrap it in your own class that normalises the exceptions:

```java
// Bad: many catch clauses for one logical failure
try {
    port.open();
} catch (DeviceResponseException e) {
    reportPortError(e); logger.log("Device response exception", e);
} catch (ATM1212UnlockedException e) {
    reportPortError(e); logger.log("Unlock exception", e);
} catch (GMXError e) {
    reportPortError(e); logger.log("Device response exception");
}

// Good: wrap the API and define a single exception type
LocalPort port = new LocalPort(12);
try {
    port.open();
} catch (PortDeviceFailure e) {
    reportError(e);
    logger.log(e.getMessage(), e);
}
```

Wrapping third-party APIs is a best practice. It minimises dependencies on the vendor, makes mocking easier in tests, and lets you define a clean API that suits your needs.

## Define the Normal Flow (Special Case Pattern)

Sometimes throwing an exception for a foreseeable special case clutters the calling code unnecessarily. Instead, encapsulate the special case inside an object so the caller never has to deal with exceptional behaviour:

```java
// Before: exception clutters the normal flow
try {
    MealExpenses expenses = expenseReportDAO.getMeals(employee.getID());
    m_total += expenses.getTotal();
} catch (MealExpensesNotFound e) {
    m_total += getMealPerDiem();
}

// After: DAO returns a PerDiemMealExpenses object when no meals exist
MealExpenses expenses = expenseReportDAO.getMeals(employee.getID());
m_total += expenses.getTotal();
```

This is called the **Special Case Pattern** (Fowler). The client code is not aware of the special case -- it is handled inside the special-case object.

## Don't Return Null

Returning `null` forces the caller to check for it at every use. One missed check can crash the application with a `NullPointerException`.

- If tempted to return `null`, consider returning a **Special Case object** (e.g., an empty list) or throwing an exception instead.
- Use `Collections.emptyList()` rather than returning `null` from a method that returns a list.

```java
// Bad
public List<Employee> getEmployees() {
    if (/* no employees */) return null;
}

// Good
public List<Employee> getEmployees() {
    if (/* no employees */) return Collections.emptyList();
}
```

## Don't Pass Null

Passing `null` into methods is even worse than returning it. Unless you are working with an API that explicitly expects `null`, forbid passing `null` by default. In most languages there is no good way to deal with a `null` that a caller passes accidentally; treating it as an error by default leads to far fewer careless mistakes.

---

## Key Rules / Quick Reference

- Prefer exceptions over return codes -- they separate algorithm from error handling.
- Write `try-catch-finally` first; build the logic inside it with TDD.
- Prefer unchecked exceptions; checked exceptions break encapsulation across deep call chains.
- Include context in exception messages: what was attempted and what failed.
- Define exception classes around caller needs; wrap third-party APIs to normalise their exceptions.
- Use the Special Case Pattern to remove exception handling from normal flow.
- Never return `null` -- return empty collections or Special Case objects instead.
- Never pass `null` -- forbid it by convention.

## Summary

Clean code is readable, but it must also be robust. These are not conflicting goals. Write robust clean code by treating error handling as a **separate concern** -- something that can be reasoned about independently of the main logic. When error handling is cleanly separated, both the algorithm and the error policy become easier to understand and maintain.