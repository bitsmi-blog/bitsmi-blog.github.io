---
author: Antonio Archilla
title: SQL – Expresiones de Tablas Comunes (CTE)
date: 2016-08-14
categories: [ "references", "database", "sql" ]
tags: [ "sql" ]
layout: post
excerpt_separator: <!--more-->
---

Las **Expresiones de Tabla Común**, en inglés **Common Table Expressions (CTE)**, se pueden definir cómo la especificación de un conjunto de resultados temporales que se obtienen 
a través de una subconsulta determinada. El ámbito de aplicación de este conjunto de datos queda restringido a una ejecución concreta de la instrucción SQL 
en la que se encuentra definida (`SELECT`, `INSERT`, `UPDATE` o `DELETE`), momento a partir del cual, dichos resultados son eliminados del contexto de ejecución. 
Dicho de una manera un tanto simplista y haciendo un símil con conceptos aplicables a la programación imperativa, sería cómo la definición de una subrutina local, 
en el sentido que permite definir un *código*, en este caso una consulta que devuelve un conjunto de resultados determinados, asignarlo a un identificador determinado 
y usarlo cómo referencia dentro de otras partes de la consulta principal.

Algunas de las ventajas que proporciona su utilización son:

- Permite evitar la reevaluación de una subconsulta que se ejecute múltiples veces dentro de la consulta principal
- Simplifica la escritura y legibilidad de consultas complejas en las que se realicen definiciones de **tablas derivadas** 
(definidas dentro de la clausula `FROM` cómo una subconsulta) en uno o múltiples niveles
- Permite substituir la definición de vistas globales cuando sólo están restringidas a una sola consulta, 
ayudando a no *ensuciar* el espacio global de nombres con definiciones innecesarias
- Permite realizar operaciones de agrupación o condicionales sobre datos derivados de operaciones escalares o no deterministas. 
En este caso se podrá definir el cálculo de las operaciones requeridas dentro de la consulta CTE y posteriormente realizar las agrupaciones necesarias en la consulta principal o en otra CTE como si de valores de una tabla corriente se tratara

Aunque forma parte del estándard **SQL-99**, su implementación por parte de los motores de base de datos que soportan este estándar es opcional:

- **Oracle**: Soportado a partir de la versión 9i r2
- **MS SQL Server**: Soportado a partir de la versión 2008
- **PostgreSQL**: Soportado a partir de la versión 8.4
- **SQLLite**: Soportado a partir de la versión 3.8.3
- **IBM DB2**: Soportado
- **MySQL** y su derivada **MariaDB** no lo soportan aún

<!--more-->

## Sintaxis

Para la definición de las CTEs se sigue la sintaxis mostrada a continuación:

```sql
with <identificador CTE 1> as(
<query definición CTE 1>
)[, <identificador CTE 2> as(
<query definición CTE 2>
)…] select *
from <identificador CTE 1>, <identificador CTE 2>
```

Se usará la palabra reservada `WITH` para marcar el inicio de las definiciones de las **CTEs**. 
Invariablemente, este deberá ir delante de la sentencia `SELECT`, podiendo declarar varias de ellas a la vez utilizando una coma para separarlas. 
Cada definición de una **CTE** tiene asociado un identificador que servirá para referenciarla en la sentencia principal o bien dentro de otras **CTEs**. 
En este último caso, la definición de la **CTE** referenciada deberá realizarse con anterioridad a su utilización.

## Ejemplos

**Ejemplo básico de definición de una CTE usada múltiples veces en la consulta principal**:

```sql
WITH paises_europeos AS
(
    SELECT id_pais, desc_pais
    FROM pais
    WHERE pais.continente = 'Europa'
)
SELECT origen.desc_pais AS origen, destino.desc_pais  AS destino
FROM ruta_aerea, 
    INNER JOIN paises_europeos origen ON origen.id_pais = ruta_aerea.origen
    INNER JOIN paises_europeos destino ON destino.id_pais = ruta_aerea.destino
```

