---
author: Xavier Salvador
title: 7.- Handling errors
page_order: 07
date: 2025-02-15
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

Here’s a professional software engineer-style résumé of Chapter 8: "Boundaries" from Clean Code by Robert C. Martin (with contributions from James Grenning). The summary is structured like a technical document, with embedded code and clear software engineering perspectives:

Résumé – Clean Code Chapter 8: Boundaries
📘 Key Principle:
When integrating third-party code or systems outside your control, isolate and encapsulate their usage to maintain clean, maintainable, and testable code.

🧱 Encapsulating Boundaries
🔹 Problem:
Third-party APIs (like Map, log4j, etc.) are often too flexible or unstable to be used directly across your system.
🔹 Anti-pattern:
Passing a raw Map everywhere in the application:
Map sensors = new HashMap();
Sensor s = (Sensor) sensors.get(sensorId);

Fragile: exposed to changes in Map API


Verbose: requires repeated casting


Easy to misuse (clear(), wrong types, etc.)


✅ Solution: Encapsulate the Map
public class Sensors {
private Map<String, Sensor> sensors = new HashMap<>();

    public Sensor getById(String id) {
        return sensors.get(id);
    }

    // Additional business rules here
}

✅ Benefits:
Implementation detail hidden


Easier to control and test


Protects from breaking changes (like when generics were introduced in Java 5)



🧪 Learning Tests
🎯 Goal:
Explore and understand unfamiliar third-party libraries through isolated tests.
📍 Example: Exploring log4j
@Test
public void testLogAddAppender() {
Logger logger = Logger.getLogger("MyLogger");
logger.removeAllAppenders();
logger.addAppender(new ConsoleAppender(
new PatternLayout("%p %t %m%n"),
ConsoleAppender.SYSTEM_OUT));
logger.info("hello");
}

🧠 Purpose:
Validate assumptions about API behavior


Document expected usage


Discover quirks early


🧪 Full Log Learning Test Example:
public class LogTest {
private Logger logger;

    @Before
    public void setup() {
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

🟢 Learning tests are “better than free”:
They document, test and help future-proof integrations.

🧩 Working With Unknown APIs
Scenario:
You’re waiting on another team or vendor to finalize an API.
🧱 Strategy:
Define the interface you wish existed


Use an Adapter later to integrate the real API


📐 Example: Defining a Transmitter Interface
public interface Transmitter {
void transmit(Frequency freq, DataStream stream);
}

Allows your system to evolve without waiting


Keeps your domain code readable and testable


➕ Adapter Once API Arrives:
public class TransmitterAdapter implements Transmitter {
private RealTransmitterAPI api;

    public void transmit(Frequency freq, DataStream stream) {
        // Convert and forward to the real API
    }
}

🧪 Fake Transmitters can be used for unit testing before the real API is even ready.

🛡️ Guidelines for Clean Boundaries
Encapsulate third-party APIs behind your own interfaces


Avoid spreading boundary code across the system


Write learning tests to understand unfamiliar libraries


Use adapters to isolate external APIs from internal logic


Don’t return or accept third-party types in public APIs



📈 Visual Summary
Encapsulation Diagram
+------------------------+
|      Your Code         |
|   (Domain Logic)       |
+-----------+------------+
|
v
+------------------------+
|  Custom Interface (e.g.|
|     Sensors, Logger)   |
+-----------+------------+
|
v
+------------------------+
| Third-Party API (Map,  |
| log4j, TransmitterAPI) |
+------------------------+


🔁 ROI of Clean Boundaries
Reduces future refactoring effort


Improves testability and code clarity


Encourages API-agnostic development


Shields your app from upstream instability



📚 References
[BeckTDD]: Test-Driven Development, Kent Beck


[GOF]: Design Patterns, Gamma et al. — Adapter Pattern


[WELC]: Working Effectively with Legacy Code, Michael Feathers



Would you like this in PDF format or integrated into a slide deck for team sharing?

