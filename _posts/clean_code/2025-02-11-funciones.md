---
author: Xavier Salvador
title: 3.- Functions
page_order: 03
date: 2025-02-11
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

Small
-------
Functions max up to 20 lines.
Always small.
They are the main line of organization in any program.

Blocks and Indenting
-------------------------
If, else, while statements up to one line long as a function call.

Following that approach together with the name of the function  we are also adding documentary value because the function called within the block can have a nicely descriptive name.

The indent level of a function should not be greater than one or two making the functions easier to read and understand.

Do one thing
---------------
Three main rules about functions which
- Should do one thing.
- Should do it well.
- Should do it only.

Question: How do we know what one thing is?

Technique
We can check if a function is doing more than "one thing" if we can extract another function from it without being a restatement.

Sections Within Functions
-------------------------------
Functions that do one thing cannot be reasonably divided into sections.

* One level of Abstraction per Function
  In order to make sure our functions are doing “one thing,” we need to make sure that the statements within our function are all at the same level of abstraction.

You can find several levels of abstraction: high, intermediate and low. Question here is that mixing levels of abstraction within a function is always confusing.

The hard exercise here consists in the action of distinguishing what is an essential concept and what is a detail. Once mixed, more and more details tend to accrete within the function, so we lose the "one thing" rule applied in the function.

Reading code from Top to Bottom: The Stepdown rule
----------------------------------------------------------------
Code must be read following the top-down narrative through  The Step-down rule:

We want every function to be followed by those at the next level of abstraction so that we can read the program, descending one level of abstraction at a time as we read down the list of functions.

It turns out to be very difficult for programmers to learn to follow this rule and write functions that stay at a single level of abstraction. But learning this trick is also very important. It is the key to keeping functions short and making sure they do “one thing.” Making the code read like a top-down set of TO paragraphs is an effective technique for keeping the abstraction level consistent.

Switch statements
----------------------
By their nature, switch statements always do N things.

We can't avoid the use of switch statements of course, but we can make sure that each statement is buried in a low-level class and is never repeated.
How? Through polymorphism.

As a general rule, we prefer polymorphism to switch/case through the “ONE SWITCH” rule.

There may be no more than one switch statement for a given type of selection. The cases in that switch statement must create polymorphic objects that take the place of other such switch statements in the rest of the system.

Example

Original function
public Money calculatePay(Employee e)
throws InvalidEmployeeType {
switch (e.type) {
case COMMISSIONED:
return calculateCommissionedPay(e);
case HOURLY:
return calculateHourlyPay(e);
case SALARIED:
return calculateSalariedPay(e);
default:
throw new InvalidEmployeeType(e.type);
}
}

Summary
There are several problems with this function.
- First, it’s large, and when new employee types are added, it will grow.
- Second, it very clearly does more than one thing.
- Third, it violates the Single Responsibility Principle (SRP) because there is more than one reason for it to change.
- Fourth, it violates the Open Closed Principle8 (OCP) because it must change whenever new types are added.

But possibly the worst problem with this function is that there are an unlimited number of other functions that will have the same structure depending on the employee type .
public abstract class Employee {
public abstract boolean isPayday();
public abstract Money calculatePay();
public abstract void deliverPay(Money pay);
}
   -----------------
public interface EmployeeFactory {
public Employee makeEmployee(EmployeeRecord r) throws InvalidEmployeeType;
}
   -----------------
public class EmployeeFactoryImpl implements EmployeeFactory {
public Employee makeEmployee(EmployeeRecord r) throws InvalidEmployeeType {
switch (r.type) {
case COMMISSIONED:
return new CommissionedEmployee(r) ;
case HOURLY:
return new HourlyEmployee(r);
case SALARIED:
return new SalariedEmploye(r);
default:
throw new InvalidEmployeeType(r.type);
}
}
}

The solution to this problem (see Listing 3-5) is to bury the switch statement in the basement of an ABSTRACT FACTORY,9 and never let anyone see it. The factory will use the switch statement to create appropriate instances of the derivatives of Employee, and the various functions, such as calculatePay, isPayday, and deliverPay, will be dispatched polymorphically through the Employee interface.

DONAR UNA VOLTA A AQUEST EXEMPLE

Use descriptive names
---------------------------
Names must describe what the function is doing.

Three main rules:
1.- Don’t be afraid to make a name long.
2.- Don’t be afraid to spend time choosing a name.
3.- Be consistent in your names. Use the same phrases, nouns, and verbs in the function names you choose for your modules

Function arguments
------------------------
The ideal number of arguments (ordinal)

