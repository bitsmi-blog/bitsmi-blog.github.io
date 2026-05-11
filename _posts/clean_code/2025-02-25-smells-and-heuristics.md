---
author: Xavier Salvador
title: 17.- Smells and Heuristics
page_order: 17
date: 2025-02-25
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

Chapter 17 is the book's definitive catalogue of smells and heuristics. It collects all the specific reasons that guided the refactorings in the preceding chapters, grouped into seven categories: Comments, Environment, Functions, General, Java, Names, and Tests.

<!--more-->

## Comments

| Code | Name | Description |
|------|------|-------------|
| C1 | Inappropriate information | Metadata such as change history, authors, or ticket numbers should not be in comments; they belong in the version control system. |
| C2 | Obsolete comment | Comments that no longer match the code are worse than no comments — they mislead. They must be updated or removed. |
| C3 | Redundant comment | If the code is already clear, a comment that restates it merely adds noise: `i++; // increment i`. |
| C4 | Poorly written comment | A comment worth writing deserves to be written well: grammatically correct, brief, and precise. |
| C5 | Commented-out code | Commented-out code rots. Nobody removes it because they think someone else needs it. Delete it — version control remembers it. |

## Environment

| Code | Name | Description |
|------|------|-------------|
| E1 | Build requires more than one step | Building the project should be a single, trivial command. |
| E2 | Tests require more than one step | Running all the tests should be a single command. |

## Functions

| Code | Name | Description |
|------|------|-------------|
| F1 | Too many arguments | Zero is best; one, two, or three are acceptable; more than three is highly questionable. |
| F2 | Output arguments | Arguments should be inputs, not outputs. If state must change, change the state of the owning object. |
| F3 | Flag arguments | A `boolean` argument declares that the function does more than one thing. |
| F4 | Dead function | Methods that nobody calls should be deleted; version control remembers them. |

## General

### G1–G10: Structure and Abstraction

- **G1 Multiple languages in one file**: Ideally, one file uses one language. Java + HTML + JavaScript in the same file makes it harder to read.
- **G2 Obvious behaviour not implemented**: Following the Principle of Least Surprise, a function should implement what a programmer would reasonably expect.
- **G3 Incorrect behaviour at boundaries**: Do not rely on intuition — write tests for every boundary condition.
- **G4 Overriding safeties**: Disabling tests or ignoring compiler warnings is playing with fire.
- **G5 Duplication**: Every instance of duplication represents a missed abstraction. The most subtle form is the `switch/case` that appears repeatedly — replace it with polymorphism.
- **G6 Code at wrong level of abstraction**: Constants, variables, or functions that belong to a concrete implementation must not appear in the base class.
- **G7 Base class depends on derived classes**: In general, base classes should not know about their subclasses.
- **G8 Too much information**: Well-defined interfaces are small. Few methods, few instance variables, low coupling.
- **G9 Dead code**: Code that is never executed — unreachable branches, empty `catch` blocks, uncalled functions — must be removed.
- **G10 Vertical separation**: Variables and functions should be defined close to where they are used.

### G11–G20: Conventions and Clarity

- **G11 Inconsistency**: If you use `response` for `HttpServletResponse` in one function, use it consistently everywhere.
- **G12 Clutter**: Empty constructors, unused variables, uninformative comments — all of this should be removed.
- **G13 Artificial coupling**: Do not place general-purpose enums or constants inside specific classes.
- **G14 Feature Envy**: A method that makes heavy use of another object's data should live in that other object.
- **G15 Selector arguments**: A `false` at the end of a call is a bad smell. Split the function into two instead.
- **G16 Obscured intent**: Dense expressions, Hungarian notation, and magic numbers hide intent. Use intermediate variables with expressive names.
- **G17 Misplaced responsibility**: Code should live where the reader would expect to find it.
- **G18 Inappropriate static**: Prefer instance methods to static methods when polymorphic behaviour is possible.
- **G19 Use explanatory variables**: Decomposing calculations into intermediate variables with meaningful names dramatically improves readability.
- **G20 Function names should say what they do**: If you have to read the implementation to understand the name, the name is poorly chosen.

### G21–G30: Algorithms and Design

