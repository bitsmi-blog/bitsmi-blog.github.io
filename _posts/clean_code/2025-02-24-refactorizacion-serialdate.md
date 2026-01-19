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

<!--more-->

# SerialDate refactor

This short consultancy-style note describes a pragmatic, test-driven approach to refactoring a legacy SerialDate class (a mutable, old-style date utility often found in legacy codebases) into a clear, well-factored, and modern API. The focus is on preserving behavior, reducing surprises, and making incremental, reviewable changes.

## Problem summary

Legacy code often contains a class named `SerialDate` (or similar) that mixes parsing, formatting, arithmetic, mutability, and sometimes global state. Common issues:

- Mutable internal state that leaks across callers.
- Use of integers or magic fields for year/month/day instead of a dedicated value object.
- Tight coupling to formatting or to legacy libraries.
- Implicit assumptions about time zones or locales.
- Poor test coverage or brittle tests that make refactor risky.

These problems lead to bugs, fragile code, and a high cost for safe changes.

## Goals for the refactor

- Preserve existing externally observable behavior (backwards compatibility) where required.
- Make date values immutable and explicit.
- Replace or adapt to java.time types where practical.
- Move parsing/formatting and I/O concerns out of the core value object.
- Provide a clear migration path for callers with minimal disruption.
- Add characterization tests before changing behavior.

## A pragmatic, safe plan (step-by-step)

1. Characterize current behavior with tests.
   - Write characterization tests that capture current inputs/outputs, edge cases, and rounding/rollover behavior.
   - If the project lacks unit tests, add a focused test suite that exercises parsing, arithmetic, comparisons, and equality.

2. Identify responsibilities and create a small design.
   - Split responsibilities: Value (date arithmetic & comparison) vs. Formatting/Parsing vs. Adapters/Legacy API.
   - Sketch minimal interfaces: SerialDateValue (immutable), SerialDateParser, SerialDateFormatter, SerialDateAdapter.

3. Implement an immutable value object.
   - Create a new `ImmutableSerialDate` (or `SerialLocalDate`) that wraps `java.time.LocalDate` or that stores final fields (year, month, day).
   - Implement equals/hashCode/toString and the arithmetic/compare operations.
   - Keep the constructor package-private if you want to force creation through factories.

4. Add adapters for legacy callers.
   - Implement `SerialDateAdapter` that delegates to the new immutable implementation but preserves the old mutable API by forwarding calls.
   - Mark adapter methods as @Deprecated if you plan to remove them later.

5. Replace usage incrementally.
   - Start by wiring a subset of callers to use the immutable type (new code paths, or tests), leaving adapters in place for risky or large modules.
   - Keep characterization tests green during the transition.

6. Remove legacy surface once callers are migrated.
   - When confident, either remove the old mutable class or shrink it to a thin wrapper around the new type.

## Tests-first: characterization tests (examples)

Before changing implementation, add tests that capture current behavior. Example assertions to add:

- Parsing of all supported formats (including odd legacy ones).
- Arithmetic: addDays, rollMonth, leap-year behavior.
- Comparisons: equals, before/after edge cases.
- Serialization/formatting hooks used by other systems.

These tests are not assertions of ideal design; they record what the system currently does so you don't change behavior unintentionally.

## Code: before and after (illustrative Java snippets)

Before (typical legacy mutable API):

```java
// ...legacy SerialDate (simplified)
public class SerialDate {
    private int year;
    private int month; // 1-12
    private int day;

    public SerialDate(int y, int m, int d) { this.year = y; this.month = m; this.day = d; }
    public void addDays(int n) { /* mutates fields with complex logic */ }
    public boolean before(SerialDate other) { /* compare fields */ }
    public String format(String pattern) { /* formatting logic here */ }
    // lots of other mutable convenience methods
}
```

After (immutable value + adapter):

```java
// Immutable value object that uses java.time under the hood
public final class SerialLocalDate {
    private final java.time.LocalDate date;

    private SerialLocalDate(java.time.LocalDate date) { this.date = date; }

    public static SerialLocalDate of(int year, int month, int day) {
        return new SerialLocalDate(java.time.LocalDate.of(year, month, day));
    }

    public SerialLocalDate plusDays(long days) { return new SerialLocalDate(date.plusDays(days)); }

    public boolean isBefore(SerialLocalDate other) { return this.date.isBefore(other.date); }

    public int getYear() { return date.getYear(); }
    // equals/hashCode/toString delegate to date
}

// Adapter to preserve old mutable API while delegating
@Deprecated
public class SerialDateAdapter {
    private SerialLocalDate value;

    public SerialDateAdapter(int y, int m, int d) { this.value = SerialLocalDate.of(y, m, d); }

    public void addDays(int n) { this.value = this.value.plusDays(n); }

    public boolean before(SerialDateAdapter other) { return this.value.isBefore(other.value); }

    public SerialLocalDate toValue() { return value; }
}
```

Notes:
- The adapter preserves behavior but delegates to immutable operations. This makes it easy to unit-test the new type and slowly migrate callers.
- Prefer `java.time` for correctness around leap years, months, and other well-known pitfalls.

## Migration strategy and safety nets

- Keep both implementations in the codebase during migration. Use the adapter to bridge surfaces.
- Add feature flags or small integration tests around modules that consume `SerialDate` to detect differences early.
- Run the characterization suite in CI and consider adding property-based tests for arithmetic invariants (e.g., addDays and subtractDays are inverses).
- Use deprecation notices and a clear removal timeline in changelogs to inform the team.

## Small, reviewable commits

Break the refactor into small commits that reviewers can understand:

- Add characterization tests (commit A).
- Add new immutable type and unit tests for it (commit B).
- Add adapter implementing old API delegating to new type (commit C).
- Replace a few callers to use the new type (commit D, E).
- Remove old implementation after full migration (final commit).

## Example pitfall and how to detect it

Pitfall: ignoring implicit timezone or locale sensitivity in formatting. Detect it by adding tests that assert consistent formatting under different default locales/time-zones (use explicit locale/time-zone in tests to avoid CI variability).

## Quick checklist (consultancy)

- [ ] Do characterization tests exist for current `SerialDate` behavior?
- [ ] Is there a clear, small immutable value object implementing core arithmetic and comparisons?
- [ ] Is parsing/formatting separated from the value object?
- [ ] Are adapters provided so callers can migrate incrementally?
- [ ] Do CI tests include scenarios for leap years and month boundaries?
- [ ] Are changes split into small commits for easy review?
- [ ] Is there a deprecation and removal plan communicated to the team?

## Recommended next steps

- Start by adding a minimal characterization test suite that runs quickly in CI.
- Implement the immutable `SerialLocalDate` and test thoroughly (use java.time equivalence tests).
- Add the adapter and convert a low-risk module to the new API as a proof of concept.
- Iterate until callers are comfortable and then retire the legacy class.

If you want, I can create a concrete PR that adds the characterization tests and a starter implementation of `SerialLocalDate` (with Maven/Gradle configuration and a tiny sample test). Tell me if you prefer a Java package naming convention or a particular style (use of `java.time` only, or minimal dependency footprint) and I will prepare the PR.
