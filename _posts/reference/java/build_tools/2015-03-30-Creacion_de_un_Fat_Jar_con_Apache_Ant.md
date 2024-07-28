---
author: Antonio Archilla
title: Creación de un Fat Jar con Apache Ant
date: 2015-03-30
categories: [ "references", "java", "build tools" ]
tags: [ "java", "apache ant" ]
layout: post
excerpt_separator: <!--more-->
---

Normalmente para construir el distribuible de una aplicación Java se empaqueta el código principal de esta dentro de un **fichero jar ejecutable**, esto es, que contiene dentro de su fichero de definición `MANIFEST.MF` una entrada que especifica qué clase contiene el metodo `main()` y junto a este se crea una carpeta que contenga todas las dependéncias que este (habitualmente se llama a esta carpeta `lib`).


Esto hace que para especificar el classpath de la aplicación sea necesario:

Especificar directamente en el archivo `MANIFEST.MF` de forma individual todos las dependéncias que forman el classpath mediante la propiedad Class-Path de la siguiente manera
`Class-Path: lib/jar1.jar lib/jar2.jar lib/jar3.jar`

Especificar en la orden de ejecución Java las dependéncias a través del parámetro cp
En **Windows**: `java -cp "lib/jar1.jar;lib/jar2.jar;lib/jar3.jar" -jar jar_principal`

En **Unix**: `java -cp "lib/jar1.jar:lib/jar2.jar:lib/jar3.jar" -jar jar_principal`

En **Java 6** también es posible utilizar wildcards: `java -cp "lib/*" -jar jar_principal`

Este método hace tediosa la llamada a la máquina vitual y normalmente se tiende a crear un shell-script o cmd que haga la llamada por nosotros, con lo que se añade un fichero más al distribuible

En ciertas circumstancias muchas veces es preferible distribuir nuestra aplicación en un jar simple que facilite su distribución y ejecución, pero hay que incluir las dependencias de alguna manera. Aquí es donde entra la técnica de generar un **fat jar**, o dicho de otra manera, empaquetar toda la aplicación, dependéncias incluidas dentro de un mismo fichero jar. Para ello se suelen extraer los ficheros .class compilados que se encuentran dentro de los jars de las dependéncias y se incluyen dentro del jar principal de la aplicación. Cómo el package de las clases és único no se producen conflictos al incluirlos dentro de este. Un mecanismo sencillo de realizar esta tarea mediante un script de Apache Ant es la siguiente:

Incluir todas las clases de las dependencias en un mismo jar temporal que servirá como fuente en la creación del jar definitivo

```xml
<target name="main.dependencies.jar">       
    <jar jarfile="${dist.dir}/dependencies-all.jar">
        <zipgroupfileset dir="lib">
            <include name="**/*.jar" />
        </zipgroupfileset>
    </jar>        
</target>
```

Mediante el tag `zipgroupfileset` se incluyen en el jar de dependéncias todos los ficheros contenidos dentro de los jars de la carpeta lib.

Construir el jar principal, para ello se lanzan previamente las tareas de limpieza, compilado y generación del jar de dependencias. No se encuentran definidas en el ejemplo las 2 primeras tareas porque es bastante obvia su función. El siguiente código corresponde a la tarea de generación del jar principal

```xml
<target name="main.jar" depends="clean, main.compile, main.dependencies.jar">
        <mkdir dir="${dist.dir}"/>
        <jar destfile="${dist.dir}/${jar.name}.jar"
                basedir="${main.build.dir}"
                manifest="${main.resources.dir}/META-INF/MANIFEST.MF">
             
            <zipfileset src="${dist.dir}/dependencies-all.jar" 
                    excludes="META-INF/*.SF" />
        </jar>
</target>
```

Mediante el tag `zipfileset` se incluyen en el jar todos los ficheros contenidos en el jar de dependencias exceptuando el contenido del directorio `META-INF` que pueda sobreescribir el `MANIFEST.MF` de la aplicación principal

