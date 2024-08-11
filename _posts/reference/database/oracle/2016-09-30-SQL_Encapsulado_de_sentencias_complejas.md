---
author: Antonio Archilla
title: SQL – Encapsulado de sentencias complejas
date: 2016-09-30
categories: [ "references", "database", "oracle" ]
tags: [ "sql", "oracle" ]
layout: post
excerpt_separator: <!--more-->
---

En muchas ocasiones el acceso a un conjunto de datos almacenado en base de datos requiere de una consulta especialmente compleja. En los casos en que se debe permitir acceso a sistemas externos a estos datos, la solución ideal pasa por implementar una capa de negocio intermedia entre la aplicación consumidora de la información y la base de datos, sea mediante servicios web, un data-grid u otra componente que permita abstraer la complejidad de la obtención de los datos para facilitarla al sistema externo.
Hay casos en que esto no es posible y por requerimientos de arquitectura en el sistema, las aplicaciones externas deben acceder directamente a la base de datos para obtener la información. En estos supuestos, es buena idea implementar una interfaz para la obtención de los datos, una API que permita crear una caja negra sobre la implementación real de la obtención de los datos. Con ello se consigue:
Las modificación de las estructuras subyacentes de la base de datos no afectan a la integración con el sistema externo al mantenerse la interfaz de obtención de datos.
Permite mantener el control de cómo se obtienen los datos, lo que minimiza la posibilidad de errores al estar centralizada en una única implementación.
Ante la aparición de errores, se minimiza el tiempo necesario para la corrección, ya que estaría localizada en un único punto: La implementación de la interfaz.
En este post se propone un posible mecanismo para construir estas interfaces de acceso aplicado a bases de datos Oracle.

<!--more-->

## Creación del tipo de datos para registro:

El uso de funciones PL/SQL para la ejecución de sentencias SQL hace necesario el uso de tipos (`TYPE`) que definan las estructuras de datos que se van a tratar. En caso que se recuperen valores sólo de una tabla, será posible definir variables dentro de los bloques PL/SQL asociados a dicha tabla mediante la sintaxis `<nombre variable> <nombre tabla>%ROWTYPE`. Si se quieren recuperar datos de múltiples fuentes o se utilizan datos agregados que no estén presentes en ninguna tabla, se pueden definir tipos de datos personalizados para tratar los valores recuperados por una consulta. Estos tipos pueden ser utilizados de la misma forma que los correspondientes a las filas / tablas dentro de los bloques PL/SQL para recuperar los datos que retornaran las funciones. La sintaxis para hacerlo es la siguiente:

```sql
CREATE OR REPLACE TYPE  AS OBJECT(
    <nombre columna> <tipo>,
    [ ,]
    . . .
);
```

Por ejemplo:

```sql
CREATE OR REPLACE TYPE data_rowtype AS OBJECT ( 
    owner_type         varchar2(5 char),
    owner_code         varchar2(255 char),
    registry_id        varchar2(255 char),
    registry_desc      varchar2(4000 char), 
    parent_id          varchar2(255 char),
    group_ind     varchar2(1 char),
    start_date         date,
    end_date           date
); 
```

Una vez definida la estructura de datos de los registros que manipulará la función **PL/SQL**, es necesario crear un nuevo tipo de dato relacionado que constituya la estructura de tabla donde se acumulen los valores recuperados. Se tratará de una especie de contenedor de registros que se utilizará como una especie de tabla. La sintaxis para hacerlo es la siguiente:

```sql
CREATE OR REPLACE TYPE <nombre tipo> AS TABLE OF <tipo estructura personalizada>; 
```

Para el ejemplo anterior, la declaración correspondiente sería la siguiente:

```sql
CREATE OR REPLACE TYPE data_tabletype AS TABLE OF data_rowtype;
```
 

## Implementación de las funciones:

Dentro de los bloques PL/SQL que conforman las funciones de la API es posible ejecutar consultas parametrizadas para poder recuperar valores. Si se quieren recuperar todos de golpe de forma síncrona antes de retornar de la ejecución de la función, se utilizará el mecanismo `BULK COLLECT`. En el siguiente ejemplo se puede observar cómo una consulta parametrizada utilizando este mecanismo:

