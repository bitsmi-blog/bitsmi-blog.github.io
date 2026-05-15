---
author: Xavier Salvador
title: 8.- Boundaries
page_order: 08
date: 2025-02-16
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

## Overview

Chapter 8, written by James Grenning, addresses the challenge of integrating third-party or externally-controlled code into your system. The boundary between your code and foreign code requires special care: too much direct coupling to a third-party API spreads fragility throughout the codebase. The chapter presents techniques for keeping those boundaries clean and well-contained.

<!--more-->

## Using Third-Party Code

Third-party APIs are designed for broad applicability; your application needs a focused interface. This tension surfaces when you pass a general-purpose boundary type like `Map` through your system:

```java
// Bad: raw Map exposed everywhere
Map sensors = new HashMap();
Sensor s = (Sensor) sensors.get(sensorId);
```

Any code that receives this `Map` can call `clear()`, insert wrong types, or break when the `Map` API changes (as it did when Java 5 introduced generics). Encapsulate the boundary type in a class that exposes only what the application needs:

```java
public class Sensors {
    private Map sensors = new HashMap();

    public Sensor getById(String id) {
        return (Sensor) sensors.get(id);
    }
    // business rules here
}
```

The interface at the boundary is now hidden. The `Sensors` class enforces design and business rules, and clients are insulated from changes to the `Map` API. The advice is not to wrap every `Map`, but to avoid passing boundary interfaces across your public APIs.

## Exploring and Learning Boundaries

Learning a new third-party library is hard. Integrating it at the same time is doubly hard. A better approach is to write **learning tests** -- small, focused tests that call the third-party API the way you expect to use it in production. Jim Newkirk coined the term.

Learning tests are controlled experiments that check your understanding of the API. When exploring `log4j`, for example, you iterate through small tests, discovering that `ConsoleAppender` needs an output stream, that the default constructor is "unconfigured", and so on. The final result is an encoded understanding of the library:

```java
public class LogTest {
    private Logger logger;

    @Before
    public void initialize() {
        logger = Logger.getLogger("logger");
        logger.removeAllAppenders();
        Logger.getRootLogger().removeAllAppenders();
    }

    @Test
    public void basicLogger() {
        BasicConfigurator.configure();
        logger.info("basicLogger");
    }

    @Test
    public void addAppenderWithStream() {
        logger.addAppender(new ConsoleAppender(
            new PatternLayout("%p %t %m%n"),
            ConsoleAppender.SYSTEM_OUT));
        logger.info("addAppenderWithStream");
    }

    @Test
    public void addAppenderWithoutStream() {
        logger.addAppender(new ConsoleAppender(
            new PatternLayout("%p %t %m%n")));
        logger.info("addAppenderWithoutStream");
    }
}
```

## Learning Tests Are Better Than Free

Learning tests cost nothing: you had to learn the API anyway, and writing isolated tests is a more efficient and precise way to gain that knowledge. Moreover, learning tests have a **positive return on investment**:

- When a new version of the third-party package is released, re-run the learning tests to detect behavioural changes.
- They serve as living documentation of how the library is expected to behave.
- They reveal incompatibilities early, before they surface in production code.

Without boundary tests you may be tempted to stay with an old version of a library longer than necessary.

## Using Code That Does Not Yet Exist

Sometimes a boundary separates the known from the unknown: the API on the other side has not been designed yet. Rather than waiting, **define the interface you wish existed** and work against it:

```java
public interface Transmitter {
    void transmit(Frequency freq, DataStream stream);
}
```

Your `CommunicationsController` is written against this interface. When the real API is eventually delivered, you write a `TransmitterAdapter` that bridges the two:

```java
public class TransmitterAdapter implements Transmitter {
    private RealTransmitterAPI api;

    public void transmit(Frequency freq, DataStream stream) {
        // convert and delegate to the real API
    }
}
```

The Adapter encapsulates all interaction with the external API and provides a single place to change when it evolves. In the meantime, a `FakeTransmitter` can stand in for unit testing.

## Clean Boundaries

Change is what happens at boundaries. When you depend on code outside your control, protect your investment:

- Keep third-party types inside the class or close family of classes that use them.
- Avoid returning or accepting boundary types in public APIs.
- Wrap or adapt external APIs so only a few places in the codebase know about them.
- Support clean boundaries with outbound tests (learning tests) that verify your expectations of the third-party interface.

It is better to depend on something you control than on something you do not. If the external code changes in an incompatible way, you have one place to update -- the wrapper or adapter -- rather than dozens of scattered usages.

---

## Key Rules / Quick Reference

- Do not pass boundary types (e.g., `Map`) through your public API -- encapsulate them.
- Write learning tests to explore and document third-party API behaviour.
- Re-run learning tests when upgrading a dependency to catch breaking changes.
- When an API does not yet exist, define the interface you wish you had and use an Adapter later.
- Keep knowledge of third-party APIs restricted to as few places as possible.
- Support every boundary with tests that exercise the integration point.

## Summary

Third-party code provides power but introduces risk at every boundary. Manage boundaries by limiting how much of your code knows about them. Encapsulate boundary types, write learning tests to verify assumptions, and use Adapters to bridge your domain code from external APIs. A well-managed boundary is easy to change -- whether the third-party library evolves or your requirements do.