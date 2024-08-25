---
author: xavsal
title: Error de codificación Unicode en un mensaje Javascript
date: 2014-06-16
categories: [ "references", "javascript", "ECMA-script" ]
tags: [ "javascript" ]
layout: post
excerpt_separator: <!--more-->
---

## Descripción del Problema

Cuando se publica un mensaje que contiene un carácter en formato Unicode no muestra el texto correctamente. No se renderiza el carácter Unicode en Javascript sino que se muestra directamente la codificación

## Análisia del Problema

En el fichero JSP contenedor se encuentra la siguiente llamada:

```html
<a onclick="return(confirm('Mensaje de llamada previo al mu00E9todo?'));" 
	href="<ruta_web_navegacion>"
>
```

Cuando el navegador renderiza el botón y procesa la funcionalidad del atributo onclick no renderiza correctamente el texto contenido dentro de los confirm como carácter Unicode desde el Javascript, sino que lo interpreta como un string que forma parte de la cadena contenida dentro del confirm .

## Solución

Hay que añadir en el JSP una sección Javascript donde se implementa la siguiente función:

```html
<script>
function metodo() {
	return confirm("Mensaje de llamada previo al mu00E9todo?");
}
</script>
```

Esta nueva función renderiza directamente el texto contenido en el mensaje desde Javascript no desde HTML.

En el código HTML del enlace <a> hay que indicar en el atributo onclick el siguiente código para ejecutar correctamente la ventana confirm y posteriormente el envío del resultado al onclick del botón:      

```html
<a onclick="return(metodo());" 
	href="<ruta_web_navegacion>"
>
```

Esto permite que la codificación Unicode sea interpretada correctamente y se obtiene el carácter é lugar de la codificación ue00E9 cuando se muestra el mensaje por pantalla.

## Detalle

El método confirm devuelve el resultado de la opción elegida cuando se abre la ventana mediante Javascript.

Lo que se está haciendo se redirigir este regreso (sea true o false) hacia el botón onclick de manera que se ejecute directamente o no según la selección de las opciones del confirm Javascript que se haya efectuado.
