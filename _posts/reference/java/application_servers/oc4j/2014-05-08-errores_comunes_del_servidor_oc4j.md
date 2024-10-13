---
author: Xavsal
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