---
author: Xavier Salvador
title: OCP7 12 – Conexión JDBC en Java 7
date: 2014-07-03
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

## Introducción

JDBC (**Java Database Connectivity**) es un acrónimo que identifica la API mediante la cuál las aplicaciones Java pueden conectarse a sistemas gestores de bases de datos (BBDD).
Esta conexión se obtiene por la utilización de interfícies de conexión llamadas **controladores JDBC** (o conocidos también como **drivers**).
Estas bases de datos acostumbran a ser en general relacionales, aunque también existen otros drivers para otros tipos de BBDD (nosql, ficheros planos, hojas de cálculo, etc).

<!--more-->

## API JDBC en Java 7 (Paquetes principales)

La API está compuesta por dos paquetes principales:

- (java.sql)[http://docs.oracle.com/javase/7/docs/api/java/sql/package-summary.html]
- (javax.sql)[http://docs.oracle.com/javase/7/docs/api/java/sql/package-summary.html]

Ambos están ya incluidos dentro del SDK estándar de Java cuándo se descarga en su versión 7.
En las (notas técnicas)[http://docs.oracle.com/javase/7/docs/technotes/guides/jdbc/] puede encontrarse información más detallada, este post pretende ser una introducción solamente.

## Uso de JDBC

El paquete `java.sql` consiste en ejecutar sentencias SQL de tipo consulta, aunque también permite leer y escribir datos  mediante operaciones de modificación realizando su conexión des de cualquier fuente de datos utilizando un formato tabular (en forma de tupla).

La URL del JDBC se construye mediante la plantilla siguiente:

```
jdbc : subprotocolo : subnombre
```

El esquema sobre la operación del controlador JDBC para ejecutar una sentencia SQL en Java:

![](/assets/posts/java/ocp-7/2014-07-03-ocp7_12_conexiones_jdbc_en_java7_fig1.png)

El algoritmo de ejecución detallado en la imagen anterior es el siguiente:

- Mediante el `DriverManager` se utiliza el método `getConnection(…)` para disponer de una conexión al SGBD.
- Si se ha realizado la conexión con el SGBD de forma correcta, se crea la consulta mediante la API del JDBC utilizando el método `createStatement(…)`.
Además en este paso se parametrizan los elementos que así lo requieran (valores adicionales en los elementos `WHERE`, posibles alias utilizados, etc)
- El último paso consiste en ejecutar la sentencia SQL y gestionar la tupla obtenida como resultado de su ejecución parametrizando la información según se requiera.

Por otro lado el paquete `javax.sql`,  proporciona una API en la capa del servidor para el acceso a la fuente de datos y procesado del lenguaje de programación Java. Incorpora los siguientes añadidos:

- La interfície de `DataSource` como una alternativa al `DriverManager` para establecer la conexión con una fuente de datos.
- _Pooling_ de conexiones y sentencias de SQL.
- Transacciones distribuidas.
- Conjuntos de filas.
- Aplicaciones para utilizar directamente las API's `DataSource` y `RowSet`, aunque las API’s del pooling de conexiones y de ls transacciones distribuidas se utilizan internamente por intermediarios.

Cuándo se cierran los recursos del JDBC una vez han sido utilizados se sigue el siguiente proceso:

![](/assets/posts/java/ocp-7/2014-07-03-ocp7_12_conexiones_jdbc_en_java7_fig2.png)

- El cierre de `Connection` cierra automáticamente todos los recursos.
- El cierre del objeto `ResultSet` debe realizarse explícitamente siempre que no se utilice dado que si se deja automáticamente sólo se cerrará cuándo sea analizado por el recolector de basura. Es una buena práctica siempre cerrarlo explícitamente.
- Por último siempre cerrar cualquier recurso externo que sea capaz de mantener activa la conexión del SGBD.

En Java 7 para cerrar correctamente todos los recursos JDBC debe utilizarse una herramienta introducida en llamada try-with-resources:

```java
try (Connection con = DriverManager.getConnection(url, username, password));
Statement stmt = con.createStatement();
ResultSet rs = stmt.executeQuery(query);
{
 // Using resources
}catch(Exception ex) {
}
```

Esto permite cerrar todos los recursos al final del bloque de código.
Si se produce alguna excepción el bloque `try` antes de ser capturada la excepción, en el bloque `catch` **se cierran los recursos en el orden inverso al utilizado**.
Para utilizar correctamente la herramienta `try-with-resources` entre los paréntesis que lo implementan debemos utilizar los objetos que implementen la interfaz `AutoCloseable`.

## Sql y JDBC

La API del JDBC:

- No restringe las sentencias que se pueden utilizar en una BBDD.
- No controla que las sentencias enviadas a la BBDD estén correctamente formuladas.
- Suministra tres clases y tres métodos respectivamente para el envío de sentencias SQL:

![](/assets/posts/java/ocp-7/2014-07-03-ocp7_12_conexiones_jdbc_en_java7_fig3.png)

- `Statement`: Utiliza el método de `createStatement` y incluye los métodos de `executeQuery` (para consultas) y `executeUpdate` (para operaciones de modificación).
- `PreparedStatement`: Se utiliza para enviar consultas SQL que tengan uno o más parámetros como argumentos de entrada. 
Cuenta con métodos propios que nos ayudan a dar valor a estos parámetros.   
Se muestra el siguiente código fuente como ejemplo:

```java
PreparedStatement ps = con.prepareStatement(
 "select * from OWNER where ID=? AND NAME=? AND CODE=?");
ps.setInt(1,id-employee);
ps.setString(2,name);
ps.setInt(3,code);
```

- `CallableStatement`:  Se usan para ejecutar procedimientos almacenados SQL (Stored Procedures). 
Éstos son un grupo de sentencias SQL que son llamados mediante un nombre. 
Un objeto `CallableStatement` hereda de `PreparedStatement` los métodos para el manejo de parámetros y además añade métodos para el manejo de estos parámetros.  
Se muestra el siguiente código fuente como ejemplo:

```java
String createProcedure = "create procedure SHOW_SUPPLIERS "
 + "as "+"select SUPPLIERS.SUP_NAME, COFFEES.COF_NAME "
 + "from SUPPLIERS, COFFEES "
 + "where SUPPLIERS.SUP_ID=COFFEES.SUP_ID "
 + "order by SUP_NAME";
CallableStatement cs = con.prepareCall("{call SHOW_SUPPLIERS}");
```

Toda acción que se realice sobre la BBDD de datos abrir/cerrar conexión, ejecutar una sentencia SQL, etc pueden lanzar una excepción del tipo `SQLException` que se deberá capturar o propagar.

Este error puede resultar crítico para la integridad de los datos de la BBDD: la clase `SQLException` hereda de `Iterable` lo que permite recorrer dicha cadena de fallos. 
Así es posible recorrer todos los objetos de tipo `Throwable` que haya en una excepción `SQLException`.

## Transacción

Mecanismo para manejar grupos de operaciones como si fueran una acción realizada de forma única.

Cada transacción debe tener las propiedades **ACID**:

- **Atomicidad** (Atomicity). Una operación se hace o se deshace por completo.
- **Consistencia** (Consistency). Transformación de un estado consistente a otro estado consistente.
- **Aislamiento** (Isolation). Cada transacción se produce con independencia de otras transacciones que se produzcan al mismo tiempo.
- **Permanencia** (Durability). Propiedad que hace que las transacciones realizadas sean definitivas.

Con JDBC se ejecuta un **COMMIT** automático  (**autoCOMMIT**) tras cada insert, update o delete (con excepción de si se trata de un procedimiento almacenado).

Para indicar que **una sentencia SQL no se ejecuta de forma automática** se utilizará el método `setAutommit(boolean);` de la interfaz `Connection` pasándole como parámetro el valor false.

De este modo se pueden agrupar varias sentencias SQL en una misma transacción siendo el programador el que gestiona el momento de realizar el **COMMIT** de la ejecución.

**ROLLBACK** permite deshacer las transacciones que se hayan ejecutado dejando la BBDD en un estado consistente.
Si se cierra la conexión sin hacer **COMMIT** o **ROLLBACK**, explícitamente se ejecuta un **COMMIT** automático aunque el **autoCOMMIT** esté asignado a `false`.

## Api RowSet

![](/assets/posts/java/ocp-7/2014-07-03-ocp7_12_conexiones_jdbc_en_java7_fig4.png)

Las **interfaces** que componen la API son las siguientes:
 
**CachedRowSet**

Permite obtener una conexión des de un `DataSource`, además de permitir la actualización y desplazamiento de datos sin necesidad de disponer de la conexión a BBDD abierta.

**FilterRowSet**

Deriva de `RowSet` y añade la posibilidad de aplicar criterios de filtros para hacer visible cierta porción de datos de un resultado global.

**JdbcRowSet**

Clase que engloba el funcionamiento básico de un ResultSet y añade capacidades de desplazamiento y actualización de datos.

**JoinRowSet**

Deriva de `WebRoseSet` y añade capacidades similares al JOIN de SQL pero sin necesidad de estar conectado a la fuente de datos.

**WebRowSet**

Deriva de `CachedRowSet` y añade funcionalidad para la lectura y escritura de documentos XML.

Las clases que componen la API son las siguientes:

**BaseRowSet**

Clase base abstracta que provee un objeto `RowSet` junto a su funcionalidad básica.

**RowSetMetadaImpl**

Clase que proporciona implementaciones para los métodos que establecen y recuperan información de los metadatos de las columnas del objecto RowSet.

Un objeto RowSetMetaDataImpl realiza un seguimiento del número de columnas del `RowSet` y mantiene un `Array` interno de los atributos de la columna para cada una de las columnas.

Un objeto `RowSet` crea internamente un objeto RowSetMetaDataImpl con el fin de establecer y recuperar información sobre sus columnas.

**RowSetProvider**

Se utiliza para crear un objeto RowSetFactory.  A su vez, `RowSetFactory` se utiliza para crear instancias de implementaciones de `RowSet` (que deriva de `ResultSet` 
y por lo tanto contiene todas las capacidades de ResultSet pero añadiendo nuevas funcionalidades).
