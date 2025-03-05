---
author: Xavier Salvador
title: 2.- Nombres con sentido
page_order: 02
date: 2025-02-10
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---
Meaningful names
------------------------------

Simple rules for creating good names
-----------------------------------------

Choosing good names takes time but saves more time than it takes.

The name of a variable, function or class should answer all the big questions: why it exists, what it does and how it is used.

As an example, if we want to be evoked of a date name by the specification of how it is being measured and the unit of that measurement we can user names like these:

int elapsedTimeInDays

int daysSinceCreation

We have to be sure that we acquire the "implicity" of the code: the degree to which the context is not explicit in the code itself.

About the "implicity" of the code of a variable as an example, we need to know the answers to questions as:

- What kinds of things are in variable x?

- What is the significcance of the value x?

- How would I use the x variable begin returned?


Avoid disinformation
----------------------

We have to avoid the usage of acronyms, abbreviations as well as the usage of general concepts like List or Map reserved in Java.

Better usage of plain nouns would better like accounts instead of accountGroup or bunchOfAccounts.

Spelling similar concepts similarly is "information". Using inconsistent spelling is "disinformation".

A truly awful example of disinformative names would be the use of lower-case L or uppercase O as variable names, especially in combination.

example code
int a = l;

if ( O == l )

     a = O1;

else

     l = 01;


Make Meaningful Distinctions
-----------------------------

We don't have to write code solely to satisfy a compiler or interpreter like creating klass variable because the name class was used for something else.

It is not sufficient to add number series or noise words, even though the compiler is satisfied. If names must be different, then they should also mean something different.

Number-series naming (a1, a2, .. aN) is the opposite of intentional naming. Such names are not disinformative—they are noninformative; they provide no clue to the author’s intention.

Noise words are another meaningless distinction and redundant.

Use Pronounceable names
----------------------------

Simple, make your names pronounceable.

User Searchable names
--------------------------

Avoid the usage of single letter names like a, e or o. Use instead longer names that makes easier to be searched.

Author's preference is that single-letter names can ONLY be used as local variables inside short methods.

The length of a name should correspond to the size of its scope.

If a variable or constant might be seen or used in multiple places in a body of code, it is imperative to give it a search-friendly name.

Avoid Encodings
-----------------

We have enough encodings to deal with without adding more to our burden. Encoding type or scope information into names simply adds an extra burden of deciphering. Encoded names are seldom pronounceable and are easy to mis-type.

Hungarian Notation
...................

Java programmers don’t need type encoding. Objects are strongly typed, and editing environments have advanced such that they detect a type error long before you can run a compile! So nowadays HN and other forms of type encoding are simply impediments. They make it harder to change the name or type of a variable, function, or class. They make it harder to read the code. And they create the possibility that the encoding system will mislead the reader.

Member prefixes
...............

Don't use anymore the prefix _m for member variables. It is also required to use an editing environment that hightlights or colorized members to make distinct.

Interfaces and Implementations
...............................

Don't use the afix I when declaring interfaces, just use the name of the interdace and that's all.

In addition to this, it is preferable to encode the implementation of the interface with names like ShapeFactoryImpl or CShapeFactory.


Avoid mental mapping
.....................

Readers shouldn’t have to mentally translate your names into other names they already know. This problem generally arises from a choice to use neither problem domain terms nor solution domain terms.

This is a problem with single-letter variable names. Certainly a loop counter may be named i or j or k (though never l!) if its scope is very small and no other names can conflict with it. This is because those single-letter names for loop counters are traditional. However, in most other contexts a single-letter name is a poor choice; it’s just a place holder that the reader must mentally map to the actual concept. There can be no worse reason for using the name c than because a and b were already taken.

One difference between a smart programmer and a professional programmer is that the professional understands that clarity is king. Professionals use their powers for good and write code that others can understand.