```sql
FUNCTION findDataRegistryById(ownerType VARCHAR2,
  ownerCode VARCHAR2, 
  registryId VARCHAR2) return data_tabletype
AS
 query_str varchar2(4000 char);
 output_record data_tabletype := data_tabletype();
BEGIN
 query_str := <em>'select data_rowtype(owner_type, 
            owner_type, 
            owner_code, 
            registry_id, 
            registry_desc, 
            parent_id, 
            group_ind, 
            start_date date, 
            end_date date)
        )
        from table_values
        where owner_type=:ownerType
            and owner_code=:ownerCode
            and registry_id=:registryId'</em>;
      
 EXECUTE IMMEDIATE query_str
 BULK COLLECT INTO output_record 
 USING ownerType, ownerCode, registryId;    
   
 RETURN output_record;    
END findDataRegistryById;
```

Los puntos importantes de la implementación son los siguientes:

- La definición de la sentencia se realizará en un variable de tipo VARCHAR. La definición de los parámetros dentro de esta se hará mediante la sintaxis `:nombre_parametro`
- Los valores recuperados por la sentencia se encapsularán en un objeto del tipo asociado al `TYPE` definido cómo `AS TABLE OF` del retorno, en el ejemplo `data_rowtype` y `data_tabletype` respectivamente.
- La ejecución de la sentencia se realizará a través de las instrucción `EXECUTE IMMEDIATE`
- Al utilizar la instrucción `BULK COLLECT` se podrán especificar los parámetros para la ejecución de la sentencia especificándolos usando la cláusula `USING`. Se deberá especificar el mismo número de parámetros y en el mismo orden que en la definición de la consulta. En el ejemplo `ownerType`, `ownerCode` y `registryId`
- La función retornará un valor con el `TYPE` definido como `AS TABLE OF` asociado a la estructura de datos, en el ejemplo `data_tabletype`.

La técnica del `BULK COLLECT` presenta el inconveniente de bloquear la ejecución de la función hasta no haber recuperado todos los valores resultantes de la consulta. Esto la hace apropiada sólo para los casos en que el volumen de datos a recuperar es bajo. Oracle proporciona un mecanismo más eficiente para retornar grandes volúmenes de resultados: Las **pipelined functions**. Este tipo de funciones permite retornar los resultados obtenidos de forma incremental de forma asíncrona, haciendo que no sea necesario retornar el control de la ejecución desde el código que la ejecuta para empezar a procesar los resultados. Esto lo hace muy práctico para tratar grandes conjuntos de datos ya que proporciona un grado de paralelismo mayor. Un ejemplo de implementación de este mecanismo sería el siguiente:

```sql
FUNCTION findDataRegistries(ownerType VARCHAR2,
  ownerCode VARCHAR2, 
  registryId VARCHAR2) return data_tabletype
PIPELINED IS
 query_str varchar2(4000 char);
    TYPE record_cursor_type IS REF CURSOR;
    record_cursor record_cursor_type;
 output_record data_rowtype;
BEGIN
 query_str := <em>'select data_rowtype(owner_type, 
            owner_type, 
            owner_code, 
            registry_id, 
            registry_desc, 
            parent_id, 
            group_ind, 
            start_date date, 
            end_date date)
        )
        from table_values
        where owner_type=:ownerType
            and owner_code=:ownerCode'</em>;
      
    OPEN record_cursor FOR query_str USING ownerType, ownerCode;
    LOOP
        FETCH record_cursor INTO output_record;
        EXIT WHEN record_cursor%NOTFOUND;
        PIPE ROW(output_record);
    END LOOP;
    CLOSE record_cursor;
   
    RETURN;    
END findDataRegistries;
```

Los puntos importantes de la implementación son los siguientes:

- Se incluirá la palabra reservada `PIPELINED` en la definición de la función
- La definición de la sentencia se realizará en un variable de tipo `VARCHAR`. La definición de los parámetros dentro de esta se hará mediante la sintaxis `:nombre_parametro`
- Los valores recuperados por la sentencia se encapsularán en un objeto del tipo asociado al `TYPE` definido cómo `AS TABLE OF` del retorno, en el ejemplo `data_rowtype` y `data_tabletype` respectivamente.
- Se utilizará un bucle para recorrer un cursor con los datos recuperados y para cada iteración se ejecutará la instrucción `PIPE ROW` para retornar de forma asíncrona los datos recuperados (`output_record`).
- Al abrir el cursor se podrán especificar los parámetros para la ejecución de la sentencia especificándolos usando la cláusula `USING`. Se deberá especificar el mismo número de parámetros y en el mismo orden que en la definición de la consulta.
- Una vez concluido el bucle, esto es cuando se cumpla la condición `EXIT WHEN record_cursor%NOTFOUND` porque no haya mas datos en el cursor, este será cerrado.
- La función no retornará valor alguno dado que esta función se realiza mediante la llamada a `PIPE ROW`.

