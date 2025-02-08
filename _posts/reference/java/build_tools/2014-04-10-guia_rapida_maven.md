---
author: Xavier Salvador
title: Guía rápida Maven
date: 2022-04-05
categories: [ "references", "java", "build tools" ]
tags: [ "java", "maven" ]
layout: post
excerpt_separator: <!--more-->
---

<!--more-->

## Descripciones de los términos más conocidos

- `ArtifactId`: Identificador de un proyecto en Maven. Dentro del repositorio es la carpeta última contenedora de los ficheros de la librería
- `groupId`: Grupo identificador asociado al proyecto. Un proyecto debe pertenecer obligatoriamente a un grupo
- `archetpe:create`: Comando para crear un proyecto Maven vacío

```sh
mvn archetype:generate 
    -DgroupId=com.mycompany.app 
    -DartifactId=my-app 
    -DarchetypeArtifactId=maven-archetype-quickstart 
    -DinteractiveMode=false
```

- `package`: Permite generar un jar, war o web desplegada (opción exploded). Está formado por la versión del proyecto y por el indicador de la construcción.

```
Ejemplo:    1.0         –    SNAPSHOT
(versión)      (indicador de proceso de construcción)
```

> **NOTA**:
> Si se utiliza la agrupación de los 2 se considera que es la **VERSIÓN** la que **se debe indicar en la mayoria de referencias de Poms dependientes o jerarquizados**.

Para obtener la versión de Maven instalada en el sistema en Windows se debe ejecutar el siguiente comando:

```sh
mvn --version
```

Aparecerá por pantalla la versión de Maven instalada en el sistema.

Dentro de Maven se crea un directorio siguiendo el esquema definido por el standard project structure de Maven. Se compone de los siguientes elementos:

```
my-app
|
|-- pom.xml
|
|-- src
     |-- main
     |   |-- java
     |       |-- com
     |           |-- mycompany
     |               |-- app
     |                   |-- App.java
     |-- test
         |-- java
             |-- com
                 |-- mycompany
                     |-- app
                         |-- AppTest.java
```

Dónde src/main/java contiene el código fuente del proyecto, src/test/java contiene el código fuente de test y el fichero pom.xml es el Project Object Model oPOM.

El **POM** es una representación XML de un proyecto Maven contenido en un archivo denominado `pom.xml`.  
Este fichero puede contener información de la configuración del proyecto, de las personas involucradas y del rol rol que ejercen, del sistema de control de incidencias, la organización, licencias, URL dónde reside el proyecto, dependencias del proyecto y todas las piezas que dan sentido al código. 
En el mundo de Maven, un proyecto no necesita contener ningún tipo de código, simplemente un `pom.xml`.

## Construyendo un projecto con Maven

`mvn package` donde `package` es una fase (secuencia ordenada de pasos).

El ciclo de vida por defecto contiene la fases de construcción. Referencia del ciclo de vida:

- `validate` Valida que el proyecto es correcto y toda la información necesaria está disponible
- `compile` Compila el codigo fuente del proyecto
- `test` Testea el código fuente compilado usando un *framework* de testing unitario adecuado. Los tests no requieren que el artefacto sea empaquetado o desplegado
- `package` Empaqueta el código compilado en el formato distribuible adecuado, por ejemplo `JAR` 
- `integration-test` Procesa y despliega si es necessarion en un entorno donde los test de integración puede ser ejecutados
- `verify` Ejecuta las comprobaciones pertinentes sobre el desplegable y verifica que es válido y cumple los criterios de calidad
- `install` Instala el paquete generado en el repositorio local para su uso como dependencia en otros proyectos de forma local
- `deploy` En entornos de integración o *release*, copia el paquete final en el repositorio remoto para su compartición con otros desarrolladores y proyectos
