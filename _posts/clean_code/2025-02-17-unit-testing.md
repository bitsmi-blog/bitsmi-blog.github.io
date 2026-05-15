---
author: Xavier Salvador
title: 9.- Unit Testing
page_order: 09
date: 2025-02-17
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

## Overview

Chapter 9 argues that unit tests are not a second-class citizen of the codebase. Tests must be written with the same care, design, and discipline as production code. Dirty tests are as damaging as no tests: they accumulate technical debt, resist change, and ultimately get discarded -- taking with them all the safety they once provided.

<!--more-->

## The Three Laws of TDD

Test-Driven Development is governed by three laws that lock developer and test into a tight cycle of roughly thirty seconds:

1. You may not write production code until you have written a failing unit test.
2. You may not write more of a unit test than is sufficient to fail (not compiling counts as failing).
3. You may not write more production code than is sufficient to pass the currently failing test.

Working this way generates a comprehensive test suite that covers virtually all production code.

## Keeping Tests Clean

Some teams decide that test code does not need to meet the same quality standards as production code. This is a false economy. As production code evolves, tests must change with it. Dirty tests are hard to change; the harder they are to change, the less they are run; the less they are run, the faster the production code rots. The moral: **test code is just as important as production code**.

## Tests Enable the -ilities

It is unit tests that keep code flexible, maintainable, and reusable. With a comprehensive test suite you can refactor or restructure the system without fear. Without tests, every change is a possible bug. Tests are what make continuous improvement possible.

## Clean Tests

What makes a test clean? Readability. Clarity, simplicity, and density of expression. Tests should say a lot with as few expressions as possible.

Compare a verbose test that is loaded with irrelevant setup detail:

```java
public void testGetPageHierarchyAsXml() throws Exception {
    crawler.addPage(root, PathParser.parse("PageOne"));
    crawler.addPage(root, PathParser.parse("PageOne.ChildOne"));
    crawler.addPage(root, PathParser.parse("PageTwo"));
    request.setResource("root");
    request.addInput("type", "pages");
    Responder responder = new SerializedPageResponder();
    SimpleResponse response = (SimpleResponse) responder.makeResponse(
        new FitNesseContext(root), request);
    String xml = response.getContent();
    assertEquals("text/xml", response.getContentType());
    assertSubString("<name>PageOne</name>", xml);
    assertSubString("<name>PageTwo</name>", xml);
    assertSubString("<name>ChildOne</name>", xml);
}
```

With a version refactored into helper methods:

```java
public void testGetPageHierarchyAsXml() throws Exception {
    makePages("PageOne", "PageOne.ChildOne", "PageTwo");
    submitRequest("root", "type:pages");
    assertResponseIsXML();
    assertResponseContains(
        "<name>PageOne</name>", "<name>PageTwo</name>", "<name>ChildOne</name>"
    );
}
```

The second version makes intent immediately clear. The helper methods form a **domain-specific testing language** that hides irrelevant implementation details.

### Build-Operate-Check Pattern

Structure each test in three distinct phases: **Build** the test data, **Operate** on it, then **Check** the results. This pattern keeps tests focused and readable.

### A Dual Standard

Test code lives in a test environment, not a production environment. It is acceptable to sacrifice some performance efficiency (e.g., using string concatenation instead of `StringBuffer`) when it improves readability. What is never acceptable is sacrificing *cleanliness*.

## One Assert per Test

One school of thought requires exactly one `assert` per test function. A looser but more practical guideline: **minimise the number of asserts** and, where possible, rely on a domain-specific testing API that compresses multiple checks into a single expressive assertion.

## Single Concept per Test

The more important rule is that each test function covers **a single concept**. Do not write long test functions that mix multiple unrelated scenarios in sequence. When a test fails, you should know immediately which concept has broken.

## F.I.R.S.T. Principles

| Letter | Principle | Description |
|--------|-----------|-------------|
| F | Fast | Tests must run quickly so they are run often. Slow tests go unrun. |
| I | Independent | Tests must not depend on each other. Any test should be runnable in isolation and in any order. |
| R | Repeatable | Tests must pass in every environment: production, QA, developer laptop with no network. |
| S | Self-validating | Tests must have a clear boolean outcome -- pass or fail -- requiring no manual inspection. |
| T | Timely | Tests should be written just before the production code that makes them pass. |

---

## Key Rules / Quick Reference

- Test code has the same quality requirements as production code.
- Follow the Three Laws of TDD: failing test first, minimum test to fail, minimum code to pass.
- Clean tests are readable -- use helper methods to hide irrelevant setup.
- Build-Operate-Check: structure every test in three clear phases.
- One concept per test; minimise the number of asserts.
- Dirty tests lead to loss of the test suite, which leads to production code rot.
- F.I.R.S.T.: Fast, Independent, Repeatable, Self-validating, Timely.

## Summary

Unit tests are equal partners in the health of a project. They preserve and enhance the flexibility, maintainability, and reusability of the production code. Keep them as clean as the production code, refactor them relentlessly, and let them express your intent clearly. If you let the tests rot, the code will rot too.