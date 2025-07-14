---
author: Xavier Salvador
title: 9.- Unit Testing
page_order: 09
date: 2025-02-17
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

📄 Résumé: Clean Code – Chapter 9: Unit Tests
🧠 Core Concepts
Principle
Summary
Tests are first-class citizens
Test code should be written with the same care and quality as production code.
TDD Cycle (Three Laws)
1. No production code before a failing test.2. No more test than needed to fail.3. No more code than needed to pass.
   Cleanliness matters
   Dirty tests become a liability, impede change, and ultimately get discarded—causing code rot.
   Tests enable design
   Clean tests give confidence to refactor, enabling maintainability and all the “-ilities”.
   Domain-Specific Testing Language
   Refactor test utility methods into expressive, readable abstractions.
   F.I.R.S.T.
   Tests should be Fast, Independent, Repeatable, Self-validating, and Timely.


🧪 Clean Test Characteristics
1. Readable Tests
   Bad:
   crawler.addPage(root, PathParser.parse("PageOne"));
   assertSubString("<name>PageOne</name>", response.getContent());

Refactored:
makePages("PageOne", "PageTwo");
submitRequest("root", "type:pages");
assertResponseContains("<name>PageOne</name>");

✅ Use helper methods (e.g., makePages(), submitRequest()) to hide irrelevant setup and clarify intent.

2. Build-Operate-Check (BOC) Pattern
   Structure each test in three distinct phases:
   // BUILD
   makePageWithContent("PageOne", "sample content");

// OPERATE
submitRequest("PageOne", "type:data");

// CHECK
assertResponseContains("sample content");


⚙️ Example: Refactored Test Suite
Refactored Test (from FitNesse):
@Test
public void testGetPageHierarchyAsXml() {
makePages("PageOne", "PageOne.ChildOne", "PageTwo");
submitRequest("root", "type:pages");
assertResponseIsXML();
assertResponseContains(
"<name>PageOne</name>",
"<name>PageTwo</name>",
"<name>ChildOne</name>"
);
}


🎯 Single Concept Per Test
Poor Practice:
public void testAddMonths() {
assertEquals(...); // Tests multiple concepts: 1, 2, 3 months later
}

Clean Practice:
@Test
public void testAddOneMonthToEndOfMay() {
assertEquals("2004-06-30", SerialDate.addMonths(1, d1).toString());
}

🔁 Break long tests into smaller, concept-focused ones.

🧬 Domain-Specific Testing Language
Transform verbose, imperative logic into a test DSL:
@Test
public void turnOnLoTempAlarmAtThreshold() {
wayTooCold();
assertEquals("HBchL", hw.getState());
}

Interpretation:
H: heater ON


B: blower ON


c: cooler OFF


h: hi-temp alarm OFF


L: lo-temp alarm ON


🔥 Advantage: Test reads like a specification.

🔁 One Assert per Test – Myth or Rule?
Guideline: Prefer one assert per test to enhance clarity.


Trade-off: Multiple asserts are OK if they test a single concept and are easily interpreted.


✅ Consider splitting with @Before or Template Method pattern if duplication becomes significant.



🔠 F.I.R.S.T. Principles
Letter
Principle
Meaning
F
Fast
Tests should run quickly to support frequent execution.
I
Independent
Tests must not rely on other tests’ results or state.
R
Repeatable
Tests should work in any environment without dependencies.
S
Self-validating
Clear pass/fail, no need for manual inspection.
T
Timely
Tests should be written just before the production code they validate.


📌 Key Takeaways
Clean unit tests are indispensable for high-quality, maintainable code.


Maintain readability, focus, and expressiveness in tests just as in production code.


Use abstraction to remove irrelevant setup and emphasize test intent.


Clean tests give developers freedom to refactor without fear.



🛠️ Visualization: BOC Pattern vs. Messy Test
Messy Test (Before Refactoring)
request.setResource("root");
request.addInput("type", "pages");
Responder responder = new SerializedPageResponder();
SimpleResponse response = responder.makeResponse(new FitNesseContext(root), request);
assertEquals("text/xml", response.getContentType());

Clean Test Structure
BUILD     → makePages("PageOne", "PageTwo")
OPERATE   → submitRequest("root", "type:pages")
CHECK     → assertResponseIsXML(), assertResponseContains(...)


✅ Code Snippet Summary
Helper for Test State (Readable State Checking)
public String getState() {
return (heater ? "H" : "h") +
(blower ? "B" : "b") +
(cooler ? "C" : "c") +
(hiTempAlarm ? "H" : "h") +
(loTempAlarm ? "L" : "l");
}


📚 Conclusion
Unit tests aren’t optional or secondary—they are equal partners in building clean, reliable, and evolvable software. Treat them with the same care. Refactor relentlessly. Let tests express your intent clearly and confidently.
“If you let the tests rot, then your code will rot too.” – Robert C. Martin

Let me know if you'd like this as a PDF/Markdown, or integrated into a code repository with working examples.