## Tratamiento de errores y excepciones:

El encapsulado de sentencias dentro de funciones **PL/SQL** permite hacer un tratamiento de los datos para controlar errores o el dominio de los valores permitidos para la ejecución de las sentencias. Utilizando el sistema excepciones de **PL/SQL** es posible tratar casos en los que las sentencias retornen valores incorrectos, como por ejemplo subconsultas agregadas que retornan mas de un valor, y poder actuar en consecuencia:

```sql
DECLARE
    . . .
BEGIN
    . . .
EXCEPTION
    WHEN TOO_MANY_ROWS THEN
        -- Tratar error cuando se retornen demasidos valores...        
        dbms_output.put_line(SQLCODE || ': ' || SQLERRM); -- Log
    WHEN OTHERS
        -- Tratar errores de otro tipo
        dbms_output.put_line(SQLCODE || ': ' || SQLERRM); -- Log
END;
```

Los puntos importantes de la implementación son los siguientes:

- Se utilizará el bloque `EXCEPTION` para tratar los errores.
- En este caso se captura de forma individual el error de tipo `TOO_MANY_ROWS`. La lista completa de errores se puede encontrar en el siguiente enlace
- El resto de errores se capturarán dentro del bloque `OTHERS`
- Dentro de los bloques de excepción se puede utilizar las variables `SQLCODE` y `SQLERRM` para obtener el código y mensaje de error que proporciona Oracle.

Oracle también permite utilizar su mecanismo de errores para definir validaciones dentro de las funciones, podiendo definir errores propios. Para ello se tendrá en cuenta que:

- El rango de códigos reservados para errores de usuario es -20000 … -20999
- Se utilizará la instrucción raise_application_exception para lanzar los errores. Esta función recibe 2 parámetros: código de error y mensaje asociado al error.

Un ejemplo de utilización de este mecanismo sería el siguiente:

```sql
FUNCTION findRegistryById(ownerType VARCHAR2,
  ownerCode VARCHAR2, 
  registryId VARCHAR2) return data_tabletype
 AS
  . . .
 BEGIN
  -- Validaciones
  IF ownerType is null THEN
   raise_application_error(-20001, 
                            'El tipo de propietario es obligatorio');
  ELSIF ownerType not in('REF', 'PROV') THEN
   raise_application_error(-20002, 
                            'El tipo de propietario no es válido');
  ELSIF registryId is null THEN
   raise_application_error(-20003, 
                            'El código del registro es obligatorio');
  END IF;
 
                . . .
 
END findRegistryById;
```

Los puntos importantes de la implementación son los siguientes:

- Se utiliza una estructura IF ELSE para validar los parámetros de entrada de la función
- En caso que un parámetro no sea correcto, se devolverá un error a través de la función raise_application_error
- El código del error devuelto se encuentra definido en el rango de errores de usuario que proporciona Oracle y siempre es un valor numérico negativo
 

## Implementación del Package de funciones:

**PL/SQL** permite agrupar de forma lógica objetos relacionados. Esto hace que sea posible crear una estructura des este tipo con todos los miembros de la API de funciones que puedan ser accedidos  través de un espacio de nombres único. Por ejemplo, las funciones implementadas en los apartados anteriores se podrían agrupar bajo el identificador dataRetrievalPkg para facilitar su acceso:

```sql
CREATE OR REPLACE PACKAGE BODY dataRetrievalPkg AS
 
FUNCTION findDataRegistryById(ownerType VARCHAR2, 
    ownerCode VARCHAR2, 
registryId VARCHAR2) return data_tabletype
BEGIN
    . . . 
END findDataRegistryById;
 
FUNCTION findAllDataRegistries(ownerType VARCHAR2, 
    ownerCode VARCHAR2) return data_tabletype
BEGIN
    . . .
END findAllDataRegistries;
 
END dataRetrievalPkg;
```

### Ejemplos de utilización

En los siguientes ejemplos se puede observar cómo mediante el uso de la función de Oracle `table()` en conjunción con la llamada a la función definida en los ejemplos anteriores, es posible tratar los valores calculados como registros de tablas corrientes e, incluso, realizar consultas dónde se mezclen los dos tipos de estructuras:

```sql
select data_owners.name, t.* 
from table(dataRetrievalPkg.findDataRegistryById('REF', null, 'ID00001')) t;
 
select t.* 
from table(dataRetrievalPkg.findAllDataRegistries('PROV', 'ID00001')) t,
    data_owners
where t.owner_type = data_owners.type
    and t.owner_code = data_owners.owner_code;
```	
	