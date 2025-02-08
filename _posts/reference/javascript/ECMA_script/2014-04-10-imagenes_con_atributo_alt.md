---
author: Xavier Salvador
title: Imágenes con atributos alt
date: 2014-04-10
categories: [ "references", "javascript", "ECMA-script" ]
tags: [ "javascript" ]
layout: post
excerpt_separator: <!--more-->
---

En desarrollos donde se emplee el tag ``img`` para que aparezca correctamente el mensaje al pasar por encima el ratón, será necesario añadir también el atributo `title`.

En el [siguiente enlace](http://www.computerhope.com/issues/ch001076.htm) se puede comprobar cómo funciona correctamente:

En la [documentación oficial del W3Schools](http://www.w3schools.com/tags/tag_img.asp) no aparece el atributo `title`. Todo parece indicar que es una especificación del IE10. No he sido capaz de encontrar un enlace donde oficialmente reste documentada esta implementación específica.

Sin embargo se confirma que si se utilizan los dos atributos (`alt` y `title`) conjuntamente se muestra correctamente el tip allí donde se haya aplicado y al pasar el ratón por encima aparece el mensaje de texto correctamente.