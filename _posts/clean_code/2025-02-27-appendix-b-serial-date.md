---
author: Xavier Salvador
title: Appendix B.- org.jfree.date.SerialDate
page_order: APENDICE_B
date: 2025-02-27
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

Appendix B contains the complete source-code listing of `org.jfree.date.SerialDate`, taken from the open-source JCommon library. Its presence in the book serves a very specific educational purpose.

<!--more-->

## What the Appendix Contains

The appendix reproduces in full the `SerialDate.java` file and the related JCommon files as they existed before the author refactored them in Chapter 16. Included are:

- `SerialDate.java`: the abstract base class (~900 lines)
- `MonthConstants.java`: interface containing the month constants
- `SpreadsheetDate.java`: concrete implementation of `SerialDate`
- `RelativeDayOfWeekRule.java`: auxiliary rule that uses `SerialDate`
- The final refactored listing (`DayDate.java` and associated classes)

## Why It Is in the Book

Chapter 16 analyses `SerialDate` line by line and proposes dozens of changes. So that readers can follow that analysis with the code in front of them — and see exactly which lines the author refers to when citing "line 98", "line 326", or "line 638" — the appendix provides the original, numbered source.

Without the appendix, the Chapter 16 references to specific line numbers would be opaque. With it, readers can verify every refactoring decision in its original context.

## Relationship to Chapter 16

The recommended reading flow is:

1. Read Chapter 16 with the appendix open as a reference.
2. Follow each proposed change (renaming the class, converting constants to enums, moving methods, removing dead code) against the original listing.
3. Compare the result with the final refactored listing, also included in the appendix.

This exercise illustrates how perfectly functional code can be substantially improved in clarity, cohesion, and adherence to Clean Code principles without changing its external behaviour.

## Summary

Appendix B is not standalone reading — it is the reference material for the Chapter 16 case study. Its value lies in allowing readers to be active participants in the refactoring, verifying each applied heuristic against the original JCommon code.