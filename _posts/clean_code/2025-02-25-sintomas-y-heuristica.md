---
author: Xavier Salvador
title: 17.- Heuristics and systems
page_order: 17
date: 2025-02-25
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

<!--more-->

# Heuristics and systems

This short consultancy-style note explains how to use heuristics to diagnose, prioritize, and fix problems in software systems. It highlights common symptoms that indicate deeper issues, offers practical heuristics you can apply immediately, and describes how to think in systems so your fixes don't create new problems.

Use this as a quick checklist during code reviews, incident postmortems, or when planning refactors.

## What is a heuristic (in engineering terms)?

A heuristic is a simple, experience-based rule of thumb that helps you make decisions quickly when formal analysis is too costly or slow. In software, heuristics are used to spot likely problems, choose what to refactor first, and design safeguards. They are not guarantees; they guide attention to the most promising place to invest effort.

## Symptoms: what to look for first

These symptoms are practical signals that something in the code or system should be investigated further:

- Recurrent bugs in the same module or feature.
- Long or painful code reviews for the same set of files.
- Tests that are hard to write or frequently adjusted when requirements change.
- High coupling: many modules import or call the same low-level code.
- Slow deployments or frequent hotfixes in a particular area.
- Surprising side effects from small changes (brittle behavior).
- Monitoring alerts that spike after a particular change or release.

Each symptom can have multiple causes; treat them as invitations to ask focused questions rather than definitive diagnoses.

## Practical heuristics (quick rules you can use now)

1. The Small Surface Heuristic: prefer smaller, well-named public APIs. If a module exposes 20 public methods, consider whether responsibilities are mixed.

2. The Single-Reason Heuristic: a class or function should have one reason to change. If you can enumerate more than one cohesive reason, split it.

3. The Testability Heuristic: if it's hard to test a unit in isolation, its dependencies are too heavy or responsibilities are mixed. Aim to make the unit fast to instantiate and exercise.

4. The Dependency Direction Heuristic: dependencies should point inward to stable abstractions. If low-level modules depend on high-level business logic, invert boundaries.

5. The State Leakage Heuristic: if you need to reset global state between tests or runs, consider making state explicit or introducing controlled scopes.

6. The Observability Heuristic: if you cannot tell what changed from logs/metrics, add lightweight telemetry (entry/exit logs, key counters, error tags).

7. The Minimal Magic Heuristic: favor explicit code over clever, implicit behavior. Magic saves a tiny amount of typing but costs cognitive load for future readers.

8. The First Fix Heuristic: when a symptom appears, fix the simplest local problem first (tests, trivial validation) to stabilize the system; then work outward with deeper changes.

## Using heuristics during a code review or incident

- Start by listing the observable symptom(s) and the impact (how often, how severe).
- Apply 2–3 heuristics that fit the symptom (e.g., Testability and State Leakage for flaky tests).
- Propose targeted actions: add tests, extract a small interface, isolate side effects, add metrics.
- Time-box the initial fix and verify behavior before attempting larger refactors.

This process keeps early fixes low-risk while creating data to support bigger investments later.

## Thinking in systems — avoid local optimizations that break the whole

Systems thinking reminds us that a system's behavior emerges from the interactions of its parts. A few practical rules:

- Favor observable invariants: add metrics that express business expectations (requests per minute, percent successful, average latency) rather than only low-level traces.
- Consider feedback loops: caching, retries, and autoscaling interact in ways that can amplify faults. Model or simulate these interactions when possible.
- Avoid one-off special cases that bypass normal flows — they create fragile paths and testing blind spots.
- Small, repeated changes with measurement beat large rewrites with guesses. Use canary deployments and A/B tests for risky behavioral changes.

## Short examples (how to apply heuristics)

1) Flaky tests in a module
- Symptom: tests occasionally fail when run in CI but pass locally.
- Heuristics: Testability, State Leakage, Observability.
- Immediate actions: run tests in isolation, audit for shared static state, add setup/teardown in tests to reset environment, add a reproducible failing case.
- Longer-term: extract pure logic into small, immutable components and mock external systems in unit tests.

2) High bug frequency in a legacy parser
- Symptom: many bug fixes around parsing edge cases.
- Heuristics: Minimal Magic, Small Surface, First Fix.
- Immediate actions: add characterization tests covering observed failures; add clear input validation and explicit error messages.
- Longer-term: extract a small parser module with a well-defined API, and consider replacing ad-hoc parsing with a tested parsing library.

3) Slow degradation after deploy
- Symptom: latency increases only after particular deployments.
- Heuristics: Observability, Dependency Direction, Systems thinking.
- Immediate actions: add request-level tracing and latency histograms, roll back suspect change, run canary to reproduce.
- Longer-term: decouple synchronous dependencies, add timeouts and circuit breakers, and design graceful degradation paths.

## Quick checklist for a heuristic-driven review

- [ ] Did we capture the symptom and measure its impact?
- [ ] Which heuristics suggest likely causes?
- [ ] Can we stabilize the system with a small, reversible change first?
- [ ] Are there easy tests or metrics we can add to increase confidence?
- [ ] Is the proposed change localized or will it affect many components (risk)?
- [ ] Do we understand feedback loops and operational consequences?
- [ ] Is there a rollback or mitigation plan if the change increases risk?

## Communication and team practices

- Use heuristics during postmortems to focus learning (what worked, what didn't), not to assign blame.
- Share short remediation plans that include a quick stabilizing action and a longer-term improvement story.
- Keep the language concrete: "increase error logging for X" instead of "improve observability".
- Track recurring symptoms across sprints — recurring issues are signals for systemic investment.

## Recommended next steps (consultancy)

- Run a 1-hour triage session: list top 3 symptoms, pick one, apply heuristics, and implement a small stabilizing change.
- Add two or three high-value metrics and a simple dashboard to track the chosen symptom over time.
- Identify one module with recurrent problems and propose a small refactor plan using the Single-Reason and Small Surface heuristics.

If you'd like, I can help run the triage on your codebase, produce the quick fixes (tests, metrics, small refactors), and prepare a short PR with the proposed changes — point me at the repository or the files you want me to analyze.
