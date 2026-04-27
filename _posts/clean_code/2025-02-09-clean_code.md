---
author: Xavier Salvador
title: 1.- Clean Code
page_order: 01
date: 2025-02-09
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

## Overview

This chapter explains why clean code matters, what it looks like according to respected practitioners, and what attitude a professional programmer must adopt. It sets the tone for the entire book.

<!--more-->

## There Will Be Code

Code represents the details of a requirement. Despite trends toward higher-level abstractions, code will always be needed — requirements cannot be so precisely specified that they become self-executing.

## Bad Code

Bad code can bring down a company.

**Wading**: The experience of struggling through code that is hard to understand or navigate.

If cleanup is deferred with "We will review it later", it will never happen.

***LeBlanc's Law: "Later equals never."***

## The Total Cost of Owning a Mess

Teams that move fast early on can find themselves nearly paralyzed after a year or two. Every change requires understanding a tangled web of code. Management may add staff to fix the productivity loss — but new team members, unfamiliar with the codebase, often make the mess worse.

**Conclusion**: keeping code clean is not only cost effective but a matter of professional survival.

## Attitude

Programmers bear responsibility for code quality. Managers defend schedules and requirements with passion — it is the programmer's job to defend the code with equal passion.

## The Primal Conundrum

The only way to meet a schedule consistently is to keep the code as clean as possible at all times. Letting code degrade to go faster is always self-defeating.

## The Art of Clean Code

Writing clean code requires a painstakingly acquired **"code-sense"**. A programmer with this sense can look at messy code and see the strategy for transforming it — not just recognise that it is messy.

## What Practitioners Say About Clean Code

- **Bjarne Stroustrup**: Elegant and efficient; does one thing well; complete error handling; minimal dependencies.
- **Grady Booch**: Reads like well-written prose; never obscures the designer's intent; crisp abstractions.
- **Dave Thomas**: Can be read and enhanced by others; has unit and acceptance tests; minimal, explicitly defined dependencies.
- **Michael Feathers**: Always looks like it was written by someone who cares.
- **Ron Jeffries**: Runs all tests; no duplication; expresses all design ideas; minimises the number of entities.
- **Ward Cunningham**: Each routine you read turns out to be pretty much what you expected.

## The Boy Scout Rule

*"Leave the campground cleaner than you found it."*

It is not enough to write code well initially. Check in every piece of code a little cleaner than you found it.

## Quick Reference

- Bad code accumulates silently — "later" never comes (LeBlanc's Law).
- Messy code destroys productivity; adding staff does not fix a messy codebase.
- Defend code quality as actively as managers defend schedules.
- The only way to go fast long-term is to keep the code clean.
- Apply the Boy Scout Rule: always leave the code slightly better than you found it.
- There is no substitute for practice — knowledge of principles alone is not enough.