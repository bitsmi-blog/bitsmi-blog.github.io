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

<!--more-->

# Appendix A — Concurrency II

This short consultancy-style appendix covers practical, advanced concerns when working with concurrent and parallel code. It assumes you already know the basics (threads, locks, volatile, synchronized) and focuses on patterns, testing strategies, performance heuristics, and migration steps you can apply quickly.

Use this note as a short reference during design discussions, code reviews, and incident triage when concurrency is involved.

## Goals and constraints

- Make concurrency predictable and testable.
- Minimize shared mutable state and reduce contention.
- Choose high-level constructs (executors, futures, streams, reactive) over raw threads where appropriate.
- Document and measure behavior; prefer small iterative changes.

## Common high-level patterns

1. Task-based parallelism (ExecutorService / thread pools)
   - Use a bounded thread pool for CPU-bound tasks (size around number of cores).
   - Use larger pools for I/O-bound tasks, but prefer asynchronous I/O if possible.
   - Never create unbounded thread pools in production without controls.

2. Futures and composition (CompletableFuture / Future)
   - Prefer composing independent computations with futures instead of blocking waits.
   - Use timeouts and exception handlers; avoid silent swallowing of exceptions.

3. Work-stealing and fork-join (ForkJoinPool)
   - Use for divide-and-conquer parallelism (e.g., parallel streams). Ensure tasks are small and balanced.

4. Messaging and Actors
   - Use actor-style isolation (Akka, Vert.x, or simple single-threaded queues) to avoid shared mutable state. Good for bounded concurrency and domain isolation.

5. Lock-free and concurrent collections
   - Use java.util.concurrent collections (ConcurrentHashMap, ConcurrentLinkedQueue) when possible.
   - Only attempt custom lock-free algorithms with strong justification and deep review—they are easy to get wrong.

6. Immutable state and functional transformations
   - Prefer immutable data structures for safe sharing; copy-on-write or persistent collections help when mutations are rare.

## Practical examples (Java)

Here are short idiomatic examples you can copy into Scala/Java projects.

1) ExecutorService (bounded pool) pattern

```text
ExecutorService pool = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors());
try {
    List<Callable<Result>> tasks = ...;
    List<Future<Result>> results = pool.invokeAll(tasks);
    // process results
} finally {
    pool.shutdown();
}
```

Notes: use invokeAll with timeouts when tasks may hang; prefer submit+timeout handling for finer control.

2) CompletableFuture composition (non-blocking)

```text
CompletableFuture.supplyAsync(() -> fetchUser(userId), pool)
    .thenCompose(user -> CompletableFuture.supplyAsync(() -> fetchOrders(user), pool))
    .thenApply(orders -> aggregate(orders))
    .exceptionally(ex -> handle(ex));
```

Tips: always handle exceptions and consider using `orTimeout` to avoid indefinite waits.

3) Actor-like queue (single-threaded worker)

```text
BlockingQueue<Runnable> queue = new LinkedBlockingQueue<>();
Thread worker = new Thread(() -> {
    while (!Thread.currentThread().isInterrupted()) {
        try {
            Runnable job = queue.take();
            job.run();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
});
worker.start();
// offer tasks: queue.offer(() -> doWork(...));
```

Use bounded queues and backpressure to prevent unbounded memory growth.

## Testing and debugging concurrent code

- Characterization tests: write deterministic tests that capture current behavior before changes.
- Unit-level concurrency tests: prefer testing small units with simulated concurrency using tools such as JUnit + concurrency testing helpers (CountDownLatch, CyclicBarrier, Semaphore) to coordinate threads.
- Use deterministic concurrency frameworks for tests (e.g., thread schedulers in concurrency testing libraries) when possible.
- Reproduce flaky behavior locally by running tests in loop, under stress, and with varied thread scheduling (CI runners can help).
- Add logs with thread names and correlation ids — helpful for reproducing race windows.
- Use async assertions and timeouts in tests to avoid indefinite blocking.

Example: testing a concurrent increment

```text
@Test
void concurrentIncrement() throws InterruptedException {
    AtomicInteger counter = new AtomicInteger();
    int threads = 10;
    ExecutorService pool = Executors.newFixedThreadPool(threads);
    CountDownLatch start = new CountDownLatch(1);
    CountDownLatch done = new CountDownLatch(threads);

    for (int i = 0; i < threads; i++) {
        pool.submit(() -> {
            try {
                start.await();
                for (int j = 0; j < 1000; j++) counter.incrementAndGet();
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            } finally {
                done.countDown();
            }
        });
    }
    start.countDown();
    assertTrue(done.await(5, TimeUnit.SECONDS));
    assertEquals(threads * 1000, counter.get());
    pool.shutdownNow();
}
```

## Performance and contention heuristics

- Measure first: use flame graphs, contention sampling (Java Flight Recorder, async-profiler), and latency histograms.
- Hotspots: synchronized methods, locks with long hold times, cache misses due to false sharing.
- Use fine-grained locks or lock striping to reduce contention; prefer read-write locks only when readers vastly outnumber writers.
- Beware of false sharing: align frequently-updated fields or use padding to avoid CPU cache line contention.
- Prefer batching updates and reducing synchronization frequency (e.g., accumulate locally then flush).

## Common pitfalls and how to detect/fix them

1. Excessive thread creation
   - Symptom: threads pile up, GC pressure, OOM. Fix: use bounded pools and backpressure.

2. Deadlocks
   - Symptom: system stalls with threads waiting on locks. Fix: detect with thread dumps, enforce lock ordering, or use tryLock with timeouts and recovery.

3. Live locks and starvation
   - Symptom: progress slows; some tasks never complete. Fix: fairness mechanisms, bounded retries, or redesign to avoid priority inversion.

4. Silent exception swallowing
   - Symptom: background tasks stop processing without clear error. Fix: centralize exception handling, log and surface failures, fail-fast where appropriate.

## Migration strategy: small, measurable steps

- Start with adding timeouts, metrics, and better logging around suspect concurrency code.
- Replace raw threads with executor-based abstractions in a single module and measure behavior.
- Introduce immutable messages and actor boundaries where shared state causes bugs.
- Run canaries and increase load gradually; monitor error rates and latencies.

## Quick checklist (consultancy)

- [ ] Do we measure concurrency-related metrics (latency, queue depth, thread counts)?
- [ ] Are thread pools bounded and sized appropriately for the workload?
- [ ] Are timeouts and exception handlers present for background tasks?
- [ ] Is shared mutable state minimized or protected by appropriate concurrency primitives?
- [ ] Are concurrent collections used where appropriate instead of manual synchronization?
- [ ] Are tests in place to assert correctness under concurrent access and to reproduce known race conditions?
- [ ] Are logs and thread dumps configured for production troubleshooting?

## Recommended next steps

- Add a short benchmark and contention profile for the suspect module.
- Replace any ad-hoc thread creation with a controlled ExecutorService and add metrics for queue depth and execution latency.
- Add small deterministic concurrency tests (use CountDownLatch/CyclicBarrier) to capture and prevent regressions.

If you want, I can create a small PR that replaces raw thread usage in one module with a safe ExecutorService wrapper, add metrics and a simple concurrent unit test. Point me to the file(s) you want me to change and I'll prepare the changes and run a validation locally.
