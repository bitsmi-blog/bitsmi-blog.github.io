---
author: Xavier Salvador
title: Quick reference - Oracle DML and DDL statements
date: 2015-05-28
categories: [ "references", "database", "oracle" ]
tags: [ "sql", "oracle" ]
layout: post
excerpt_separator: <!--more-->
---

Just a quick reference of DML and DDL Oracle Statements and some links to visit.

## DML Statements

Main Site: [Oracle DML Statements](http://docs.oracle.com/cd/E11882_01/appdev.112/e10766/tdddg_dml.htm#TDDDG99941)

**Insert**

```sql
INSERT INTO table_name (list_of_columns)
VALUES (list_of_values);
```

**Update**

```sql
UPDATE table_name
SET column_name = value [, column_name = value]…
[ WHERE condition ];
```

**Delete**

```sql
DELETE FROM table_name
[ WHERE condition ];
```

## DDL Statements

Main Site: [DDL Oracle Statements](https://docs.oracle.com/database/121/SQLRF/clauses.htm#SQLRF021)

**Create**

```sql
CREATE TABLE table_name
(
column1 datatype [ NULL | NOT NULL ],
column2 datatype [ NULL | NOT NULL ],
…
column_n datatype [ NULL | NOT NULL ] );
```

**Alter**

```sql
ALTER TABLE table_name
ADD column_name column-definition;
```

**Drop**

```sql
DROP [schema_name].TABLE table_name
[ CASCADE CONSTRAINTS ] [ PURGE ];
```

## Extra

Some sites which contains interesting information about the last topics: 

* <http://www.orafaq.com/faq/what_are_the_difference_between_ddl_dml_and_dcl_commands>
* <http://docs.oracle.com/cd/E11882_01/server.112/e41085/sqlqr01001.htm#SQLQR110>
* <http://www.techonthenet.com/oracle/index.php>
