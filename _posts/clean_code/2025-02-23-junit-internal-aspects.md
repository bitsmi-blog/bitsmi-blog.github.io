---
author: Xavier Salvador
title: 15.- Internal Aspect of JUnit
date: 2025-02-23
page_order: 15
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

Chapter 15 examines the `ComparisonCompactor` class from the JUnit framework in depth, demonstrating how to apply Clean Code rules to an already well-written module using the Boy Scout principle: leave the code better than you found it.

<!--more-->

## What ComparisonCompactor Does

`ComparisonCompactor` produces readable error messages for equality assertion failures. Given `contextLength`, `expected`, and `actual`, it generates strings such as:

```
expected: <...B[X]D...>  but was: <...B[Y]D...>
```

The brackets enclose the differing portion; the ellipses indicate trimmed context. The module had 100% test coverage.

## Original Code (Listing 15-2)

The original was correct but improvable code. Private variables used an `f` prefix (`fContextLength`, `fExpected`, `fActual`, `fPrefix`, `fSuffix`), a negative conditional in `compact()` was not encapsulated, and several names did not clearly convey intent.

## Refactoring Steps

### 1. Remove the `f` prefix from member variables [N6]

Modern environments make this kind of scope encoding unnecessary:

```java
private int contextLength;
private String expected;
private String actual;
private int prefix;
private int suffix;
```

### 2. Encapsulate the negative conditional [G28]

```java
if (shouldNotCompact())
    return Assert.format(message, expected, actual);

private boolean shouldNotCompact() {
    return expected == null || actual == null || areStringsEqual();
}
```

### 3. Invert to a positive conditional [G29]

Negative conditions are harder to read. The method is renamed and its logic inverted:

```java
if (canBeCompacted()) { ... }

private boolean canBeCompacted() {
    return expected != null && actual != null && !areStringsEqual();
}
```

### 4. Rename `compact` → `formatCompactedComparison` [N7]

The name `compact` obscured the side effect of the error check and the return of a formatted message.

### 5. Extract `compactExpectedAndActual()` [G30]

A function should do one thing: the body of the `if` is extracted into a separate method. `compactExpected` and `compactActual` are promoted to member variables to maintain return-value consistency [G11].

### 6. Expose the temporal coupling [G31]

`findCommonSuffix` depended on `findCommonPrefix` having been called first. The fix is to merge them into `findCommonPrefixAndSuffix()`, which calls `findCommonPrefix` internally before computing the suffix.

### 7. Rename `suffixIndex` → `suffixLength` [N1, G33]

`suffixIndex` was actually a 1-based length that introduced artificial `+1` offsets throughout `computeCommonSuffix`. Renaming it and adjusting the arithmetic removes those offsets, and `compactString` can be simplified to:

```java
private String compactString(String source) {
    return computeCommonPrefix()
        + DELTA_START
        + source.substring(prefixLength, source.length() - suffixLength)
        + DELTA_END
        + computeCommonSuffix();
}
```

## Final Version (Listing 15-5)

The result is a class with roughly 10 small methods, each named to describe what it does. The methods `startingEllipsis()`, `startingContext()`, `delta()`, `endingContext()`, and `endingEllipsis()` compose the output in a readable way inside `compact(String s)`.

## Key Rules

| Code | Rule applied |
|------|-------------|
| N1 | Descriptive names |
| N6 | Avoid encodings (`f` prefix) |
| N7 | Names must describe side effects |
| G9 | Remove dead code and redundant statements |
| G11 | Consistency in conventions |
| G28 | Encapsulate conditionals |
| G29 | Avoid negative conditionals |
| G30 | Functions must do one thing |
| G31 | Expose temporal couplings |
| G33 | Eliminate artificial `+1` offsets with proper names |

## Summary

This chapter demonstrates that even well-written code can be improved. Through small steps — each guided by a specific heuristic — `ComparisonCompactor` goes from being *good* to being *clean*: more expressive, more cohesive, and free of hidden couplings.