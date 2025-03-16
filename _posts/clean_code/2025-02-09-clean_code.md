---
author: Xavier Salvador
title: 1.- Clean Code
page_order: 01
date: 2025-02-09
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

Anyone reading this book:
1. Is a programmer.
2. Is a programmer who wants to be a better programmer.

After reading this book:
1. We will be able to tell the differences between good code and bad code.
2. We will know how to write good code.
3. We will know how to transform bad code into good keeping its business requirements.

<!--more-->

## There will be code
Code represents the details of a requirement.

From a historical perspective, the discipline of requirements specification with well specified requirements are as formal as code and can act as a group of executable tests of that code.

## Bad code
Bad code can bring down a company.

**Wading**: Finding bad code written without being understood what is describing this code. 

If the team continues working on it but any clean approach is postponed with "We will review it later" it will never be achieved and the mess will continue to grow.

***Leblanc's Law: "Later equals never".***


## The total cost of owning a mess

**Mess** code is a natural process.

When a team is working in a code during the first years, any move in it is faster and smoother. 

Later, after some time, when trying to apply any change and trying to understand what several parts are doing, it gets more difficult to change, update or evolve the code. 

Then the **_Mess is built_**.

From this point, the team's productivity is declining to the **absolute zero** despite management tries to fix it by adding more staff who are not really aware of the inner meaning of the source code.

So as a conclusion, **_spending time_** keeping your code clean **is not only cost effective but professional survival** as a company as well as a professional programmer.

## Attitude
Despite the efforts of managers and marketers to always achieve the goals according to a narrow and specific schedule, it is part of our job to raise the hand and defend code quality with passion not only to avoid the creation of a "**mess**" short term but to get a better maintenance of the code long term.

## The Primal Conundrum
It has be understood as a **first amendment**:

**"To avoid the creation of a Mess and the only way to achieve any deadline according to a schedule is to keep the code as clean as possible at all times".**


## The Art of Clean Code
Writing clean code requires the disciplined use of myriad little techniques applied through the concept of **"cleanliness"** where the **"code-sense"** is the key.

A programmer with this **"code-sense"** will be able to confront the **"mess"** and choose the best variation preserving the transformation of the code from here to there ending in an elegantly coded system more readable and functionally working exactly as the original **mess**.



## Some quotes from famous programmers about clean code

### Bjarne Stroustrup, inventor of C++ and author of The C++ Programming Language
_I like my code to be elegant and efficient. The logic should be straightforward to make it hard for bugs to hide, the dependencies minimal to ease maintenance, error handling complete according to an articulated strategy, and performance close to optimal so as not to tempt people to make the code messy with unprincipled optimizations. Clean code does one thing well._


### Grady Booch, author of Object Oriented Analysis and Design with Applications
_Clean code is simple and direct. Clean code reads like well-written prose. Clean code never obscures the designer’s intent but rather is full of crisp abstractions and straightforward lines of control._


### “Big” Dave Thomas, founder of OTI, godfather of the Eclipse strategy
_Clean code can be read, and enhanced by a developer other than its original author. It has unit and acceptance tests. It has meaningful names. It provides one way rather than many ways for doing one thing. It has minimal dependencies, which are explicitly defined, and provides a clear and minimal API. Code should be literate since depending on the language, not all necessary information can be expressed clearly in code alone._

### Michael Feathers, author of Working Effectively with Legacy Code
_I could list all of the qualities that I notice in clean code, but there is one overarching quality that leads to all of them. Clean code always looks like it was written by someone who cares. 
There is nothing obvious that you can do to make it better. 
All of those things were thought about by the code’s author, and if you try to imagine improvements, you’re led back to where you are, sitting in appreciation of the code someone left for you—code left by someone who cares deeply about the craft._

### Ron Jeffries, author of Extreme Programming Installed and Extreme Programming Adventures in C#
_In recent years I begin, and nearly end, with Beck’s rules of simple code. In priority order, simple code:_
- _Runs all the tests;_
- _Contains no duplication;_
- _Expresses all the design ideas that are in the system;
- _Minimizes the number of entities such as classes, methods, functions, and the like._

_Of these, I focus mostly on duplication. When the same thing is done over and over, it’s a sign that there is an idea in our mind that is not well represented in the code. I try to figure out what it is. Then I try to express that idea more clearly._

_Expressiveness to me includes meaningful names, and I am likely to change the names of things several times before I settle in. With modern coding tools such as Eclipse, renaming is quite inexpensive, so it doesn’t trouble me to change. Expressiveness goes beyond names, however. I also look at whether an object or method is doing more than one thing. If it’s an object, it probably needs to be broken into two or more objects. If it’s a method, I will always use the Extract Method refactoring on it, resulting in one method that says more clearly what it does, and some submethods saying how it is done._

_Duplication and expressiveness take me a very long way into what I consider clean code, and improving dirty code with just these two things in mind can make a huge difference. There is, however, one other thing that I’m aware of doing, which is a bit harder to explain._

_After years of doing this work, it seems to me that all programs are made up of very similar elements. One example is “find things in a collection.” Whether we have a database of employee records, or a hash map of keys and values, or an array of items of some kind, we often find ourselves wanting a particular item from that collection. When I find that happening, I will often wrap the particular implementation in a more abstract method or class. That gives me a couple of interesting advantages._

_I can implement the functionality now with something simple, say a hash map, but since now all the references to that search are covered by my little abstraction, I can change the implementation any time I want. I can go forward quickly while preserving my ability to change later._

_In addition, the collection abstraction often calls my attention to what’s “really” going on, and keeps me from running down the path of implementing arbitrary collection behavior when all I really need is a few fairly simple ways of finding what I want._

_Reduced duplication, high expressiveness, and early building of simple abstractions. That’s what makes clean code for me._

### Ward Cunningham, inventor of Wiki, inventor of Fit, coinventor of eXtreme Programming. Motive force behind Design Patterns. Smalltalk and OO thought leader. The godfather of all those who care about code.
_You know you are working on clean code when each routine you read turns out to be pretty much what you expected. You can call it beautiful code when the code also makes it look like the language was made for the problem._

### Uncle Bob
Consider this book a description of the **_Object Mentor School of Clean Code_**. The techniques and teachings within are the way that we practice our art. We are willing to claim that if you follow these teachings, you will enjoy the benefits that we have enjoyed, and you will learn to write code that is clean and professional.

**The Boy Scout Rule**

It’s not enough to write the code well. The code has to be kept clean over time. We’ve all seen code degrade as time passes. So we must take an active role in preventing this degradation.

_Leave the campground cleaner than you found it._

**The Boy Scouts of America.**

As a conclusion for chapter 1, despite all the things shown inside the book, <u>there is only one way to achieve the goal of creating clean code: practice as hell.<u>


