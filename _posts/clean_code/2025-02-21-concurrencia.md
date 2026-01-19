---
author: Xavier Salvador
title: 13.- Concurrency
page_order: 13
date: 2025-02-21
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

<!--more-->

Concurrency is one of the hardest areas in software design: small mistakes produce subtle, intermittent bugs that are expensive to find and fix. This short consultancy-style guide helps you perform a rapid audit of a package or set of files and provides a prioritized checklist of practical patches you can apply immediately.

If you want a tailored checklist, tell me the package or files to audit and I'll provide a customized list of fixes and example patches.

What I deliver (quick consultancy):

- A concise audit checklist you can run in under an hour.
- High-impact, low-effort patches to stabilize concurrency behavior.
- Small code examples showing safe patterns and anti-patterns to avoid.
- A simple risk/priority matrix to guide what to fix first.

Contract (what this checklist assumes and guarantees)

- Input: a package or a set of source files (Java, Kotlin, or similar JVM languages).
- Output: a short, prioritized list of findings and suggested patches with code snippets.
- Error modes: missing source, mixed languages, or framework-specific concurrency features (you can provide hints in that case).
- Success: you receive a targeted checklist and example patches you can apply quickly.

Quick audit checklist (run in ~30-60 minutes)

1. Identify concurrency boundaries
   - Find threads, runnables, executors, scheduled tasks, and places using locks or atomics.
   - Grep for Thread, Runnable, Executor, ScheduledExecutorService, synchronized, volatile, Atomic, CompletableFuture, ForkJoin.

2. Look for shared mutable state
   - Find non-final fields accessed from multiple threads.
   - Check for collections not wrapped or not using concurrent collections.

3. Check publication safety
   - Ensure objects shared between threads are safely published (final fields or proper synchronization).

4. Check for improper locking
   - Spot synchronized(this) or locking on publicly accessible objects.
   - Look for nested locks that may create deadlocks.

5. Evaluate thread lifecycle & resource usage
   - Ensure executors are bounded and shut down properly.
   - Look for creation of threads in hot paths (use pools instead).

6. Timeouts, interruption and cancellation
   - Ensure blocking calls use timeouts or handle InterruptedException.
   - Verify long-running tasks check for interruption or a cancellation token.

7. Use of high-level concurrency utilities
   - Prefer ConcurrentHashMap, CopyOnWriteArrayList, BlockingQueue, and java.util.concurrent primitives
   - Prefer CompletableFuture or structured concurrency patterns over ad-hoc thread management.

8. Test coverage
   - Check for tests that assert concurrency behavior deterministically or use stress tests and deterministic tools (e.g., thread sanitizers, timeouts).

Common problems and quick patches (high-impact, low-effort)

- Problem: Non-final published fields cause visibility bugs.
  Patch: Make fields final or initialize inside a constructor and avoid later mutation.

  Example:

  ```java
  // bad
  public class Cache {
    private Map<String, String> map = new HashMap<>();
    public void put(String k, String v) { map.put(k, v); }
  }

  // quick patch
  public class Cache {
    private final Map<String, String> map = new ConcurrentHashMap<>();
    public void put(String k, String v) { map.put(k, v); }
  }
  ```

- Problem: Unbounded thread creation causing resource exhaustion.
  Patch: Replace new Thread(...) with a bounded ExecutorService.

  Example:

  ```java
  // bad
  new Thread(task).start();

  // patch
  private static final ExecutorService POOL = Executors.newFixedThreadPool(8);
  POOL.execute(task);
  ```

- Problem: Locking on public objects or using synchronized(this).
  Patch: Use a private final lock object or explicit ReentrantLock.

  ```java
  private final Object lock = new Object();
  synchronized(lock) { /* critical section */ }
  ```

- Problem: Double-checked locking incorrect publication.
  Patch: Use volatile for the instance or prefer initialization-on-demand holder idiom.

  ```java
  private static volatile Foo instance;
  public static Foo get() {
    if (instance == null) {
      synchronized(Foo.class) {
        if (instance == null) instance = new Foo();
      }
    }
    return instance;
  }
  ```

Practical short list of small patches to apply first (priority)

1. Replace HashMap/ArrayList used across threads with ConcurrentHashMap/CopyOnWriteArrayList or synchronize access (Priority: High)
2. Make shared fields final where possible and prefer immutability (Priority: High)
3. Replace ad-hoc threads with a bounded ExecutorService and ensure proper shutdown (Priority: High)
4. Add timeouts to blocking calls and handle interrupts (Priority: Medium)
5. Replace synchronized on public objects with private lock objects (Priority: Medium)
6. Add tests that reproduce the concurrency scenario using timeouts and repeated runs (Priority: Medium)

Risk/priority matrix (quick guidance)

- High risk: visibility bugs, unbounded threads, deadlocks — fix immediately.
- Medium risk: inefficient synchronization, missing timeouts — schedule soon.
- Low risk: micro-optimizations in lock-free algorithms — defer.

Example micro-checks (grep patterns)

- Thread creation: "new Thread(" or "Thread(" or "Executors\.new" or "ScheduledExecutor"
- Synchronization: "synchronized(" or "synchronized void" or "ReentrantLock"
- Shared state: non-final fields and non-private mutable collections

How I can help further (next steps)

- Provide a tailored checklist and patch set if you point me to the package or files to audit (I will produce precise diffs or suggested edits).
- Add small unit/integration tests that reliably reproduce the bug and guard against regressions.
- Convert ad-hoc concurrency constructs to higher-level patterns (CompletableFuture, structured concurrency) with minimal changes.

If you'd like a custom audit, tell me which package(s) or files to inspect (for example: `com.myapp.cache` or `src/main/java/com/example/worker/**`). I'll produce a prioritized checklist and example patches you can apply immediately.
