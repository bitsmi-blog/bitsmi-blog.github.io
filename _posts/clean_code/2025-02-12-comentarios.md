---
author: Xavier Salvador
title: 4.- Comments
page_order: 04
date: 2025-02-11
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

Comments are not good by nature. They can be understood as a failure  because we haven't been good enough when writing the source code.

Comments are also dangerous because they are lying due to the fact that programmers do not maintain them.

They are also very dangerous when the comments are inaccurate.

Truth can only be found in one place: the code. Only the code can truly tell you what it does. It is the only source of truly accurate information.

Note: Comments can be useful in some exceptional cases.

Comments Do not make backup for code
------------------------------------------------
One of reasons why comments are written is because of the bad code.

Review the code and rewrite it again to try to be clear and expressive instead of using the comments to try to explain the bad code.

Explain yourself in code
----------------------------
Instead of adding comments to the code, simply create a function that says the same thing as the comment you want to write.

Good comments
--------------------
Some comments are necessary or beneficial.

- Legal comments
  Sometimes our corporate coding standards force us to write certain comments for legal reasons. For example, copyright and authorship statements are necessary and reasonable things to put into a comment at the start of each source file.

Where possible, refer to a standard license or other external document rather than putting all the terms and conditions into the comment.

- Informative comments
  It is sometimes useful to provide basic information with a comment.

```java
// format matched kk:mm:ss EEE, MMM dd, yyyy
   Pattern timeMatcher = Pattern.compile(“\\d*:\\d*:\\d* \\w*, \\w* \\d*, \\d*”);

In this case the comment lets us know that the regular expression is intended to match a time and date that were formatted with the SimpleDateFormat.format function using the specified format string.

- Explanation of Intent

Sometimes a comment goes beyond just useful information about the implementation and provides the intent behind a decision.

Example 1
``` java
public int compareTo(Object o)
   {
     if(o instanceof WikiPagePath)
     {
       WikiPagePath p = (WikiPagePath) o;
       String compressedName = StringUtil.join(names, “”);
       String compressedArgumentName = StringUtil.join(p.names, “”);
       return compressedName.compareTo(compressedArgumentName);
     }
     return 1; // we are greater because we are the right type.
   }

Example 2
``` java
public void testConcurrentAddWidgets() throws Exception {
     WidgetBuilder widgetBuilder =
       new WidgetBuilder(new Class[]{BoldWidget.class});
       String text = ”’’’bold text’’’”;
       ParentWidget parent =
         new BoldWidget(new MockWidgetRoot(), ”’’’bold text’’’”);
       AtomicBoolean failFlag = new AtomicBoolean();
       failFlag.set(false);
   
       //This is our best attempt to get a race condition
       //by creating large number of threads.
       for (int i = 0; i < 25000; i++) {
         WidgetBuilderThread widgetBuilderThread =
           new WidgetBuilderThread(widgetBuilder, text, parent, failFlag);
         Thread thread = new Thread(widgetBuilderThread);
         thread.start();
       }
       assertEquals(false, failFlag.get());
     }


- Clarification
Sometimes it is just helpful to translate the meaning of some obscure argument or return value into something that’s readable. In general it is better to find a way to make that argument or return value clear in its own right; but when its part of the standard library, or in code that you cannot alter, then a helpful clarifying comment can be useful.

``` java
public void testCompareTo() throws Exception
   {
     WikiPagePath a = PathParser.parse("PageA");
     WikiPagePath ab = PathParser.parse("PageA.PageB");
     WikiPagePath b = PathParser.parse("PageB");
     WikiPagePath aa = PathParser.parse("PageA.PageA");
     WikiPagePath bb = PathParser.parse("PageB.PageB");
     WikiPagePath ba = PathParser.parse("PageB.PageA");

     assertTrue(a.compareTo(a) == 0);    // a == a
     assertTrue(a.compareTo(b) != 0);    // a != b
     assertTrue(ab.compareTo(ab) == 0);  // ab == ab
     assertTrue(a.compareTo(b) == -1);   // a < b
     assertTrue(aa.compareTo(ab) == -1); // aa < ab
     assertTrue(ba.compareTo(bb) == -1); // ba < bb
     assertTrue(b.compareTo(a) == 1);    // b > a
     assertTrue(ab.compareTo(aa) == 1);  // ab > aa
     assertTrue(bb.compareTo(ba) == 1);  // bb > ba
   }

- Warning of consequences

