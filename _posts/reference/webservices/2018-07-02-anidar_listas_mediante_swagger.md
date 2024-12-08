---
author: Xavsal
title: Anidar listas de objetos de negocio en un modelo Json mediante Swagger
date: 2018-07-02
categories: [ "references", "webservices" ]
tags: [ "rest", "swagger" ]
layout: post
excerpt_separator: <!--more-->
---

## Implementación

Para poder anidar distintos objetos de negocio dentro del **Swagger**, el primer paso consiste en añadir éstos en la sección definitions del **Swagger**.

Aquí deben declararse todos los que se van a utilizar para crear la lista de objetos de tipo Element según el ejemplo que se ha desarrollado.

Una vez añadidas las definiciones se añade al Swagger el siguiente código:

```yaml
ElementList:  
    type: array
    description: Elements List.
    items:
      $ref: '#/definitions/Element'
```	  
         
`Type` indica a **Swagger** que el elemento contenido es de tipo array.
Description describe la lista de elementos de la lista.

```yaml
items:
    $ref: '#/definitions/Element'      
```	
	
Con esta sintaxis se indica a **Swagger** que cada elemento de la lista `ElementList` se corresponde con una definición de objeto de negocio cuya definición també aparecerá cuando **Swagger** 
muestre el modelo general.

Se pueden anidar varios niveles en la creación de un objeto complejo. 
En el caso de ejemplo que se describe en el apartado  siguiente se puede visualizar tres niveles: `ElementList -> Element`  que contiene a su vez  listas del tipo `Acces` e `Invoice`.

<!--more-->

## Ejemplo

Código de ejemplo:

```yaml
swagger: '2.0'
paths:
  '/MainEndpoint/{element}':
    get:
      summary: Getting information of the service.
      description: &gt;-
        Description of the swagger service.
      parameters:
        - name: element
          in: path
          required: true
          type: string
          description: Element Id separated by commas.
      responses:
        '200':
          description: Specific element.
          schema:
            properties:
              sources:
                type: array
                items:
                  $ref: '#/definitions/ElementList'
        default:
          description: Unexpected error
          schema:
            $ref: '#/definitions/Error'
      x-auth-type: None
      x-throttling-tier: Unlimited
  /MainEndpoint:
    get:
      summary: Get the whole elements.
      description: |
        Get all the elements available.
      responses:
        '200':
          description: All the elements
          schema:
            properties:
              sources:
                title: ElementList
                type: array
                items:
                  $ref: '#/definitions/ElementList'
        default:
          description: Unexpected error
          schema:
            $ref: '#/definitions/Error'         
      x-auth-type: None
      x-throttling-tier: Unlimited
definitions:
  Error:
    type: object
    properties:
      code:
        type: integer
        format: int32
      message:
        type: string
      fields:
        type: string  
  ElementList:  
    type: array
    description: Elements List.
    items:
      $ref: '#/definitions/Element'
  Element:
    type: object
    description: Element.
    properties: 
      elementCode:
        type: string
        example: 5000
      name: 
        type: string 
        example: Door
      address: 
        type: string 
        example: Jumper Street number 65
      elementaccess: 
        type: array
        description: Acces element.
        items:
          $ref: '#/definitions/Access'
      maxwidth: 
        type: integer
        format: int32
        example: 250
      maxheight: 
        type: integer
        format: int32
        example: 100
      saved: 
        type: boolean 
        example: 1
      informationpoint: 
        type: boolean      
        example: 0
      open: 
        type: string  
        example: 1
      close: 
        type: string 
        example: 1
      exterior: 
        type: boolean
        example: 0
      elevator: 
        type: boolean 
        example: 1
      elementinvoicelist: 
        type: array
        description: Element invoice.
        items:
          $ref: '#/definitions/Invoice'      
      argumentelement: 
        type: integer
        format: int32
        example: 30
  Invoice: 
      type: object
      properties: 
        invoicetype: 
          type: string
          example: Custom
        descinvoicetype: 
          type: string
          example: 7 days
        elementtype: 
          type: string
          example: ElementType
        amount: 
          type: number
          format: float
          example: 50,35
        minutes: 
          type: integer
          format: int32
          example: 15
  Access: 
      type: object
      properties: 
        accessid: 
          type: string
          example: 45
        accessaddress: 
          type: string
          example: Boeing Street number 126.
info:
  title: Endpoint Title
  version: v1
  description: &gt;-
    Description related with the endpoint
     
securityDefinitions:
  default:
    type: oauth2
    authorizationUrl: 'https://127.0.0.1:8080/authorize'
    flow: implicit
    scopes: {}
basePath: /Base/PathService/Element/v1
host: '127.0.01:8080'
schemes:
  - https
  - http    
```

## Enlaces utilizados
- [https://editor.swagger.io/](): Editor online de Swagger
- [http://docs.swagger.io/spec.html](): Swagger RESTful API Documentation Specification
- [https://jsonformatter.org/](): Formateador online para ficheros Json
- [https://roger13.github.io/SwagDefGen/](): Generador de definición de objetos Json
