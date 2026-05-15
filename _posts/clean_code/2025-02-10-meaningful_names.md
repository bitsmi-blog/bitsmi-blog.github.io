---
author: Xavier Salvador
title: 2.- Meaningful names
page_order: 02
date: 2025-02-10
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

## Overview

Names are everywhere in software — variables, functions, classes, packages, files. Because we name so many things, we should name them well. This chapter provides a set of simple, actionable rules.

<!--more-->

## Use Intention-Revealing Names

The name of a variable, function, or class should answer: why it exists, what it does, and how it is used. If a name requires a comment to explain it, the name does not reveal its intent.

```java
// Bad
int d; // elapsed time in days

// Good
int elapsedTimeInDays
int daysSinceCreation
```

The **implicitness** of the code — the degree to which context is not explicit in the code itself — must be minimised.

## Avoid Disinformation

- Avoid abbreviations, acronyms, and names that mislead (e.g., using `accountList` for something that is not a `List`).
- Use plain nouns: `accounts` rather than `accountGroup` or `bunchOfAccounts`.
- Spelling similar concepts similarly is information. Inconsistent spelling is disinformation.
- Never use lowercase `l` or uppercase `O` as variable names — they look like `1` and `0`.

## Make Meaningful Distinctions

- Do not create names solely to satisfy the compiler (e.g., `klass` because `class` is taken).
- Number-series naming (`a1, a2, aN`) is noninformative — it provides no clue to the author's intention.
- Noise words (`Info`, `Data`, `The`) make names different without making them mean anything different.

## Use Pronounceable Names

If you cannot pronounce a name, you cannot discuss it without sounding awkward. Programming is a social activity.

## Use Searchable Names

- Avoid single-letter names and numeric constants in code — they are impossible to search for reliably.
- Single-letter names are acceptable only as loop counters in very short, local scopes.
- The length of a name should correspond to the size of its scope.

## Avoid Encodings

Type or scope information encoded into names (Hungarian Notation, `m_` prefixes) adds deciphering burden without benefit in modern typed languages and IDEs.

### Hungarian Notation

Java programmers do not need type encoding. IDEs detect type errors before compilation. HN makes names harder to read and easier to mistype.

### Member Prefixes

Do not prefix member variables with `m_`. Use an IDE that highlights or colorises members instead.

### Interfaces and Implementations

Do not prefix interfaces with `I`. Prefer encoding the implementation: `ShapeFactoryImpl` or `CShapeFactory`.

## Avoid Mental Mapping

Readers should not have to mentally translate a name into another concept they already know. Single-letter names (except `i`, `j`, `k` in small loop scopes) force this translation. Clarity is king.

## Class Names

Classes and objects should have **noun or noun phrase** names: `Customer`, `WikiPage`, `Account`, `AddressParser`.

Avoid: `Manager`, `Processor`, `Data`, `Info` — these are vague and do not convey meaning. A class name should never be a verb.

## Method Names

Methods should have **verb or verb phrase** names. Accessors, mutators, and predicates should be prefixed with `get`, `set`, and `is` per the JavaBean standard.

## Don't Be Cute

Do not use colloquialisms, slang, or culture-dependent jokes as names. Say what you mean. Mean what you say.

## Pick One Word per Concept

Pick one word for an abstract concept and use it consistently throughout the codebase. `fetch`, `retrieve`, and `get` used interchangeably for the same kind of operation is confusing.

## Don't Pun

Avoid using the same word for two different purposes. Using the same term for two different ideas is a pun — it trades clarity for a false consistency.

## Use Solution Domain Names

Readers of your code are programmers. Use technical names freely: `Visitor`, `Factory`, `JobQueue` are understood by any programmer and do not need explanation.

## Use Problem Domain Names

When there is no good solution domain name for a concept, use the name from the problem domain. At least a programmer can look it up and ask a domain expert what it means.

## Add Meaningful Context

Variables rarely have meaning on their own. Group related variables into a well-named class to give them context.

```java
// Variables in isolation are ambiguous
String firstName, lastName, street, city, state;

// Grouped in a class, their meaning is clear
public class Address {
    private String firstName;
    private String lastName;
    private String street;
    private String city;
    private String state;
    private String zipcode;
}
```

## Don't Add Gratuitous Context

Shorter names are generally better than longer ones, as long as they are clear. Do not add a prefix to every class in an application. Use `Address` for the class; use `accountAddress` or `customerAddress` for instances.

## Quick Reference

| Rule | Guidance |
|------|----------|
| Intention-revealing | Name tells why, what, and how |
| No disinformation | No misleading abbreviations or type-like names |
| Meaningful distinctions | No noise words, no number series |
| Pronounceable | If you can't say it, you can't discuss it |
| Searchable | No single letters or magic numbers in wide scope |
| No encodings | No HN, no `m_`, no `I` prefix on interfaces |
| No mental mapping | Explicit over clever |
| Class names = nouns | No verbs, no vague suffixes like `Manager` |
| Method names = verbs | `get`/`set`/`is` for accessors/mutators/predicates |
| One word per concept | Consistent vocabulary across the codebase |
| Solution + problem domain | Technical names first; domain names when no technical name exists |

## Conclusion

Choosing good names requires good descriptive skills and a shared cultural background. Rename freely when you find a better name — modern IDEs make this safe and cheap.