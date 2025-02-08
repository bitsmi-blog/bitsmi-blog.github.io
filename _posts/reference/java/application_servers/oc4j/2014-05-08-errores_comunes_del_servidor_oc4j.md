---
author: Xavier Salvador
title: Errores comunes del servidor OC4J
date: 2014-05-08
categories: [ "references", "java", "application servers", "oc4j" ]
tags: [ "java", "oc4j" ]
layout: post
excerpt_separator: <!--more-->
---

## Errores JMS

A través de la consola de comandos se muestra un error como el siguiente:

```
2013-11-13 15:49:56.330 ERROR J2EE OJR-00011 Excepción al iniciar el servidor JMS: Error parsing jms-server config at file:/C:/PRO_MAVEN/OC4J_10g_TRUNK/j2ee/home/config/jms.xml: /C:/PRO_MAVEN/OC4J_10g_TRUNK/j2ee/home/config/jms.xml, Fatal error at line 27 offset 12 in file:/C:/PRO_MAVEN/OC4J_10g_TRUNK/j2ee/home/config/jms.xml: .<Line 27, Column 12>: XML-20211: (Error Fatal) No está permitido '--' en comments.
```

### Solución

* Parar el servidor de aplicaciones.
* Acceder a la ruta `<PATH>/j2ee/home/persistence/` de la instalación del servidor OC4J.
* Borrar el fichero `jms.state`.
* Reiniciar el servidor.

## Error ParserConfigurationException

A través de la consola de comandos se muestra un error como el siguiente:

```
ERROR [2013-12-03 15:18:55,759] [Digester] Digester.getParser:
javax.xml.parsers.ParserConfigurationException: XML document validation is not s
upported
at com.bluecast.xml.JAXPSAXParserFactory.newSAXParser(JAXPSAXParserFacto
ry.java:105)
at org.apache.commons.digester.Digester.getParser(Digester.java:686)
at org.apache.commons.digester.Digester.getXMLReader(Digester.java:902)
at org.apache.commons.digester.Digester.parse(Digester.java:1548)
at org.apache.struts.action.ActionServlet.parseModuleConfigFile(ActionServlet.java:1006)
```

### Solución

No se está utilizando una JDK compatible con el servidor. OC4J es compatible solamente con la JDK 1.4 y este es un error correspondiente al uso del servidor con una JDK superior.

## Error "Not in an application scope – start OC4J with the -userThreads switch if using user-created threads"

Este error se produce dentro de un proyecto J2EE que dispone de código fuente que genera hilos bajo demanda del programador. 
El servidor detecta dicha generación manual y muestra el mensaje de error dando una pista sobre cómo solucionar el problema de compatibilidad.

### Solución

En el caso concreto comentado es obligatorio utilizar el atributo `-userThreads` (**Enable context lookup support from user-created threads**) del servidor OC4J. 
Esto permite que el servidor sea capaz de gestionar además de los hilos internos propios también los creados manualmente por el usuario desde la aplicación J2EE.

Este parámetro debe indicarse en el Script de arranque del servidor (en caso de ejecutarse des de consola también debe añadirse como parámetro):

```sh
java -jar oc4j.jar -userthreads
```

### Referencias

- [Documentación Oficial](http://sqltech.cl/doc/oas10gR31/web.1013/b28950/sysprops.htm)
