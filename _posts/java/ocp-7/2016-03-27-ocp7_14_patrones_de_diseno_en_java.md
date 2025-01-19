---
author: Xavsal
title: OCP7 14 – Patrones de dseño en Java (Singleton, Factory y DAO)
date: 2016-03-27
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

<!--more-->

Los [patrones de diseño](https://es.wikipedia.org/wiki/Patr%C3%B3n_de_dise%C3%B1o) consisten en soluciones reutilizables a problemas comunes en el desarrollo de software.

Estas soluciones se encuentran ampliamente documentadas y pretenden formalizar el vocabulario usado para hablar del diseño de software.

## Patrón Singleton

Persigue el objetivo de mejorar el rendimiento de una aplicación **impidiendo la creación de varias instancias de una clase**.
Para la implementación de este patrón se utilizará una clase con una **variable de referencia estática**:

```java
ublic class SingletonClass {
     
    private static final SingletonClass instance = new SingletonClass();
     
    private SingletonClass() {}
     
    public static SingletonClass getInstance() {
        return instance;
    }
}
```

La cual contendrá la única instancia de la clase. También se **marca esta variable como final para que no pueda ser reasignada  una instancia diferente**.

Se añade un constructor privado `private SingletonClass() {}` de modo que sólo se permita el acceso a él des de la misma clase impidiendo cualquier intento de instanciarla de nuevo.

Por último se añade un método **público** y **estático** el cuál podrá acceder al campo estático y devolver su valor.

```java
public static SingletonClass getInstance() {
  return instance; 
}
```

Mediante este método se puede recuperar la instacia creada cuándo sea requerido el objeto que implementa la clase Singleton.

## Patrón Dao (Data-Acces-Object)

Es un [patrón de diseño](https://es.wikipedia.org/wiki/Data_Access_Object) ampliamente conocido que separa la lógica de negocio de la persistencia de los datos.
Permite una mayor facilidad de implementación del código y una mayor sencillez de mantenimiento del mismo. A su vez es más escalable y ampliable.

## Patrón Factory

Patrón de diseño que **separa la clase que crea los objetos de la jerarquía de los objetos a instanciar** dentro del espacio de memoria

Los objetivos intenta conseguir consisten en:

- Una centralización de la creación de los objetos en memoria.
– Escalabilidad del Sistema.
– Abstracción del usuario sobre la instancia a crear.

Un ejemplo de implementación del patrón Factoria es el siguiente:

```java
EmployeeDAOFactory factory = new EmployeeDAOFactory();
 
EmployeeDAOFactory dao = factory.createEmployeeDAOFactory();
```

Mediante este patrón de diseño **_Factory_** se impide que una aplicación se vincule a una aplicación específica implementadora del **Patrón DAO**.

Se debe evitar la duplicación de código siempre que se pueda y refactorizar al máximo posible sin poner en riesgo la funcionalidad de la aplicación y dejándola intacta. La Factoría permite obtener estos resultados de una forma eficiente.

## Patrón Cadena de Responsabilidad

El patrón de diseño **Cadena de Responsabilidad** (_Chain of Responsability_) es un patrón de tipo **comportamiento** es decir, que establece protocolos de interacción entre clases y objetos emisores y receptores de los mensajes a procesar. Se utiliza para desacoplar las diferentes implementaciones de un algoritmo de su uso final, ya que el emisor del mensaje no tiene porqué conocer el componente que finalmente procesará el mensaje.

- Se forma una lista encadenada con todos los posibles receptores del mensaje, de forma que cada uno de ellos dispone de un enlace al siguiente, si se quiere, ordenados pueden ordenarse por prioridad de forma que en caso de que varios de ellos sean capaces de procesar un mismo mensaje, prevalezca el que tenga una prioridad mas alta según criterios funcionales.
- El emisor del mensaje, sólo ha de tener acceso al primero de los receptores. Será a este al que se le hará la llamada inicial y quien proporcionará el resultado al emisor.
- Cada uno de los receptores, evaluará el mensaje proporcionado por el emisor y decidirá si es capaz de procesarlo y proporcionar un resultado. En caso afirmativo, se acabará la cadena de llamadas a posteriores receptores y se retornará. Esto hará que el resultado pase por todos los receptores ejecutados anteriormente hasta devolvérselo al emisor. En caso que el receptor actual no sea capaz de evaluar el mensaje, delegará en el siguiente receptor en la cadena esperando el resultado que le proporcione, sea él o no el que finalmente se haga cargo de proporcionárselo.
El siguiente diagrama de secuencia ilustra los puntos detallados con anterioridad:

![](/assets/posts/java/ocp-7/2016-03-27-ocp7_14_patrones_de_diseno_en_java_fig1.png)

En él se puede observar una situación en la que se dispone de un emisor y 4 receptores capaces de procesar diferentes mensajes. El emisor hace la llamada al primer de los receptores para que le proporcione el resultado. Éste, al evaluarlo, ve que no es capaz de procesarlo y delega en el segundo de los receptores y así sucesivamente hasta llegar al tercero de ellos, que si es capaz de hacerlo y proporciona un resultado, haciendo innecesaria la propagación del mensaje al cuarto de ellos. El resultado se propaga por los receptores 1 y 2 hasta llegar al emisor de forma transparente.

[Ejemplo de implementación utilizando Spring](/spring/patterns/2015-12-07-patron_cadena_de_resposnabilidad_con_spring)
