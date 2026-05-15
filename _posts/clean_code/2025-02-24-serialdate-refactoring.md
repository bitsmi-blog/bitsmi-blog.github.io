---
author: Xavier Salvador
title: 16.- SerialDate refactor
page_order: 16
date: 2025-02-24
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

Chapter 16 is a case study on the `org.jfree.date.SerialDate` class from the JCommon library. The author first makes it work correctly, then refactors it in depth, applying a broad catalogue of clean code heuristics.

<!--more-->

## First Step: Make It Work

Running the existing tests against `SerialDate` reveals several failures. Analysis uncovers two problems:

- A boundary error in `getFollowingDayOfWeek`: the adjustment condition was incorrect for certain days of the week.
- The `weekInMonthToString` and `relativeToString` methods returned error strings instead of throwing `IllegalArgumentException`.

After fixing these bugs, all JCommon tests pass.

## Second Step: Do It Right

The class is then walked through from top to bottom, applying improvements.

### Remove the change history [C1]

The lengthy block of version-history comments is a relic of the past. Modern version control systems already store that information.

### Rename `SerialDate` → `DayDate` [N1, N2]

The name "SerialDate" describes a concrete implementation (serial-number representation), but the class is abstract. An abstract name such as `DayDate` is more appropriate for a base class.

### Replace `MonthConstants` with a `Month` enum [J2]

Inheriting from an interface to obtain constants is a bad Java trick. It is replaced with a dedicated enum:

```java
public static enum Month {
    JANUARY(1), FEBRUARY(2), ..., DECEMBER(12);
    public final int index;
    public static Month make(int monthIndex) { ... }
}
```

This eliminates `isValidMonthCode` and all manual month-code validation [G5].

### Convert other constant sets to enums [J3]

- `WeekInMonth`: FIRST, SECOND, THIRD, FOURTH, LAST
- `DateInterval`: CLOSED, CLOSED_LEFT, CLOSED_RIGHT, OPEN (clearer mathematical nomenclature [N3])
- `WeekdayRange`: LAST, NEXT, NEAREST

### Move constants to the correct level [G6]

`EARLIEST_DATE_ORDINAL` and `LATEST_DATE_ORDINAL` are only used by `SpreadsheetDate`, so they are moved there. `MINIMUM_YEAR_SUPPORTED` and `MAXIMUM_YEAR_SUPPORTED` are likewise moved to the subclass.

### Introduce `DayDateFactory` [G7]

A base class should not know about its derived classes. The ABSTRACT FACTORY pattern is introduced:

```java
public abstract class DayDateFactory {
    private static DayDateFactory factory = new SpreadsheetDateFactory();
    public static DayDate makeDate(int ordinal) { return factory._makeDate(ordinal); }
    public static int getMinimumYear()          { return factory._getMinimumYear(); }
    // ...
}
```

### Extract `Day` to its own file [G13]

The `Day` enum is large enough and independent enough from `DayDate` to warrant its own source file.

### Move methods to the right place [G14, Feature Envy]

- `monthCodeToQuarter` → `quarter()` method on the `Month` enum
- `monthCodeToString` / `weekdayCodeToString` → `toString()` and `toShortString()` methods on their respective enums
- `stringToMonthCode` → `Month.parse(String s)`
- `stringToWeekdayCode` → `Day.parse(String s)`

### Additional improvements

- `isLeapYear` is rewritten more expressively using intermediate variables [G16]
- `leapYearCount` is moved to `SpreadsheetDate` where it is actually used [G6]
- `addDays` is converted from a static method to an instance method [G18]
- Redundant Javadocs and stale comments are removed [C2, C3]
- `final` on arguments and local variables is removed (it adds noise without benefit) [G12]

## Key Rules

| Code | Rule applied |
|------|-------------|
| C1–C3 | Comments: remove history, stale, and redundant comments |
| G5 | No duplication: use enums instead of manual validation |
| G6 | Code at the correct level of abstraction |
| G7 | Base classes must not know about their derived classes |
| G12 | Remove clutter (empty constructors, unnecessary `final`) |
| G13 | Avoid artificial coupling |
| G14 | Avoid Feature Envy: move methods to where they belong |
| G16 | Intermediate variables for clarity |
| G18 | Prefer instance methods to static methods |
| J2–J3 | Do not inherit constants; use enums |
| N1–N3 | Descriptive names, correct abstraction level, standard nomenclature |

## Summary

The refactoring of `SerialDate` is a complete example of how to transform a functional but improvable class into a clean one. The "make it work first, then do it right" strategy allows changes to be applied with confidence, backed at every step by the tests.