En este caso la definición de dicha **CTE** es muy simple, pero ayuda a ver cómo es posible aprovechar este mecanismo para simplificar las consultas y reutilizar código: 
En lugar de definir 2 tablas derivadas dentro de la consulta para los países **origen** y **destino** de las rutas aéreas, se utiliza una **CTE** `paises_europeos` que es referenciada 
en la consulta como origen y destino. Además, los motores de base de datos implementan mecanismos para optimizar el uso de estos recursos, 
obteniendo una única vez los datos del subconjunto definido en la **CTE** y reutilizándolos en los lugares donde es referenciada. 
En cualquier caso, este mecanismo permite encapsular consultas complejas cómo **CTEs** haciendo que la consulta principal quede simple y legíble.

**Uso de CTEs para poder aplicar condicionales sobre resultados escalares obtenidos de una subconsulta:**

```sql
WITH cte AS
(
    SELECT nombre_asignatura,
       (SELECT COUNT(*) FROM asignaturas_alumnos WHERE asignatura_id = A.id) AS numero_alumnos
    FROM asignaturas A
)
SELECT * 
FROM cte
WHERE numero_alumnos > 0
```

En este caso se suple la restricción de SQL para definir operaciones condicionales sobre el resultado de cálculos escalares que no es posible realizar con una sola consulta principal. 
Seria equivalente a la siguiente consulta **NO** válida:

```sql
SELECT nombre_asignatura,
       (SELECT COUNT(*) FROM asignaturas_alumnos WHERE asignatura_id = asignaturas.id) AS numero_alumnos
FROM asignaturas
WHERE numero_alumnos > 0
```

## Consultas recursivas

Asociado a la especificación de las **CTEs**, el estándar **SQL-99** define cómo característica opcional las **CTEs recursivas**. 
Este tipo de **CTE** puede ser usado en cualquier posición dentro de una sentencia SQL dónde estén permitidas las consultas.

La sintaxis en este caso difiere un poco de la utilizada en las **CTEs** normales:

```sql
with <identificador CTE>(col1[, col2, …, coln]) as(
— Valores iniciales
select col1[, col2, …, coln] from …
union
— Consulta recursiva
select col1[, col2, …, coln] from <identificador CTE>, …
)
select *
from <identificador CTE>
```

A continuación se muestra cómo ejemplo la típica implementación recursiva del cálculo de factoriales utilizando este mecanismo implementado sobre **Oracle**:

```sql
WITH factorial(n, f) 
AS(
  -- Valores iniciales
  SELECT 0, 1 
  FROM dual
  UNION ALL
  -- Subquery recursiva
  SELECT n+1, (n+1) * f 
  FROM factorial 
  WHERE n < 9
)
SELECT * FROM factorial;
```

Las expresiones recursivas también pueden ser útiles para recorrer relaciones definidas entre registros de una o diversas tablas que forman estructuras de grafos o árboles, 
aunque no proveen de estructuras especializadas cómo en el caso de Oracle con las construcciones `CONNECT BY` y las pseudocolumnas `IS_LEAF`, `LEVEL`, etc. que aportan información adicional. 
En el caso del uso de las **CTEs recursivas**, estas estructuras se deberán emular por código. 
Como ejemplo se expone la siguiente consulta implementada sobre **Oracle**, donde se desea recuperar los datos de los empleados de una empresa correspondientes a una jerarquía de mando determinada, 
junto con los datos del responsable inmediatamente superior y los del responsable de primer nivel (jefe):

| ID EMPLEADO | NOMBRE EMPLEADO | RESPONSABLE |
| ----------- | --------------- | ----------- |
| 1  | A. Urrutia               |             |
| 2  | B. Pou                   |             |
| 3  | C. Fernández             | 1           |
| 4  | D. Sánchez               | 2           |
| 5  | E. López                 | 3           |

**Consulta**:

```sql
WITH jerarquia(id_empleado, nombre_empleado, responsable, nombre_responsable, jefe, nombre_jefe)
AS(
    -- Valores iniciales. Corresponde a la selección del responsable
    SELECT empleados.id_empleado, empleados.nombre_empleado, 
        null AS responsable, null AS nombre_responsable, 
        empleados.id_empleado AS jefe, empleados.nombre_empleado AS nombre_jefe
    FROM empleados 
    WHERE id_empleado = 1
 
    UNION ALL
 
    -- Subconsulta recursiva para todos los emplados bajo la jerarquia del responsable
    SELECT empleados.id_empleado, empleados.nombre_empleado, 
        jerarquia.id_empleado AS responsable, jerarquia.nombre_empleado AS nombre_responsable, 
        jerarquia.jefe, jerarquia.nombre_jefe
    FROM empleados, jerarquia
    WHERE empleados.responsable = jerarquia.id_empleado
)
select id_empleado, nombre_empleado, responsable, nombre_responsable, jefe, nombre_jefe FROM jerarquia
```

