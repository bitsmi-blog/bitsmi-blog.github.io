---
author: Antonio Archilla
title: Creación de un Fat Jar con Apache Maven
date: 2015-08-30
categories: [ "references", "java", "build tools" ]
tags: [ "java", "maven" ]
layout: post
excerpt_separator: <!--more-->
---

Hace un tiempo publiqué un post en este mismo blog en el que se explicaba como [construir un **Fat Jar** con **Apache Ant**](/references/java/build%20tools/2015-03-30-Creacion_de_un_Fat_Jar_con_Apache_Ant.html) para empaquetar toda una aplicación, dependencias incluidas, dentro de un mismo fichero jar. El procedimiento para ello se basa en extraer los ficheros `*.class` compilados que se encuentran dentro de los jars de las dependencias incluirlo dentro del jar principal de la aplicación. En caso de utilizar **Maven** como herramienta de construcción en lugar de Ant, esta acción se puede realizar utilizando el plugin `Shade`. Para ello será necesario incluir su definición dentro del fichero `pom.xml` del proyecto y asociar la ejecución de su único goal `shade` a la ejecución de la fase de empaquetado `package`:

```xml
<build>
    <plugins>             
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-shade-plugin</artifactId>
            <version>2.4.1</version>
            <executions>
                <!-- Ejecutar el goal "shade" en la fase de empaquetado "package" -->
                <execution>
                    <phase>package</phase>
                    <goals>
                        <goal>shade</goal>
                    </goals>
                    <configuration>
                        <transformers>
                            <!-- Se puede especificar la clase que contiene el método "main" para inluirlo en el Manifest 
                                 de la aplicación i así hacerla ejecutable
                            -->
                            <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                                <mainClass>com.bitsmi.yggdrasil.launcher.MainProgram</mainClass>
                            </transformer>
                        </transformers>
                    </configuration>
                </execution>
            </executions>
        </plugin>
    </plugins>      
</build>
```

Esto hará posible su ejecución automática durante la construcción de la aplicación a través de los goals `package`, `install` o `deploy` de **Maven**.

Adicionalmente, es posible especificar en la configuraciones adicionales para la ejecución del plugin en la sección `<configuration/>`, como por ejemplo reglas de inclusión y exclusión de artefactos en el **Fat Jar**, renombrado de paquetes, o tratamiento de recursos ubicados en el directorio `META-INF` para evitar solapamiento (ficheros de licencia, definición de Services…). En la página del plugin hay multitud de ejemplos sobre cómo utilizar cada una de estas funcionalidades.

## Enlaces de interés

- [Creación de un Fat Jar con Apache Ant](/references/java/build%20tools/2015-03-30-Creacion_de_un_Fat_Jar_con_Apache_Ant.html)
- [Apache Maven Shade Plugin](https://maven.apache.org/plugins/maven-shade-plugin/)
