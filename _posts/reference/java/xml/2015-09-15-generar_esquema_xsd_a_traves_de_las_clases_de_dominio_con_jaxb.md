---
author: Antonio Archilla
title: Generar esquema XSD a través de las clases de dominio con JAXB
date: 2015-09-15
categories: [ "references", "java", "xml" ]
tags: [ "java", "jaxb" ]
layout: post
excerpt_separator: <!--more-->
---

Una operación muy habitual cuando se trabaja con JAXB para generar XML a partir de clases de dominio mediante anotaciones de JAXB es la de generar el esquema XSD 
asociado a la estructura de datos de dicho XML. Este esquema puede ser utilizado posteriormente para volver a generar las clases de dominio a través de JAXB. 
Se trata de una operativa muy común cuando se trabaja con servicios web REST para exponer la estructura de los mensajes de respuesta desde el servidor a los clientes 
para que estos puedan interpretarla, por ejemplo. 

Una manera muy sencilla de generar esta definición XSD cuando ya se tienen modeladas las clases de dominio a partir de las que se creará el XML mediante JAXB es 
utilizando el método `generateSchema` del contexto JAXB al que se han especificado las clases de dominio que forman el mensaje XML.

<!--more-->

En el siguiente extracto de código se escribe en un fichero el XSD generado. Para ello se tiene que definir una nueva implementación de la clase `SchemaOutputResolver`
para decirle a JAXB dónde tiene que poner el resultado del XSD, en este caso el fichero que se especifica dentro de dicha implementación:

```java
/* Especificamos la clase raiz del contexto de JAXB. Mediante las anotaciones de JAXB se relacionará sus valores 
 * con el resto de clases que conforman la estructura de datos
 */
JAXBContext jaxbContext = JAXBContext.newInstance(DomainEntity.class);
jaxbContext.generateSchema(new SchemaOutputResolver() 
{
    @Override
    public Result createOutput(String namespaceUri, String suggestedFileName) throws IOException 
    {
        // Especificamos la ruta del fichero resultante
        File file = new File("/tmp/schema.xsd");
        // Se guarda el resultado en el fichero de disco especificado
        StreamResult result = new StreamResult(file);
        // Es necesario especificar una ID única para el resultado. En este caso, la URL del fichero generado
        result.setSystemId(file.toURI().toURL().toString());
        return result;
    }
});
```

También es posible utilizar un objeto de tipo `StringWriter` para obtener el resultado directamente en forma de `String` y, por ejemplo, 
retornarlo a través de la respuesta HTTP en caso de estar sirviendo una petición para conocer el esquema.

```java
/* Especificamos la clase raiz del contexto de JAXB. Mediante las anotaciones de JAXB se relacionará sus valores 
 * con el resto de clases que conforman la estructura de datos
 */
JAXBContext jaxbContext = JAXBContext.newInstance(DomainEntity.class);
StringWriter writer = new StringWriter();
jaxbContext.generateSchema(new SchemaOutputResolver() 
{
    @Override
    public Result createOutput(String namespaceUri, String suggestedFileName) throws IOException 
    {
        // Se guarda el resultado escribiendolo como una cadena de texto
        StreamResult result = new StreamResult(writer);
        // Es necesario especificar una ID única para el resultado. En este caso, se genera aleatoriamente para el ejemplo
        result.setSystemId(UUID.randomUUID().toString());
        return result;
    }
 
    // Se recoge el resultado para poder utilizarlo a continuación
    String schema = writer.toString();
});
```