Los puntos claves de la consulta son:

- En la definición de la **CTE** jerarquía (línea 1) se definen una serie de parámetros que serán los que retornará la **CTE**, 
tanto a la consulta principal como a las recursiones de la subconsulta (**linias 13 – 17**)
- Consulta de definición de los valores iniciales dentro de la **CTE** : Sirve para determinar los valores iniciales de la recursión , 
en este caso, los del responsable de primer nivel con `ID_EMPLEADO = 1` (**línea 8**)
- Dentro de las sucesivas recursiones, se accederá a los valores de los niveles superiores a través del identificador jerarquia. 
Los valores `jerarquia.id_empleado`, `jerarquia.nombre_empleado`, `jerarquia.responsable`, `jerarquia.nombre_responsable`, `jerarquia.jefe`, `jerarquia.nombre_jefe` 
contendrán los valores calculados para el responsable inmediatamente superior al que se está tratando en la recursión actual.
- El encadenamiento de los sucesivos niveles se realiza en la cláusula `WHERE` de la sentencia recursiva, donde se iguala el código de responsable del registro de la recursión 
actual con el código de empleado recuperado en para el registro superior, accesible mediante el identificado jerarquía (**línea 17**)
- Las columnas `JEFE` y `NOMBRE_JEFE` de la consulta recursiva siempre corresponderá a los valores `jerarquia.jefe` y `jerarquia.nombre_jefe` dado que se quiere devolver el valor calculado en la consulta de los valores iniciales.

Los resultados recuperados por la consulta serían:

| ID EMPLEADO | NOMBRE EMPLEADO | ID RESPONSABLE | NOMBRE RESPONSABLE | ID JEFE | NOMBRE JEFE |
| ----------- | --------------- | -------------- | ------------------ | ------- | ----------- |
| 1 | A. Urrutia |   |              | 1 | A. Urrutia
| 3 | D. Sánchez | 1 | A. Urrutia   | 1 | A. Urrutia
| 5 | E. López   | 3 | C. Fernández | 1 | A. Urrutia


## Consideraciones sobre el rendimiento

Normalmente las bases de datos gestionan las **CTEs** como si se tratara de vista, es decir, substituyendo las referencias hacia ellas por su definición. 
El proceso de optimización de la consulta resultante no obstante, difiere del motor de base de datos sobre el que se ejecute la consulta. 
Por ejemplo, mientras en la mayoría de motores la optimización se realiza sobre la consulta final, **PostgreSQL **realiza una optimización independiente para las consultas de definición de las **CTEs** 
lo que puede comportar un impacto significativo en el rendimiento en comparación con el uso de otras técnicas como las subsonsultas, que puede ser positivo o negativo según el caso.

En el caso concreto de **Oracle**, el optimizador evalúa el coste de las consultas definidas en cada **CTE** y cómo son utilizadas dentro de la consulta principal 
y actúa en consecuencia para optimizar la ejecución final. Si el número de resultados estimados es suficientemente grande y la **CTE** es referenciada múltiples veces dentro de la consulta principal, 
optará por crear una tabla física temporal con los resultados de dicha **CTE** que será evaluada como una tabla normal dentro de la consulta principal. 
De esta forma sólo se calcularan dichos resultados una única vez, mejorando el rendimiento global de la ejecución. 
En caso contrario, si el optimizador considera que la **CTE** no tiene el coste suficiente, sea por número de resultados esperados o por número de referencias, 
se evaluará cómo una vista _inline_ substituyendo cada ocurrencia de esta dentro de la consulta principal por su definición. 
Estas acciones se pueden también forzar a través de _hints_ `MATERILIZE` y `INLINE` respectivamente.

