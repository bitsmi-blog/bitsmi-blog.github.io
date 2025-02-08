---
author: Xavier Salvador
title: Método Unscape en Javascript
date: 2014-04-10
categories: [ "references", "javascript", "ECMA-script" ]
tags: [ "javascript" ]
layout: post
excerpt_separator: <!--more-->
---

En el proyecto actual en el que estoy trabajando, se ha creado una **URL** mediante la API de Java y se ha transmitido mediante una petición al navegador web.

Se ha producido un error en la transformación y su interpretación del navegador web de dicha **URL** dado que la cadena de texto obtenida por el navegador ha sido ésta:

`http://www.direccion.es/dominio?param1=valor1&param2=valor2`

Para solucionar el problema basta con utilizar el método `unescape` de **Javascript**.

<!--more-->

Mediante este método se trata la cadena de texto recibida por parámetro de forma literal con lo que se eliminan las codificaciones especiales de la cadena de texto.

Dentro del proyecto, se ha utilizado este método para interpretar los caracteres que conforman la **URL** literalmente y así poder utilizarla en el método window.open de **Javascript** correctamente.

El código **Javascript** queda del  siguiente modo:

```jsvascript
window.open(unescape(url), "popup2", "left=5,top=5,scrollbars=yes,resizable=yes,status=yes,width=" + (screen.availWidth - 20).toString() + ",height=" + (screen.availHeight - 100).toString());
```

Al hacer clic en el botón, se abre correctamente el *pop up* y se carga el contenido indicado por el enlace correctamente dado que el navegador puede interpretar la dirección web (**URL**) de forma literal y explícita.

A modo de resumen,  comentar que si desea que una cadena URL recibida por petición se trate correctamente debe emplearse el método unescape para ser tratada la cadena de forma literal.

## Referencias

- http://www.w3schools.com/jsref/jsref_unescape.asp