0.- Niladic.
1.- Monadic.
2.- Dyadic.
3.- Triadic.
x.- Polyadic.

3 and x must never be used and they require a special justification to be used.

Arguments are hard so the best approach with them is to try to remove from them as much of conceptual power as we can.

It makes it easy to read the function and the arguments.

Arguments are even harders from a testing point of view. Main reason why is that it is very difficult to write all the test cases to ensure that all combinations of arguments are working properly. The more arguments we have, the more difficult it is to create the testing.

Common monadic forms
------------------------------
There are two very common reasons to pass a single argument into a function:
1.- You may be asking a question about that argument, as in a boolean method
2.- You may be operating on that argument, transforming it into something else and returning it.

Uncle Bob recommends choosing names that make the distinction clear, and always use the two forms in a consistent context.

Flag arguments
------------------
Passing flag arguments to a method is a bad practice. For example, booleans from the perspective of the One Thing Rule mentioned before are not fitting this rule because this function with the boolean as an argument is doing two things:
- One thing if the flag is true.
- Another thing if the flag is false.

Dyadic functions
---------------------
When we have two arguments in a method we tend to clearly see the first one, keeping its meaning without problems but when we try to read the second argument, we require a short pause until we learn to ignore the first argument.

Best approach to follow is to try to transform a Dyadic Function into a Monadic function.

Despite that, there are times where this function is needed in reality.

Example
Point p = new Point(0,0);
Cartesian points always have two points so this specific case fits in the use of a Dyadic function.

Triads
--------
These functions are harder than Dyadic. Main issues related to ordering, pausing, and ignoring are more than doubled.

As the Dyadic functions there is one specific case that can fit into this kind of functions -
Example
assertEquals(1.0, amount, .001).
It’s always good to be reminded that equality of floating point values is a relative thing.

Argument Objects
----------------------
Reducing the number of arguments by creating objects out of them may seem like cheating, but it’s not.

Argument Lists
------------------
Sometimes we want to pass a variable number of arguments into a function.

If the variable arguments are treated identically, they are equivalent to a single argument of type List. So this example is a Dyadic function

public String format(String format, Object... args);

Same approach can be followed for monad and triad functions like
void monad(Integer… args);
void dyad(String name, Integer… args);
void triad(String name, int count, Integer… args);
but adding more will be a huge mistake.

Have no side effects
------------------------
When we want a function to follow the One-Thing rule, we also want to avoid possible hidden things: doing two more calls to other methods or doing more things than the only expected one.

Output arguments
----------------------
Arguments are most naturally interpreted as inputs to a function.

In general, output arguments should be avoided. If your function must change the state of something, it has to change the state of its owning object.

Why? In the days before object oriented programming it was sometimes necessary to have output arguments. However, much of the need for output arguments disappears in OO languages because this is intended to act as an output argument.

Command Query Separation
----------------------------------
Functions should either do something or answer something but not the two actions at the same time.

Important point here is to remove ambiguity as much as we can.

Prefer Exceptions to  returning  error codes
---------------------------------------------------
Using exceptions instead of returned error codes, then the error processing code can be separated from the happy path code and can be simplified:
try {
deletePage(page);
registry.deleteReference(page.name);
configKeys.deleteKey(page.name.makeKey());
}
catch (Exception e) {
logger.log(e.getMessage());
}

Extract Try/Catch blocks
-----------------------------
The way to do that is to encapsulate the whole logic found inside the try in a private function, and use this reference explicitly inside the try.

Try and catch blocks they will only contain the reference of this new private function.

As an example from the last example (section Prefer Exceptions to  returning  error codes)
public void delete(Page page) {
try {
deletePageAndAllReferences(page);
}
catch (Exception e) {
logError(e);
}
}

private void deletePageAndAllReferences(Page page) throws Exception {
deletePage(page);
registry.deleteReference(page.name);
configKeys.deleteKey(page.name.makeKey());
}

private void logError(Exception e) {
logger.log(e.getMessage());
}

Error handling is also only one thing
--------------------------------------------
Error handling is only One Thing too so a function that handles errors should not do anything else.

The Error.java Dependency Magnet
-------------------------------------------
As a standard approach programmers tend to manage an enum containing the errorsthat are defined.
public enum Error {
OK,
INVALID,
NO_SUCH,
LOCKED,
OUT_OF_RESOURCES,
WAITING_FOR_EVENT;
}

These classes are called  "dependency magnet": the main reason why is because a lot of classes must use these errors.

If new errors appear, it is needed too to change the current enum so new deployments are required too.

When you use exceptions rather than error codes, then new exceptions are derivatives