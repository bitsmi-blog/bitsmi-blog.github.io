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

Writing clean concurrent programs is hard. Code that looks correct on the surface is often broken at a deeper level and only fails when the system is under stress. Chapter 13 explains why concurrency is difficult, presents defence principles, catalogues the classic execution models, and gives practical guidance for testing threaded code.

<!--more-->

## Why Concurrency?

Concurrency is a decoupling strategy. It separates *what* gets done from *when* it gets done. In a single-threaded application, the call stack is the state of the system; a programmer can set a breakpoint and know exactly where things stand. Decoupling what from when can dramatically improve both throughput and structure.

Common motivations:

- An information aggregator hitting many web sites sequentially takes too long as the number of sites grows; concurrent requests finish in a fraction of the time.
- A system that handles one user at a time forces each user to queue behind all others; concurrent handling eliminates that bottleneck.
- Large data-set processing tasks can be distributed across processors working in parallel.

## Myths and Misconceptions

Before diving into defence, acknowledge the common wrong beliefs:

- **"Concurrency always improves performance."** It can, but only when there is idle wait time that multiple threads or processors can share. Neither situation is trivial.
- **"Design does not change when writing concurrent programs."** The design of a concurrent algorithm is often radically different from the equivalent single-threaded design. Decoupling what from when has a large structural impact.
- **"Understanding concurrency issues is not important when using a container."** Web and EJB containers manage some concurrency, but you must still guard against concurrent update and deadlock.

Additional truths worth internalising:

- Concurrency incurs overhead in performance and in additional code.
- Correct concurrency is complex even for simple problems.
- Concurrency bugs are rarely repeatable, so they are frequently dismissed as one-offs rather than fixed.
- Concurrency often requires a fundamental change in design strategy.

## Challenges

Consider a trivially small class:

```java
public class X {
    private int lastIdUsed;
    public int getNextId() { return ++lastIdUsed; }
}
```

If two threads share a single instance with `lastIdUsed` set to 42 and both call `getNextId()`, there are three possible outcomes:

- Thread 1 gets 43, thread 2 gets 44 — correct.
- Thread 1 gets 44, thread 2 gets 43 — correct, different order.
- Both threads get 43 — incorrect, data lost.

A JIT-level analysis reveals 12,870 possible execution paths through that one line of bytecode for two threads. Most produce valid results; some do not.

## Concurrency Defence Principles

### Single Responsibility Principle

Concurrency design is complex enough to deserve its own class (or set of classes), separate from the production logic it serves. Keep concurrency-related code separate from other code.

### Limit the Scope of Data

Protect shared data with `synchronized` critical sections, but minimise how many places that data can be updated. The more locations that write to shared state, the more likely you will forget to protect one, duplicate protective effort, or struggle to find the source of failures.

**Recommendation:** Take data encapsulation to heart; severely limit access to any data that may be shared.

### Use Copies of Data

One of the best ways to avoid shared-data problems is to avoid sharing data at all. Copy objects and treat them as read-only. Collect results from multiple threads in their copies, then merge in a single thread. The cost of extra object creation is usually lower than the cost of synchronisation overhead.

### Threads Should Be as Independent as Possible

Write threaded code such that each thread lives in its own world, taking all required data from unshared sources and keeping results in local variables. Each thread then behaves as if it were the only thread in the world.

## Know Your Library

Java 5 introduced `java.util.concurrent`, `java.util.concurrent.atomic`, and `java.util.concurrent.locks`. Use them.

| Utility | Purpose |
|---------|---------|
| `ConcurrentHashMap` | Thread-safe map; faster than `HashMap` in most situations |
| `ReentrantLock` | Lock that can be acquired in one method and released in another |
| `Semaphore` | Classic semaphore — a lock with a count |
| `CountDownLatch` | Waits for a number of events before releasing all waiting threads |

Prefer these over writing your own synchronisation primitives.

## Know Your Execution Models

Three fundamental problems recur across concurrent systems. Understanding them and their solutions is essential.

**Definitions:**

- *Bound resource* — a resource of fixed size shared in a concurrent environment (e.g., a fixed-size buffer or a database connection pool).
- *Mutual exclusion* — only one thread can access shared data at a time.
- *Starvation* — a thread or group of threads is prevented from proceeding for an excessively long time.
- *Deadlock* — two or more threads each hold a resource the other requires and neither can finish.
- *Livelock* — threads in lockstep, continuously stepping on each other, unable to make progress.

### Producer-Consumer

