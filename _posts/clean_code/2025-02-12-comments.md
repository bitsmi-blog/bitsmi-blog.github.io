---
author: Xavier Salvador
title: 4.- Comments
page_order: 04
date: 2025-02-11
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

## Overview

Comments are not inherently good. At best they are a necessary evil — a compensation for our failure to express ourselves clearly in code. The proper response to bad code is to clean it, not to comment it.

*"Don't comment bad code — rewrite it."* — Kernighan and Plaugher

<!--more-->

## Comments Do Not Make Up for Bad Code

The motivation for most comments is bad code. Rather than writing a comment to explain a mess, clean the mess.

## Explain Yourself in Code

In most cases you can create a function that says the same thing as the comment you wanted to write:

```java
// Bad
// Check to see if the employee is eligible for full benefits
if ((employee.flags & HOURLY_FLAG) && (employee.age > 65))

// Good
if (employee.isEligibleForFullBenefits())
```

## Good Comments

Some comments are necessary or beneficial:

- **Legal comments**: copyright and authorship statements required by corporate standards. Refer to an external licence file rather than reproducing full terms inline.
- **Informative comments**: basic information that cannot easily be expressed in the code itself, such as explaining the format matched by a regular expression.
- **Explanation of intent**: a comment that explains the reason behind a decision, not just what the code does.
- **Clarification**: translating an obscure argument or return value into something readable, especially when the code cannot be changed (e.g., a standard library call).
- **Warning of consequences**: alerting other programmers to a known side effect or risk.
- **TODO comments**: notes for work that should be done but cannot be done right now. Not an excuse to leave bad code. Scan and remove TODOs regularly.
- **Amplification**: a comment that amplifies the importance of something that might otherwise seem inconsequential.

## Bad Comments

Most comments fall into this category.

- **Mumbling**: A comment written hastily that does not communicate clearly. If a comment is worth writing, write it precisely.
- **Redundant comments**: Comments that restate what the code already says clearly. They clutter the code without adding information.
- **Misleading comments**: Comments that are not precise enough to be accurate, leading readers to incorrect assumptions.
- **Mandated comments**: A rule requiring every function or variable to have a Javadoc is bureaucratic noise. Comments like this propagate lies and disorganisation.
- **Journal comments**: A log of every change at the top of a module. Version control makes these obsolete — remove them.
- **Noise comments**: Comments that restate the obvious (`/** Default constructor. */`) add no new information.
- **Frustration comments**: Comments that express frustration (`// Give me a break!`) should be replaced by refactoring the code that caused the frustration.
- **Commented-out code**: Leaving chunks of code in comments leads to confusion. Modern version control remembers old code — simply delete it.
- **HTML comments**: HTML markup in source code comments is an abomination; it makes the comments unreadable in the editor where they are most often read.
- **Nonlocal information**: A comment should describe the code it appears next to, not some distant part of the system. Nonlocal information will drift out of sync.
- **Too much information**: Do not put historical discussions or irrelevant technical details into a comment.
- **Inobvious connection**: The connection between a comment and the code it describes should be obvious. If the comment requires its own explanation, it has failed.
- **Function headers**: Short, well-named functions rarely need a header comment. A good name does the job better.
- **Javadocs in nonpublic code**: Javadoc comments are useful for public APIs. Generating them for every internal function or class is unnecessary formality.
- **Position markers and closing-brace comments**: Banner comments (`// Actions ////`) and `} // while` labels are unnecessary when functions are short and well-structured.

## Quick Reference

| Type | Use |
|------|-----|
| Legal | Required; reference external licence file |
| Informative | Only when code cannot express it |
| Intent | Explain *why*, not *what* |
| Clarification | For unalterable APIs only |
| Warning | Alert to side effects or risks |
| TODO | Temporary; remove regularly |
| Amplification | Highlight non-obvious importance |

**Bad comment checklist** — avoid:
- Redundant, mandated, or journal comments
- Commented-out code
- Noise, HTML, nonlocal, or misleading comments
- Javadocs on nonpublic code
- Position markers and closing-brace labels