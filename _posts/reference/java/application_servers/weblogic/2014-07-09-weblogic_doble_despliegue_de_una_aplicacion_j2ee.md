---
author: Xavier Salvador
title: Weblogic – Doble despliegue de una aplicación J2EE
date: 2014-07-09
categories: [ "references", "java", "application servers", "weblogic" ]
tags: [ "java", "weblogic" ]
layout: post
excerpt_separator: <!--more-->
---

Al trabajar con **Weblogic** y **Eclipse**, muchas veces da la impresión de que **las aplicaciones se despliegan dos veces**. 

- Una junto al arranque del servidor y, una vez éste está arrancada, vuelve a hacer el deploy correspondiente.
- Parece ser que el problema está en la carpeta tmp del server que no se borra durante los reinicios del servidor.

**NOTA:** Todos los cambios que se detallan a continuación han sido realizado en **Windows 8**.

Para solucionarlo se puede modificar el script de arranque de `startWebLogic.cmd` añadiendo la instrucción rd de MS-DOS para borrar la carpeta tmp antes de iniciar el servidor.

La modificación quedaria de este modo:

```
@ECHO OFF 
@REM WARNING: This file is created by the Configuration Wizard. 
@REM Any changes to this script may be lost when adding extensions to this configuration. 
SETLOCAL 
set DOMAIN_HOME=C:OracleMiddlewareuser_projectsdomainscomercio_domain 
@REM Borrar tmp 
rd /S /Q %DOMAIN_HOME%serversAdminServertmp 
call "%DOMAIN_HOME%binstartWebLogic.cmd" %* 
ENDLOCAL
```

La modificación del fichero de arranque se ha producido mediante el servidor **Bea Weblogic** en su versión **9.2 MP4**. 

**NOTA**: Se pueden aplicar dichos cambios también en los ficheros de arranque de Linux (extensión .sh) o de otros sistemas operativos. 
El principio de eliminación de la carpeta temporal sirve **independientemente de cuál sea el sistema operativo**.