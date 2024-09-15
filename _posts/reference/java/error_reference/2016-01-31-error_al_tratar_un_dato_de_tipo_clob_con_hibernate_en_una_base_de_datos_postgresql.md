---
author: Antonio Archilla
title: Error al tratar un dato de tipo CLOB con Hibernate en una base de datos PostgreSQL
date: 2016-01-31
categories: [ "references", "java", "error reference" ]
tags: [ "java", "hibernate", "postgresql" ]
layout: post
excerpt_separator: <!--more-->
---
## Descripción de error

Se produce un error al recuperar datos de tipo **LOB** de una entidad a través de la capa de persistencia basada en **JPA** + **Hibernate** si la base de datos subyacente es **PostgreSQL**. 
Se produce un error de tipo:

`org.postgresql.util.PSQLException: Bad value for type long`

<!--more-->

La configuración de los campos de una entidad incialmente es la siguiente:

```java
@Basic(fetch=FetchType.LAZY)
@Lob
protected String stringLargeValue;
```

<!--more-->

## Entorno

- **JDK**: 1.6. Es posible que ocurra también en versiones posteriores (No probado)
- **Framework de persistencia**: **JPA** con **Hibernate 3.6**. No se ha probado con la versión 4 ni posteriores.
- **Base de datos**: **PostgreSQL 9.2.4**, Es posible que ocurra también en versiones posteriores (No probado)

## Solución propuesta

Parece ser que hay una falta de entendimiento entre **Hibernate 3.6** y el driver de **PostgreSQL** porque lo que uno entiende como dato (**Hibernate**) 
el otro lo entiende como el puntero de tipo long para acceder a este (**PostgreSQL**) por lo que al hacer la extracción de datos este intenta hacer una conversión y provoca el error. 
Una posible solución se basa en configurar la propiedad de tipo **LOB** de la entidad con la anotación `@Type` de la siguiente manera para indicarle a Hibernate como debe tratar el valor recuperado:

```java
@Basic(fetch=FetchType.LAZY)
@Lob
@Type(type="org.hibernate.type.TextType")
protected String stringLargeValue;
```