One or more producers place work into a bound-resource queue; one or more consumers take work from that queue. The queue acts as a handshake: producers wait when the queue is full; consumers wait when the queue is empty. Both must signal each other when they write to or read from the queue.

### Readers-Writers

A shared resource serves primarily as a source of information for readers but is occasionally updated by writers. Throughput versus consistency is the core tension. Giving writers priority can cause throughput to suffer; giving readers priority can starve writers and allow stale data to accumulate. Finding the right balance requires careful design.

### Dining Philosophers

Philosophers sit at a circular table. A fork lies between each pair of neighbours. A philosopher must hold *two* forks to eat. Threads are the philosophers; forks are resources. Systems that compete for resources this way risk deadlock, livelock, and throughput degradation unless carefully designed.

**Recommendation:** Study these three models and practise writing solutions. Most concurrency problems you encounter will be a variation of one of them.

## Beware Dependencies Between Synchronized Methods

When a shared class has more than one `synchronized` method, the system can be written incorrectly even if each method individually is correctly synchronised. When forced to use multiple methods on a shared object, choose one of:

- *Client-based locking* — the client locks the server before calling the first method and holds the lock until after the last.
- *Server-based locking* — the server provides a single method that acquires the lock, calls all required methods, then releases.
- *Adapted server* — create an intermediary that provides server-based locking without modifying the original server.

## Keep Synchronized Sections Small

Locks create delays and add overhead. Do not litter code with `synchronized` statements. Extend synchronisation only to the minimal critical section needed for correctness. Extending synchronisation beyond that minimum increases contention and degrades performance.

## Writing Correct Shut-Down Code Is Hard

A system that must shut down gracefully is much harder to implement than one that runs forever. Deadlock is the most common problem: threads wait forever for a signal that never comes. A parent thread waiting for all children to finish will wait forever if one child is deadlocked. A producer-consumer pair can deadlock during shutdown if the producer shuts down first and the consumer is still waiting for a message.

**Recommendation:** Think about shutdown early and plan for it. It will take longer than you expect.

## Testing Threaded Code

Testing does not guarantee correctness, but good testing minimises risk. The difficulty multiplies when two or more threads operate on the same code with shared data.

Key recommendations:

- **Treat spurious failures as candidate threading issues.** Do not dismiss a one-off failure as cosmic-ray noise. The longer such failures are ignored, the more code is built on a potentially faulty foundation.
- **Get the nonthreaded code working first.** Separate the POJOs that contain the logic from the threading code. Test the POJOs without threads.
- **Make threaded code pluggable.** Run it in single-thread mode, in multiple-thread mode, and with thread counts that vary at runtime. Run against both real and test-double collaborators.
- **Make threaded code tunable.** Allow the thread count to be adjusted at runtime so you can find the right balance by trial and error.
- **Run with more threads than processors.** Task switches expose missing critical sections and latent deadlocks. More threads means more task switching.
- **Run on different platforms.** Threading policies differ across operating systems. Tests that pass consistently on one platform may fail frequently on another.
- **Instrument code to force failures.** Insert calls to `Thread.yield()`, `Thread.sleep()`, or `Thread.setPriority()` in strategic places to alter execution ordering and expose latent bugs. For production safety, use AOP-based frameworks to inject these calls automatically during testing only.

## Key Rules

| Rule | Recommendation |
|------|----------------|
| Separate concurrent code | Keep it apart from production logic |
| Limit shared data | Minimise the places shared state can be changed |
| Prefer copies | Avoid sharing data by copying objects where feasible |
| Keep threads independent | Each thread should operate on unshared, local data |
| Use `java.util.concurrent` | Prefer thread-safe collections and synchronisation primitives |
| Know the execution models | Study Producer-Consumer, Readers-Writers, Dining Philosophers |
| Keep critical sections small | Do not extend locks beyond the minimum required |
| Plan for shutdown | Design and test graceful shutdown early |
| Test thoroughly | Run on multiple platforms, with more threads than processors |

## Summary

Concurrency is hard because even trivially small code can produce thousands of possible execution paths, only some of which are correct, and failures are rarely repeatable. The defences are disciplined: keep concurrent code separate, limit shared mutable state, prefer copies of data, keep threads independent, use the library's thread-safe utilities, and restrict critical sections to the absolute minimum. The three classic models — Producer-Consumer, Readers-Writers, and Dining Philosophers — cover most real-world concurrency problems. Testing must be aggressive: run on different platforms, with more threads than processors, with instrumented code that forces rare paths to execute.