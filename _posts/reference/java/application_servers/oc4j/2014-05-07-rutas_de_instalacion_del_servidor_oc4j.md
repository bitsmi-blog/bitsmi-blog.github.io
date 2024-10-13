---
author: Xavsal
title: Rutas de instalación del servidor OC4J
date: 2014-05-07
categories: [ "references", "java", "application servers", "oc4j" ]
tags: [ "java", "oc4j" ]
layout: post
excerpt_separator: <!--more-->
---

Las rutas de instalación por defecto del servidor **OC4J** son las siguientes:

* En la ruta `OC4J_10g_TRUNK/j2ee/home/applications/<nombre_aplicación>/APP-INFlib/`, se pueden encontrar las librerías compartidas por todas las aplicaciones y que el servidor lo carga en su classpath.
* En la ruta `OC4J_10g_TRUNK/j2ee/home/applications/<nombre_aplicación>/`, ruta dónde se encuentra todas las aplicaciones desplegadas en el servidor.
* En la ruta `OC4J_10g_TRUNK/j2ee/home/application-deployments/`, se encuentra la CACHE de las aplicaciones (en generar se puede dejar vacía si quiere disponer más espacio libre).

