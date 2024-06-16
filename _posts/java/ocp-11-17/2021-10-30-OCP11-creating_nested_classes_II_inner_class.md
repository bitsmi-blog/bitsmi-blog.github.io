---
author: xavsal
title: OCP11 - Creating nested classes (II) - Declaring an Inner Class
date: 2021-10-30
categories: [ "java", "ocp-11-17" ]
tags: [ "ocp-11", "ocp-17" ]
layout: post
excerpt_separator: <!--more-->
---

An **inner class**, also called a **member inner class**, is a **non‐ static** type **defined at the member level of a class** (the same level as the methods, instance variables, and constructors). Inner classes have the following properties:

- Can be declared public, protected, package‐private (default), or private
- Can extend any class and implement interfaces
- Can be marked abstract or final
- Cannot declare static fields or methods, except for static final fields
- Can access members of the outer class including private members. The last property is actually pretty cool. It means that the inner class can access variables in the outer class without doing anything special. 

Example - Ready for a complicated way to print Hi three times?
```java
1:  public class Outer {
2:     private String greeting = "Hi";
3:     
4:     protected class Inner {
5:        public int repeat = 3;
6:        public void go() {
7:           for (int i = 0; i < repeat; i++)
8:              System.out.println(greeting);
9:        }
10:    }
11:    
12:    public void callInner() {
13:       Inner inner = new Inner();
14:       inner.go();
15:    }
16:    public static void main(String[] args) {
17:       Outer outer = new Outer();
18:       outer.callInner();
19: } }
```
**Line 8** shows that the inner class just refers to **greeting** as if it were available. It works even though the variable is **private** being on the same class.

**Line 13** shows that an instance of the outer class can instantiate **Inner** normally. It works because **callInner()** is an instance method on **Outer**. Both **Inner** and **callInner()** are members of **Outer**.

<!--more-->

**Another way** to instantiate **Inner** a little bit odd but it works like in **line 13**. 
Example:
```java
20:    public static void main(String[] args) {
21:       Outer outer = new Outer();
22:       Inner inner = outer.new Inner(); // create the inner class
23:       inner.go();
24:    }
```
**Line 22**. We need an instance of **Outer** to create **Inner**. We can't just call **new Inner** because Java won't know with which instance of **Outer** it is associated. Java solves thiss issue by calling new as if it were a method on the outer variable.

Inner classes can have the same variable name as outeer classes, making scope a little tricky. It exists a special way of calling **this** to say which variable you want to access. **It would be seen in the exam** but not in the real world.

Example - How to nest multiple classes and access a variable with the same name in each:
```java
1:  public class A {
2:     private int x = 10;
3:     class B {
4:        private int x = 20;
5:        class C {
6:           private int x = 30;
7:           public void allTheX() {
8:              System.out.println(x);        // 30
9:              System.out.println(this.x);   // 30
10:             System.out.println(B.this.x); // 20
11:             System.out.println(A.this.x); // 10
12:    } } }
13:    public static void main(String[] args) {
14:       A a = new A();
15:       A.B b = a.new B();
16:       A.B.C c = b.new C();
17:       c.allTheX();
18: }}
```
This code contains two nested classes. 
**Line 8,9** are the type of code that we are used to seeing. They refer to instance variable on the current class - declared on **line 6**.
**Line 10** uses **this** a special way. We an explcitly the instance variable which can be found on the **B** class -  being a variable on **line 4**.
**Line 11** does the same thing for class A, getting the variable from **line 2**.
**Line 14** instantiates the outermost one.
**Line 15** uses the awkward sytanx to instantiate a B. Notice the type is **A.B**. We could have written **B** as the type because that is avaialbel at the member level of B. Java knows where to look for it.
**Line 16** We instantiate a **C**. The **A.B.C** type is necessary to specify. **C** is too deep for java to know where too look.
**Line 17** calls a method in **C**.

## Inner Classes require an Instance

```java
  public class Fox {
       private class Den {}
       public void goHome() {
          new Den();
       }
       public static void visitFriend() {
          new Den();  // DOES NOT COMPILE
       }
    }
 
    public class Squirrel {
       public void visitFox() {
          new Den();  // DOES NOT COMPILE
       }
    }
```
The **first** constructor call compiles because **goHome()** is an instance method, and therefore the call is associated with the this instance. The **second** call does not compile because it is called inside a static method. You can still call the constructor, but you have to explicitly give it a reference to a **Fox** instance.

The **last** constructor call does not compile for **two reasons**. Even though it is an instance method, it is not an instance method inside the **Fox** class. Adding a **Fox** reference would not fix the problem entirely though. **Den** is private and not accessible in the **Squirrel** class.
