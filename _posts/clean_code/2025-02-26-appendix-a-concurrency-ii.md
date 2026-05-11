---
author: Xavier Salvador
title: Appendix A.- Concurrency II
page_order: APENDICE_A
date: 2025-02-26
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

Appendix A, written by Brett L. Schuchert, extends Chapter 13 on concurrency with deeper analysis: a client/server example, possible execution paths, deadlock, and strategies for increasing throughput.

<!--more-->

## Client/Server Example

### Single-threaded Version

A server waits on a socket, processes each request, and waits again. A performance test requires it to process a set of requests in under 10 seconds:

```java
@Test(timeout = 10000)
public void shouldRunInUnder10Seconds() throws Exception {
    Thread[] threads = createThreads();
    startAllThreads(threads);
    waitForAllThreadsToFinish(threads);
}
```

If the test fails, the question is: where is the time being spent?

- **I/O operations** (sockets, databases, virtual memory): the CPU waits.
- **CPU operations** (calculations, regex, GC): the CPU works.

If the system is I/O-bound, multithreading can improve performance by overlapping waits with processing.

### Adding Threads

A naive solution is to create one thread per request:

```java
void process(final Socket socket) {
    Runnable clientHandler = new Runnable() {
        public void run() {
            String message = MessageUtils.getMessage(socket);
            MessageUtils.sendMessage(socket, "Processed: " + message);
            closeIgnoringException(socket);
        }
    };
    new Thread(clientHandler).start();
}
```

This makes the test pass, but it violates the Single Responsibility Principle. The `process` function simultaneously manages: socket connections, client processing, threading policy, and shutdown policy.

### Clean Design with SRP

A `ClientScheduler` interface is introduced to isolate all threading logic:

```java
public interface ClientScheduler {
    void schedule(ClientRequestProcessor requestProcessor);
}
```

Interchangeable implementations: `ThreadPerRequestScheduler` and `ExecutorClientScheduler` (using `java.util.concurrent.Executors.newFixedThreadPool`). Business code knows nothing about threads.

## Possible Execution Paths

An apparently innocent Java line can expand into several JVM bytecodes:

```java
return ++lastIdUsed;
```

This operation comprises: reading `lastIdUsed`, incrementing, writing, and returning. With two threads starting with `lastIdUsed = 93`, the possible outcomes are:

- T1 gets 94, T2 gets 95, `lastIdUsed` = 95 ✓
- T1 gets 95, T2 gets 94, `lastIdUsed` = 95 ✓
- T1 gets 94, T2 gets 94, `lastIdUsed` = 94 ✗ (race condition)

The number of possible execution paths for N bytecodes and T threads grows exponentially. To prevent incorrect results, critical sections must be protected with `synchronized` or by using classes from the `java.util.concurrent.atomic` package.

## Deadlock

### The Four Conditions

Deadlock requires four conditions to hold simultaneously:

1. **Mutual exclusion**: the resource cannot be used by more than one thread at a time.
2. **Lock & Wait**: a thread holds a resource while waiting to acquire another.
3. **No preemption**: a thread cannot forcibly take a resource from another.
4. **Circular wait**: T1 waits for a resource held by T2, and T2 waits for one held by T1.

### Concrete Example

A web server with two pools (DB connections and MQ connections):

- "Create" threads acquire DB first, then MQ.
- "Update" threads acquire MQ first, then DB.

If all resources of one type are exhausted at the wrong moment, the system locks up indefinitely.

### Breaking Deadlock

It is sufficient to break *one* of the four conditions:

| Condition | Strategy |
|-----------|----------|
| Mutual exclusion | Use concurrent resources (`AtomicInteger`); increase the number of resources |
| Lock & Wait | Check availability before acquiring; if any is unavailable, release all and retry |
| No preemption | Rarely applicable directly |
| Circular wait | Agree on a global resource acquisition order and always follow it |

The most robust strategy is to order resources: if all threads always acquire resources in the same order (DB first, then MQ), circular wait becomes impossible.

## Client-Side vs Server-Side Locking

Client-side locking (each consumer synchronises before using the object) has multiple problems: duplication, error-proneness, and coupling. Server-side locking (the object synchronises its own methods) is preferable:

- Reduces repeated code.
- Allows swapping a thread-safe implementation for a non-thread-safe one in single-threaded deployments.
- Centralises the policy: if there is a concurrency bug, there is one place to look.

If the server cannot be modified, use an ADAPTER that adds synchronisation around the existing API.

## Increasing Throughput

For a system that downloads pages and processes them:

- I/O time per page: 1 s (0% CPU)
- Processing time: 0.5 s (100% CPU)

With a single thread: 1.5 s × N pages.

With three threads: downloads overlap with processing. Throughput ≈ 3×. The key is to keep the `synchronized` block as small as possible (only the critical section that fetches the next URL).

## Key Rules

| Principle | Description |
|-----------|-------------|
| SRP in concurrency | Code that manages threads should do nothing else |
| Small critical sections | Synchronise only the absolute minimum |
| JDK thread-safe classes | Prefer `java.util.concurrent` over manual management |
| Resource acquisition order | The most effective strategy against deadlock |
| Concurrency testing | Vary configurations, thread counts, and loads to expose race conditions |

## Summary

Concurrency demands additional discipline: the SRP applied to threading code, awareness of possible execution paths, and knowledge of the four deadlock conditions are the fundamental tools for writing correct and maintainable concurrent systems.