- **G21 Understand the algorithm**: It is not enough for the tests to pass. You must understand how the solution works.
- **G22 Make logical dependencies physical**: Do not make assumptions about another module — ask it explicitly for what you need.
- **G23 Polymorphism over if/else or switch/case**: The ONE SWITCH rule: for a given type selection, at most one `switch` statement, which creates polymorphic objects.
- **G24 Follow standard conventions**: The team chooses a standard and everyone follows it without exceptions.
- **G25 Replace magic numbers with named constants**: `SECONDS_PER_DAY` instead of `86400`.
- **G26 Be precise**: Design decisions must be made precisely — check for `null`, use integers for currency, add locks when there is concurrency.
- **G27 Structure over convention**: An abstract class with abstract methods forces their implementation; a naming convention does not.
- **G28 Encapsulate conditionals**: `if (shouldBeDeleted(timer))` is clearer than `if (timer.hasExpired() && !timer.isRecurrent())`.
- **G29 Avoid negative conditionals**: `if (buffer.shouldCompact())` is easier to read than `if (!buffer.shouldNotCompact())`.
- **G30 Functions should do one thing**: A loop with a condition and payment logic should be split into three separate methods.

### G31–G36: Couplings and Configuration

- **G31 Hidden temporal couplings**: If B must be called before A, make that dependency explicit in the signature — `findCommonPrefixAndSuffix()` calls `findCommonPrefix()` internally.
- **G32 Do not be arbitrary**: If the code looks arbitrary, others will change it. Give the structure a clear reason to be the way it is.
- **G33 Encapsulate boundary conditions**: Encapsulate boundary calculations — do not scatter them throughout the code.
- **G34 Functions should descend only one level of abstraction**: Mixing high- and low-level logic in the same function makes it harder to read.
- **G35 Keep configurable data at high levels**: Configurable constants should live at the top of the hierarchy and be passed downward.
- **G36 Avoid transitive navigation**: `a.getB().getC().doSomething()` creates rigid architectures. The Law of Demeter: a module should only know its immediate collaborators.

## Java

| Code | Name | Description |
|------|------|-------------|
| J1 | Avoid long import lists | Use `import package.*` instead of importing class by class when two or more classes from the same package are used. |
| J2 | Do not inherit constants | Inheriting from an interface to obtain constants is a dirty trick. Use `static import`. |
| J3 | Constants vs enums | Now that Java has enums (Java 5), use them — they are more expressive than `public static final int`. |

## Names

| Code | Name | Description |
|------|------|-------------|
| N1 | Descriptive names | Names account for 90% of what makes code readable. Take the necessary time to choose them well. |
| N2 | Correct abstraction level | Do not use `phoneNumber` in a `Modem` interface; use `connectionLocator`. |
| N3 | Standard nomenclature | If you use the DECORATOR pattern, use "Decorator" in the name. |
| N4 | Unambiguous names | A `doRename` that calls `renamePage` says nothing about the difference between the two. |
| N5 | Long names for long scopes | `i` is perfect in a 5-line loop; for wide scopes, use full names. |
| N6 | Avoid encodings | Prefixes such as `m_`, `f`, and `I_` are noise in modern environments. |
| N7 | Names must describe side effects | A `getOos()` that creates the object if it does not exist should be called `createOrReturnOos`. |

## Tests

| Code | Name | Description |
|------|------|-------------|
| T1 | Insufficient tests | A test suite should test everything that could fail. |
| T2 | Use a coverage tool | Coverage tools reveal which branches have not been tested. |
| T3 | Do not skip trivial tests | They are easy to write and their documentary value outweighs the cost. |
| T4 | An ignored test is a question | `@Ignore` or a commented-out test expresses ambiguity in the requirements. |
| T5 | Test boundary conditions | Boundaries are where algorithms most often fail. |
| T6 | Test exhaustively near bugs | Bugs cluster. If you find one, look for more in the same function. |
| T7 | Failure patterns are revealing | Ordering tests and observing red/green patterns can point to the root cause. |
| T8 | Coverage patterns are revealing | Code not covered by passing tests gives clues about failing ones. |
| T9 | Tests should be fast | A slow test is a test that will not be run when time pressure is high. |

## Summary

The catalogue in Chapter 17 does not aim to be exhaustive — it is a system of values. Clean code is not written by following a checklist of rules, but by cultivating the professional judgement to recognise smells and know how to eliminate them.