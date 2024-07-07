---
author: Antonio Archilla
title: CRLF end of line problems in Git
date: 2020-04-20
categories: [ "references", "scm", "scripts and utilities" ]
tags: [ "git" ]
layout: post
excerpt_separator: <!--more-->
---

Sometimes a new problem could appear regarding the end of line on files using an IDE (like IntelliJ for example) when doing a **Commit&Push** into **Master** through **Git**.

When this situation happens a new window may popup:

![IntelliJ Line Separators Warning](/assets/posts/reference/scm/scripts_and_utilities/CRLF_end_of_line_problems_in_Git_fig1.png)

It is recommended the use of the option "*commit as it is*" by default.

Be sure to uncheck the setting '*Warn if CRLF line separators are about to be commited to avoid the warning popup*' in case of using the *IntelliJ IDE*.

![](/assets/posts/reference/scm/scripts_and_utilities/CRLF_end_of_line_problems_in_Git_fig2.png)

To prevent git from automatically changing the line endings on your files in general is enough running this command:
```properties
git config --global core.autocrlf false
```

BUt a general solution that force one customized configuration is the creation of a new file in the root folder of the project called **.gitattributes**.

This is its content:
```properties
* text eol=crlf working-tree-encoding=UTF-8
*.java text eol=crlf working-tree-encoding=UTF-8
*.xml text eol=crlf working-tree-encoding=UTF-8
*.properties text eol=crlf working-tree-encoding=UTF-8
*.jsp text eol=crlf working-tree-encoding=UTF-8
*.sql text eol=crlf working-tree-encoding=UTF-8
```

It's important to point out that this configuration can be changed and adapted to a different one depending on the necessities of the project.

### More references

1. Git documentation [here](https://www.git-scm.com/docs/gitattributes "here")

2. Git attributes depending on the programming language can be found [here](https://github.com/alexkaratarakis/gitattributes "here").
