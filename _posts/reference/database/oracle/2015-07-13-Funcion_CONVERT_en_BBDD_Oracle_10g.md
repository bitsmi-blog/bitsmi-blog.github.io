---
author: Xavier Salvador
title: Función CONVERT en BBDD Oracle 10g
date: 2015-06-13
categories: [ "references", "database", "oracle" ]
tags: [ "sql", "oracle" ]
layout: post
excerpt_separator: <!--more-->
---

La función [CONVERT](http://docs.oracle.com/cd/B28359_01/server.111/b28286/functions027.htm#SQLRF00620) permite convertir un carácter de un conjunto específico de caracteres a otro carácter de otro conjunto específico de caracteres.

En el caso concreto de la aplicación en la que se está trabajando se desea realizar una consulta sobre una tabla concreta para recuperar una descripción que contenga la palabra `avión`, como caso de ejemplo. Las descripciones a recuperar son las siguientes

Auxiliares de vuelo y camareros de avión, barco y tren                         
Mecánicos y ajustadores de motores de avión
mediante la siguiente consulta

```sql
SELECT 
	des.des_dcol
FROM 
    TABLA_DESCRIPCIONES des
WHERE 
    UPPER(des.des_dcol) LIKE UPPER(‘%avión%’));
```			   

No encuentra ningún resultado dado que realiza la consulta estrictamente con acento y aunque existe en la tabla no lo retorna correctamente.

Aquí es dónde entra la utilización de la función `CONVERT`. La siguiente consulta busca las descripciones que contengan el valor `%avión%` mostrando el resultado correctamente.

```sql
SELECT 
    des.des_dcol
FROM 
    TABLA_DESCRIPCIONES des
WHERE 
    UPPER(CONVERT(des.des_dcol, ‘US7ASCII‘)) 
	LIKE UPPER(CONVERT(‘%avión%’, ‘US7ASCII‘));
```			   

Las descripciones recuperadas son las esperadas como se ha comentado con anterioridad.

- Auxiliares de vuelo y camareros de avión, barco y tren                         
- Mecánicos y ajustadores de motores de avión

La clave se encuentra en el parámetro que se le pasa, `US7ASCII`, correspondiente una de las codificaciones de caracteres comunes (**ASCII US 7-bit**) de las que puede gestionar la función..

Hasta aquí la prueba de concepto de esta función de **Oracle**. Para un mayor detalle de la misma se puede consultar en el [siguiente enlace](http://docs.oracle.com/cd/B28359_01/server.111/b28286/functions027.htm#SQLRF00620).
