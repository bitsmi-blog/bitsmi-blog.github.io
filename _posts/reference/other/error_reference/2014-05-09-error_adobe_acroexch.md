---
author: Xavsal
title: Error Adobe AcroExch. al insertar un PDF en un documento de Word
date: 2014-05-09
categories: [ "references", "other", "error reference" ]
tags: [ "adobe" ]
layout: post
excerpt_separator: <!--more-->
---

Se dispone de un documento **PDF** de unos 2 Mb i es desea incrustar en un documento de **Word** estándar (independiente de versión de **Office**).

Al intentar realizar la incrustación se abre una ventana de alerta con el siguiente mensaje de error:

`El programa usado para crear este objetivo es AcroExch. Dicho programa no está instalada en el equipo o no responde. Para editar este Objeto, Instale AcroExch o asegúrese de que todos los cuadros de diálogo de AcroExch están cerrados.`

Es un problema relacionado con una opción de seguridad del **Adobe Acrobat Reader**. El programa por defecto dispuesta de la opción **Activar modo protegido al iniciar**. 
Así para solucionar el problema lo que hay que hacer es seguir los siguientes pasos:

- Abrir la **Adode PDF Reader** (múltiples versiones)
- Acceder a la opción **Editar**
- Acceder a la opción **Preferencias**
- Dependiendo de la versión del **Acrobat** puede ser la opción de General (**Adobe Acrobat X**) o la opción Seguridad (mejorada) (**Adobe Acrobat XI**). 
En otras versiones el nombre de la opción es el mismo, hay que buscarlo para encontrar el lugar donde aparezca.
- Hay que desactivar la opción **Activar modo protegido al iniciar**.

Ahora si se realiza de nuevo la inserción del documento **PDF** dentro del documento de **Word** no se volverá a mostrar el error y finalizará la incrustación correctamente.