Sometimes it is useful to warn other programmers about certain consequences
``` java
   // Don't run unless you
   // have some time to kill.
   public void _testWithReallyBigFile()
   {
     writeLinesToFile(10000000);
   
     response.setBody(testFile);
     response.readyToSend(this);
     String responseString = output.toString();
     assertSubString("Content-Length: 1000000000", responseString);
     assertTrue(bytesSent > 1000000000);
   }

Nowadays, of course, we’d turn off the test case by using the @Ignore attribute with an appropriate explanatory string. @Ignore(”Takes too long to run”).

- TODO Comments
It is sometimes reasonable to leave “To do” notes in the form of //TODO comments.

TODOs are jobs that the programmer thinks should be done, but for some reason can’t do at the moment.

Whatever else a TODO might be, it is not an excuse to leave bad code in the system.

-Amplification

A comment may be used to amplify the importance of something that may otherwise seem inconsequential.

```Java
String listItemContent = match.group(3).trim();
   // the trim is real important.  It removes the starting
   // spaces that could cause the item to be recognized
   // as another list.
   new ListItemWidget(this, listItemContent, this.level + 1);
   return buildList(text.substring(match.end()));

-Bad comments
Most comments fall into this category.

-Mumbling

Don't create comments if you don't pretend they are useful.  Be precise, concise and describe everything as well as you can.

-Redundant comments
These comments serve only to clutter and obscure the code. They serve no documentary purpose at all.
Example:
```java
   // Utility method that returns when this.closed is true. Throws an exception
   // if the timeout is reached.
   public synchronized void waitForClose(final long timeoutMillis)
   throws Exception
   {
      if(!closed)
      {
         wait(timeoutMillis);
         if(!closed)
           throw new Exception("MockResponseSender could not be closed");
      }
   }

-Misleading comments
Sometimes, with all the best intentions, a programmer makes a statement in his comments that isn’t precise enough to be accurate.

-Mandated comments
It is just plain silly to have a rule that says that every function must have a javadoc, or every variable must have a comment. Comments like this just clutter up the code, propagate lies, and lend to general confusion and disorganization.

''' Java
/**
    *
    * @param title The title of the CD
    * @param author The author of the CD
    * @param tracks The number of tracks on the CD
    * @param durationInMinutes The duration of the CD in minutes
    */
   public void addCD(String title, String author,
                      int tracks, int durationInMinutes) {
     CD cd = new CD();
     cd.title = title;
     cd.author = author;
     cd.tracks = tracks;
     cd.duration = duration;
     cdList.add(cd);
   }

Not useful in this case.

- Journal comments
Sometimes people add a comment to the start of a module every time they edit it. These comments accumulate as a kind of journal, or log, of every change that has ever been made. I have seen some modules with dozens of pages of these run-on journal entries.
Example
''' java
    * Changes (from 11-Oct-2001)
    * --------------------------
    * 11-Oct-2001 : Re-organised the class and moved it to new package
    *               com.jrefinery.date (DG);
    * 05-Nov-2001 : Added a getDescription() method, and eliminated NotableDate
    *               class (DG);
    * 12-Nov-2001 : IBD requires setDescription() method, now that NotableDate
    *               class is gone (DG);  Changed getPreviousDayOfWeek(),
    *               getFollowingDayOfWeek() and getNearestDayOfWeek() to correct
    *               bugs (DG);
    * 05-Dec-2001 : Fixed bug in SpreadsheetDate class (DG);
    * 29-May-2002 : Moved the month constants into a separate interface
    *               (MonthConstants) (DG);
    * 27-Aug-2002 : Fixed bug in addMonths() method, thanks to N???levka Petr (DG);
    * 03-Oct-2002 : Fixed errors reported by Checkstyle (DG);
    * 13-Mar-2003 : Implemented Serializable (DG);
    * 29-May-2003 : Fixed bug in addMonths method (DG);
    * 04-Sep-2003 : Implemented Comparable.  Updated the isInRange javadocs (DG);
    * 05-Jan-2005 : Fixed bug in addYears() method (1096282) (DG);

Nowadays, however, these long journals are just more clutter to obfuscate the module. They should be completely removed.

-Noise Comments

These comments restate the obvious and provide no new information about the code.

- Redundant/Obvious Comments

Comments like /** Default constructor. */ add no new information and quickly become noise.
- Frustration or “Venting” Comments

Instead of using comments to express frustration (e.g., // Give me a break!), the author suggests refactoring the code to remove the source of frustration.
- Commented-Out Code

Leaving chunks of code inside comments leads to confusion and clutter. Modern version control systems remember old changes, so simply remove unused code rather than commenting it out.
- Noisy or Misplaced Javadoc

Comments should focus on clarifying genuinely nonobvious details, not on repeating what the code already states, nor on containing large amounts of irrelevant or system-wide information.
- Better Alternatives to Comments

Use meaningful variable names, small well-named functions, and clearly structured logic. Often, what might have been explained in a comment can be expressed directly in the code.
- Position Markers and Closing-Brace Comments

Elaborate banners (// Actions //////////////////////////////////) and closing-brace labels (} // while) are generally unnecessary if functions are short and well-structured.
-Example of Poor vs. Improved Code

The text contrasts a “GeneratePrimes.java” example (filled with redundant comments and unclear structure) with a cleaner, refactored “PrimeGenerator.java.” The improved version shows how minimal, purposeful comments—alongside good naming and small functions—make the code more readable and maintainable.
