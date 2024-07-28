---
author: xavsal
title: Cálculo del tamaño de una BBDD Oracle
date: 2014-05-08
categories: [ "references", "database", "oracle" ]
tags: [ "sql", "oracle" ]
layout: post
excerpt_separator: <!--more-->
---

## Incluye el tamaño de los archivos de datos en la búsqueda

El tamaño total incluye tablas, campos, procedimientos almacenados y otros objetos de la base de datos.

Calcula el tamaño de la vista «dba_data_files»:

```sql
SELECT SUM(bytes)/1024/1024/1024 data_size FROM dba_data_files;
```
 

## Calcula el tamaño de los archivos temporales

Estos conservan datos durante el proceso pero no es un almacenamiento permanente.

Calcula el tamaño del archivo temporal:

```sql
SELECT NVL(SUM(bytes),0)/1024/1024/1024 temp_size FROM dba_temp_files;
```
 

## Obtener el tamaño del redo log

Esto almacena cualquier cambio en la base de datos antes de ser aplicado en los datos actuales de la base de datos.

Esto ofrece una manera de almacenar la base de datos en su estado orignal previo a una consulta diseñada para modificar cualquier información.

```sql
SELECT SUM(bytes)/1024/1024/1024 redo_size FROM sys.v_$log;
``` 

## Tamaño del archivo de control usado por Oracle utilizando la vista V$CONTROLFILE

Esta vista se utiliza para obtener información del esquema de la base de datos i de los objetos contenidos en la misma.

Para obtener el tamaño del archivo de control hace falta ejecutar:

```sql
SELECT SUM(BLOCK_SIZE*FILE_SIZE_BLKS)/1024/1024/1024 controlfile_size 
FROM v$controlfile;
```
 

## Combinar las anteriores consultas para obtener el tamaño de la base de datos

Resultado obtenido el tamaño total de la base de datos en gigabytes:

```sql
SELECT d.data_size, t.temp_size, r.redo_size
FROM  ( SELECT NVL(bytes)/1024/1024/1024 data_size FROM dba_data_files) d,
( SELECT NVL(sum(bytes),0)/1024/1024/1024 temp_size FROM dba_temp_files ) t,
( SELECT SUM(bytes)/1024/1024/1024 redo_size FROM sys.v_$log ) r;
```
