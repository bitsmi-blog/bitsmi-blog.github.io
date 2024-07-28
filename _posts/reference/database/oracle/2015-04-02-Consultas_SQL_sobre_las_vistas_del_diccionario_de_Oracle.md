---
author: xavsal
title: Consultas SQL sobre las vistas del diccionario de Oracle
date: 2015-04-02
categories: [ "references", "database", "oracle" ]
tags: [ "sql", "oracle" ]
layout: post
excerpt_separator: <!--more-->
---

Se añaden consultas para recuperar información sobre el diccionario de Oracle. La mayoría han funcionado correctamente para la versión **10.1.0.2.0** de **Oracle Database 10g release 1**. Su documentación se puede encontrar en este [enlace](http://www.oracle.com/technetwork/database/database10g/documentation/database10g-096307.html).

## Consulta Oracle SQL sobre la vista que muestra el estado de la base de datos

```sql
SELECT * FROM v$instance;
```

## Consulta Oracle SQL que muestra si la base de datos está abierta

```sql
SELECT status FROM v$instance;
```

## Consulta Oracle SQL sobre la vista que muestra los parámetros generales de Oracle

```sql
SELECT * FROM v$system_parameter;
```

## Consulta Oracle SQL para conocer la Versión de Oracle

```sql
SELECT value FROM v$system_parameter where name = ‘compatible’;
```

## Consulta Oracle SQL para conocer la Ubicación y nombre del fichero spfile

```sql
SELECT value FROM v$system_parameter where name = ‘spfile’
```

## Consulta Oracle SQL para conocer la Ubicación y número de ficheros de control

```sql
SELECT value FROM v$system_parameter where name = ‘control_files’;
```

## Consulta Oracle SQL para conocer el Nombre de la base de datos

```sql
SELECT value FROM v$system_parameter where name = ‘db_name’;
```

## Consulta Oracle SQL sobre la vista que muestra las conexiones actuales a Oracle. Para visualizarla es necesario entrar con privilegios de administrador

```sql
SELECT osuser, username, machine, program
FROM v$session
ORDER BY osuser;
```

## Consulta Oracle SQL para matar una sesión Oracle

```sql
SELECT sid, serial# FROM v$session where username='<usuario>’;
ALTER SYSTEM kill session ‘<sid, serial>’;
```

## Consulta Oracle SQL que muestra el número de conexiones actuales a Oracle agrupado por aplicación que realiza la conexión

```sql
SELECT program Aplicacion, count(program) Numero_Sesiones
FROM v$session
GROUP BY program
ORDER BY Numero_Sesiones desc;
```

## Consulta Oracle SQL que muestra los usuarios de Oracle conectados y el número de sesiones por usuario

```sql
SELECT username Usuario_Oracle, count(username) Numero_Sesiones
FROM v$session
GROUP BY username
ORDER BY Numero_Sesiones desc;
```

## Consulta Oracle SQL que muestra propietarios de objetos y número de objetos por propietario

```sql
SELECT owner, count(owner) Numero
FROM dba_objects
GROUP BY owner;
```

## Consulta Oracle SQL sobre el Diccionario de datos (incluye todas las vistas y tablas de la Base de Datos)

```sql
SELECT * FROM dictionary;
```

## Consulta Oracle SQL que muestra los datos de una tabla especificada

```sql
SELECT * FROM ALL_ALL_TABLES where upper(table_name) like ‘%<cadena_texto>%’;
```

## Consulta Oracle SQL que muestra las descripciones de los campos de una tabla especificada

```sql
SELECT * FROM ALL_COL_COMMENTS where upper(table_name) like ‘%<cadena_texto>%’;
```

## Consulta Oracle SQL para conocer las tablas propiedad del usuario actual

```sql
SELECT * FROM user_tables;
```

## Consulta Oracle SQL para conocer todos los objetos propiedad del usuario conectado a Oracle

```sql
SELECT * FROM user_catalog;
```

## Consulta Oracle SQL para el DBA de Oracle que muestra los tablespaces, el espacio utilizado, el espacio libre y los ficheros de datos de los mismos

```sql
SELECT t.tablespace_name «Tablespace», t.status «Estado»,
ROUND(MAX(d.bytes)/1024/1024,2) «MB Tamaño»,
ROUND((MAX(d.bytes)/1024/1024) –
(SUM(decode(f.bytes, NULL,0, f.bytes))/1024/1024),2) «MB Usados»,
ROUND(SUM(decode(f.bytes, NULL,0, f.bytes))/1024/1024,2) «MB Libres»,
t.pct_increase «% incremento»,
SUBSTR(d.file_name,1,80) «Fichero de datos»
FROM DBA_FREE_SPACE f, DBA_DATA_FILES d, DBA_TABLESPACES t
WHERE t.tablespace_name = d.tablespace_name AND
f.tablespace_name(+) = d.tablespace_name
AND f.file_id(+) = d.file_id GROUP BY t.tablespace_name,
d.file_name, t.pct_increase, t.status
ORDER BY 1,3 DESC;
```

## Consulta Oracle SQL para conocer los productos Oracle instalados y la versión

```sql
SELECT * FROM product_component_version;
```

## Consulta Oracle SQL para conocer los roles y privilegios por roles

```sql
SELECT * FROM role_sys_privs;
```

## Consulta Oracle SQL para conocer las reglas de integridad y columna a la que afectan

```sql
SELECT constraint_name, column_name FROM sys.all_cons_columns;
```

## Consulta Oracle SQL para conocer las tablas de las que es propietario un usuario

```sql
SELECT table_owner, table_name FROM sys.all_synonyms where table_owner like ‘<usuario>’;
```

### Variante: Consulta Oracle SQL más efectiva

```sql
SELECT DISTINCT TABLE_NAME
FROM ALL_ALL_TABLES
WHERE OWNER LIKE ‘HR’;
```

## Parámetros de Oracle, valor actual y su descripción

```sql
SELECT v.name, v.value value, decode(ISSYS_MODIFIABLE, ‘DEFERRED’,
‘TRUE’, ‘FALSE’) ISSYS_MODIFIABLE, decode(v.isDefault, ‘TRUE’, ‘YES’,
‘FALSE’, ‘NO’) «DEFAULT», DECODE(ISSES_MODIFIABLE, ‘IMMEDIATE’,
‘YES’,’FALSE’, ‘NO’, ‘DEFERRED’, ‘NO’, ‘YES’) SES_MODIFIABLE,
DECODE(ISSYS_MODIFIABLE, ‘IMMEDIATE’, ‘YES’, ‘FALSE’, ‘NO’,
‘DEFERRED’, ‘YES’,’YES’) SYS_MODIFIABLE , v.description
FROM V$PARAMETER v
WHERE name not like ‘nls%’ 
ORDER BY 1;
```

## Consulta Oracle SQL que muestra los usuarios de Oracle y datos suyos (fecha de creación, estado, id, nombre, tablespace temporal,…)

```sql
SELECT * FROM dba_users;
```

## Consulta Oracle SQL para conocer tablespaces y propietarios de los mismos

```sql
SELECT owner, decode(partition_name, null, segment_name,
segment_name || ‘:’ || partition_name) name,
segment_type, tablespace_name,bytes,initial_extent,
next_extent, PCT_INCREASE, extents, max_extents
FROM dba_segments
Where 1=1 AND extents > 1 
ORDER BY 9 desc, 3;
```

## Últimas consultas SQL ejecutadas en Oracle y usuario que las ejecutó

```sql
SELECT distinct 
vs.sql_text, vs.sharable_mem,
vs.persistent_mem, vs.runtime_mem, vs.sorts,
vs.executions, vs.parse_calls, vs.module,
vs.buffer_gets, vs.disk_reads, vs.version_count,
vs.users_opening, vs.loads,
to_char(to_date(
   vs.first_load_time, ‘YYYY-MM-DD/HH24:MI:SS’),’MM/DD HH24:MI:SS’) first_load_time,
rawtohex(vs.address) address, vs.hash_value hash_value ,
rows_processed , vs.command_type, vs.parsing_user_id ,
OPTIMIZER_MODE , au.USERNAME parseuser
FROM v$sqlarea vs , all_users au
where (parsing_user_id != 0) AND
(au.user_id(+)=vs.parsing_user_id)
AND (executions >= 1) ORDER BY buffer_gets/executions desc;
```

## Consulta Oracle SQL para conocer todos los tablespaces

```sql
SELECT * FROM V$TABLESPACE;
```

## Consulta Oracle SQL para conocer la memoria Share_Pool libre y usada

```sql
SELECT name, to_number(value) bytes
FROM v$parameter where name =’shared_pool_size’
union all
SELECT name,bytes
FROM v$sgastat where pool = ‘shared pool’ AND name = ‘free memory’;
```

## Cursores abiertos por usuario

```sql
SELECT b.sid, a.username, b.value Cursores_Abiertos
FROM v$session a,
v$sesstat b,
v$statname c
where c.name in (‘opened cursors current’)
AND b.statistic# = c.statistic#
AND a.sid = b.sid
AND a.username is not null
AND b.value >0
ORDER BY 3;
```

## Consulta Oracle SQL para conocer los aciertos de la caché (no debería superar el 1 por ciento)

```sql
SELECT sum(pins) Ejecuciones, sum(reloads) Fallos_cache,
trunc(sum(reloads)/sum(pins)*100,2) Porcentaje_aciertos
FROM v$librarycache
where namespace in (‘TABLE/PROCEDURE’, ‘SQL AREA’, ‘BODY’, ‘TRIGGER’);
```

## Sentencias SQL completas ejecutadas con un texto determinado en el SQL

```sql
SELECT c.sid, d.piece, c.serial#, c.username, d.sql_text
FROM v$session c, v$sqltext d
WHERE c.sql_hash_value = d.hash_value
AND upper(d.sql_text) like ‘%WHERE <nombre_campo> LIKE%’
ORDER BY c.sid, d.piece;
```

## Una sentencia SQL concreta (filtrado por sid)

```sql
SELECT c.sid, d.piece, c.serial#, c.username, d.sql_text
FROM v$session c, v$sqltext d
WHERE c.sql_hash_value = d.hash_value
AND sid = 105
ORDER BY c.sid, d.piece;
```

## Consulta Oracle SQL para conocer el tamaño ocupado por la base de datos

```sql
SELECT sum(BYTES)/1024/1024 MB FROM DBA_EXTENTS;
```

## Consulta Oracle SQL para conocer el tamaño de los ficheros de datos de la base de datos

```sql
SELECT sum(bytes)/1024/1024 MB FROM dba_data_files;
```

## Consulta Oracle SQL para conocer el tamaño ocupado por una tabla concreta sin incluir los índices de la misma

```sql
SELECT sum(bytes)/1024/1024 MB FROM user_segments
where segment_type=’TABLE’ AND segment_name='<nombre_tabla>’;
```

## Consulta Oracle SQL para conocer el tamaño ocupado por una tabla concreta incluyendo los índices de la misma

```sql
SELECT sum(bytes)/1024/1024 Table_Allocation_MB FROM user_segments
where segment_type in (‘TABLE’,’INDEX’) AND
(segment_name='<nombre_tabla>’ OR segment_name in
(SELECT index_name FROM user_indexes where table_name='<nombre_tabla>’));
```

## Consulta Oracle SQL para conocer el tamaño ocupado por una columna de una tabla

```sql
SELECT sum(vsize(‘<nombre_columna’))/1024/1024 MB 
FROM <nombre_tabla>;
```

## Consulta Oracle SQL para conocer el espacio ocupado por usuario

```sql
SELECT owner, SUM(BYTES)/1024/1024 MB FROM DBA_EXTENTS
GROUP BY owner;
```

## Consulta Oracle SQL para conocer el espacio ocupado por los diferentes segmentos (tablas, índices, undo, rollback, cluster, …)

```sql
SELECT SEGMENT_TYPE, SUM(BYTES)/1024/1024 MB FROM DBA_EXTENTS
GROUP BY SEGMENT_TYPE;
```

## Consulta Oracle SQL para obtener todas las funciones de Oracle: NVL, ABS, LTRIM, …

```sql
SELECT distinct object_name
FROM all_arguments
WHERE package_name = ‘STANDARD’
ORDER BY object_name;
```

## Consulta Oracle SQL para conocer el espacio ocupado por todos los objetos de la base de datos, muestra los objetos que más ocupan primero

```sql
SELECT SEGMENT_NAME, SUM(BYTES)/1024/1024 MB FROM DBA_EXTENTS
GROUP BY SEGMENT_NAME
ORDER BY 2 desc;
```

## Consulta Oracle SQL para recuperar los indices de una tabla específica

```sql
SELECT  index_name, index_type, table_owner, table_name, table_type
FROM user_indexes
WHERE table_name = ‘<nom_taula>’;
```

## Consulta Oracle SQL para obtener todas las tablas que utilizan un campo concreto

```sql
SELECT  table_name
FROM all_tab_columns
WHERE column_name = ‘<nom_columna>’;
```

### Variante sobre la consulta incluyendo el propietario y un tipo de dato específico:

```sql
SELECT  table_name
FROM all_tab_columns
WHERE column_name = ‘<nom_columna>’ and
data_type = ‘NVARCHAR2’    and
owner = «<schema_owner>
ORDER BY table_name;
```
