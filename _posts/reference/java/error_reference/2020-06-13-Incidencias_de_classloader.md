---
author: Antonio Archilla
title: Incidencias de class loader
date: 2020-06-13
categories: [ "references", "java", "error reference" ]
tags: [ "java" ]
layout: post
excerpt_separator: <!--more-->
---

En el lenguaje de programación Java, para identificar una clase especifica se tienen en cuenta principalmente 2 cosas: El nombre del *package* en el que se encuentra y el propio nombre de la clase. Mediante estos 2 valores, el sistema de *class loaders* de la máquina virtual identifica y carga la diferentes clases según sean necesarias durante la ejecución de una aplicación. Este mecanismo tiene un problema bastante conocido cuando más de una clase con el mismo nombre y *package* se encuentran contenidas en ficheros *jar* o directorios diferentes. Este fenómeno es una de las variantes del denominado [**Jar Hell**][jar-hell] que en este caso concreto consiste en que no todas las clases pertenecientes al mismo *package* que son cargadas por el sistema de *class loaders* proceden de la misma ubicación (directorio de clases o fichero *jar*), lo que puede ocasionar incompatibilidades o errores inesperados si estas no pertenecen a la misma versión de código.

La especificación de Java define un mecanismo denominado ***package sealing*** que puede **aplicarse opcionalmente** para garantizar que todas las clases pertenecientes a un mismo *package* son cargadas desde el **mismo fichero jar**. En caso de que la máquina virtual en un momento determinado intente cargar una clase de un *package* definido como sellado y esta pertenezca a un fichero *jar* distinto al del resto de clases del mismo *package* ya cargadas, se producirá un error advirtiendo de ello. Desafortunadamente, no todas las librerías hacen uso de este mecanismo, por lo que a veces es complicado ver si esta puede ser la causa de un error determinado.

En este artículo se exponen diferentes casuísticas derivadas de este fenómeno y de como identificar la causa de un error de este tipo para poder solucionarlo.

<!--more-->

## Introducción al problema

El sistema de carga de clases de la máquina virtual Java consta de una estructura jerárquica de múltiples *class loaders* que cargan las clases desde múltiples ubicaciones diferentes en el momento que son requeridas por la ejecución del programa. Como mínimo, esta estructura cuenta con 3 *class loaders*:

* **Bootstrap class loader**: Es el *class loader* raiz de toda la estructura. Es responsable de cargar las clases de la propia JDK, esto es las contenidas en  **rt.jar** i en otras librerías core ubicadas en `jre/lib` 
* **Extension class loader**: Responsable de la carga de las librerías que forman las extensiones del core de java ubicadas en `lib/ext`
* **System class loader**: Responsable de la carga de clases a nivel de aplicación desde las ubicaciones configuradas mediante la opción `-classpath` al ejecutar la máquina virtual.

Adicionalmente, las aplicaciones pueden definir su propia estructura de *class loaders* que colgaran del **system class loader**. Esto se suele hacer para limitar el acceso del código en ejecución a otras clases. Por ejemplo, el código de una librería de terceros al *core* de la aplicación.

El procedimiento de carga de clases típico funciona de la siguiente manera:

* Cuando una clase es requerida por la ejecución de la aplicación, ya sea por la instanciación de un objecto de la misma o por el acceso estático a uno de sus miembros, se delega la localización de su definición al mismo *class loader* que ha cargado la clase donde se está produciendo la instanciación o acceso. Es decir, si dentro del código de una clase **C1** se instancia o accede a la clase **C2**, el *class loader* que se utilizará para cargar la definición será el mismo que ha cargado la clase **C1**. 
* Si ya ha sido cargada anteriormente por el *class loader* se devuelve esa definición.
* En caso que no sea así, el *class loader* delegará la localización de la clase a su *class loader* antecesor en la jerarquía. La identificación de la clase se realiza a partir del *package* y el nombre de esta. 
* Si ninguno de los *class loader* antecesores ha cargado previamente la clase y tampoco son capaces de localizar su definición, el *class loader* la intentará localizar y cargar desde una de las ubicaciones que tiene configuradas.
* Este proceso se repite para cada uno de los niveles de la jerarquía de *class loaders* hasta que uno de ellos devuelve la definición de la clase.
* En el caso de que ningún *class loader* de la jerarquía consiga cargar la definición de la clase, se lanzará un error de tipo `java.lang.ClassNotFoundException`.

No es difícil encontrar entornos donde las ubicaciones por las que se distribuyen las diferentes clases y librerías involucradas en la ejecución de una aplicación se multiplican. Por ejemplo, en la ejecución de una aplicación web por un servidor de aplicaciones como puede ser **Tomcat**, las librerías que intervienen se encuentran ubicadas a varios niveles. De una forma muy esquemática, se pueden identificar: 

* Librerías proporcionadas por la JVM (Core y extensiones). Son gestionadas por los *class loaders* de **Bootstrap** y **Extension**
* Librerías proporcionadas por el servidor de aplicaciones. En muchos casos, el mismo servidor de aplicaciones dispone de varios niveles de *class loaders* que cargan las librerías desde diferentes ubicaciones. Son gestionadas por el *System class loader* u otros creados por el servidor de aplicaciones a partir de este.
* Librerías propias de la aplicación web que pueden o no ser gestionadas mediante sistemas de control de dependencias, como el implementado por **Maven**. Son gestionadas por un *class loader* que el servidor de aplicaciones crea explícitamente para cad una de las aplicación web que ejecuta y normalmente cuelga de uno de los *class loaders* 
que crea el propio servidor de aplicaciones. 

Aunque esta estructura multicapa es un mecanismo muy versátil, tiene el inconveniente de que no proporciona un mecanismo que impida que múltiples versiones de la misma clase se encuentren en los diferentes ubicaciones, lo que propicia que puedan aparecer problemas asociados al [**Jar Hell**][jar-hell].

#### Ejemplo

Una aplicación ejecutada en un servidor de aplicaciones dispone de la siguiente estructura de *class loaders* asociados a distintas ubicaciones a partir de las que se cargan las clases necesarias:

![](/assets/posts/reference/java/error_reference/Incidencias_de_classloader_fig1.png)

La librería **foo** se encuentra en 2 versiones diferentes en 2 ubicaciones diferentes. Una es cargada por el *class loader* del servidor de aplicaciones (**foo-1.0.0.jar**) y la otra por el de la aplicación (**foo-2.0.0.jar**). Entre las 2 versiones es muy posible que se hayan añadido o eliminado clases y métodos de la API. Por ejemplo, se suponen las siguientes implementaciones:

**foo-1.0.0.jar**

```java
package com.foo.first.package;

public class Bar 
{
	. . .
	
	public void doStuff() { ... }	
	
	. . .
}
```

**foo-2.0.0.jar**

```java
package com.foo.first.package;

public class Bar 
{
	. . .
	
	public void doStuff() { ... }
	// Método añadido en la versión 2 no presente en versiones anteriores
	public void doStuffv2(){ ... }
	
	. . .
}
```

**Código del servidor de aplicaciones**

```java
import com.foo.first.package.Bar

public class AppServerComponent 
{
	. . .
	
	public void serve() {
		new Bar().doStuff();
	}
	
	. . .
}
```

**Código de la aplicación web**

```java
import com.foo.first.package.Bar

public class ApplicationComponent 
{
	. . .
	
	public void doSomething() {
		// La aplicación hace uso de la API exclusiva de la v2.0.0
		new Bar().doStuffv2();
	}
	
	. . .
}
```

Se puede observar que la versión de la librería utilizada por la aplicación contiene llamadas a la API de la librería que no están presentes en la versión gestionada por el servidor de aplicaciones. Este hecho es importante ya que el uso de una u otra provocará un error cuando la aplicación intente llamar a la API nueva.

Dado que los códigos de *servidor de aplicaciones* y *aplicación web* son independientes y no hay control de cual de ellos se ejecutará primero, se pueden dar 2 casuísticas: 

**El código del servidor de aplicaciones se ejecuta primero**

El *class loader* asociado al servidor de aplicaciones (App. server shared class loader) no encuentra la clase `Bar` cargada porque no ha sido utilizada anteriormente y la carga desde el fichero `foo-1.0.0.jar` que se encuentra en la ubicación que gestiona (directorio AppServer/lib). Como es la misma versión de la librería que se ha utilizado para compilar el código del servidor de aplicaciones, el código de este se ejecuta sin problemas.

Seguidamente, la ejecución llega al componente de la aplicación web que accede a la clase `Bar`. Siguiendo el flujo de la jerarquía descrito, el *class loader* asignado a la aplicación web (Web application 1 class loader) no tiene cargada en si mismo la definición de la clase, por lo que delega en el *class loader* del servidor de aplicaciones su  localización. Como este ya ha cargado anteriormente la clase identificado por `com.foo.first.package.Bar`, devuelve la definición al *class loader* de la aplicación. En este caso la aplicación web ha sido compilada con la versión 2.0.0 de la librería y accede a un método que no está presente en la versión 1.0.0. Dado que la definición que se utiliza finalmente en la ejecución del código de la aplicación web es la 1.0.0, el método `doStuffv2` no está disponible y se produce un error indicándolo:

```java
Exception in thread "main" java.lang.NoSuchMethodError: 
  com.foo.first.package.Bar.doStuffv2();
  at ApplicationComponent.doSomething()
```  

**El código de la aplicación se ejecuta primero**

El *class loader* asociado a la aplicación web (Web application 1 class loader) no encuantra la clase `Bar` cargada porque no ha sido utilizada anteriormente y la carga desde el fichero `foo-2.0.0.jar` que se encuentra en la ubicación que gestiona (directorio WEB-INF/lib de la propia aplicación web). Como es la misma versión de la librería que se ha utilizado para compilar el código del servidor de aplicaciones, el código de este se ejecuta sin problemas.

Seguidamente, la ejecución llega al componente del servidor de aplicaciones. En este caso el mecanismo de carga de clases se iniciará en el *class loader* asociado al servidor de aplicaciones y como ni este ni ninguno de sus antecesores en la jerarquía de *class loaders* ha cargado la clase, la carga desde el fichero `foo-1.0.0.jar`. El *class loader* asociado a la aplicación web no se tiene en cuenta en el proceso dado que se encuentra por debajo en la jerarquía. Se da la situación que para el servidor de aplicaciones la versión de la clase cargada es la correspondiente a la versión 1.0.0 y para la aplicación es la 2.0.0, por lo que los 2 códigos funcionaran correctamente, aunque esto se deba unicamente a que el orden de ejecución de los componentes en este caso así lo ha propiciado. No se puede confiar en que el orden de ejecución sea siempre el mismo o que cambios en el entorno (servidor de aplicaciones, librerías asociadas...) alteren este orden.

En este ejemplo el resultado final es un error que puede ser más o menos visible en los *logs* de la aplicación, pero en otras ocasiones sólo es posible ver el error por los efectos colaterales de utilizar fragmentos de la implementación de la librería que no corresponden con el resto, lo que es más complicado de detectar.


#### Uso del *package sealing*

El funcionamiento del ***package sealing*** se basa en añadir al **Manifest** del fichero *jar* el campo `Sealed: true`. Este sellado puede ser aplicado a todos los *packages* del fichero o sólo a algunos concretos si se especifica el campo `Name` junto a `Sealed`. Los siguientes ejemplos muestran el sellado a nivel de fichero *jar* completo y el de únicamente de los *packages* `com/foo/first/package/` y `com/foo/second/package/`.

```properties
Manifest-Version: 1.0
Created-By: 1.7.0_06 (Oracle Corporation)
Sealed: true
```

```properties
Manifest-Version: 1.0
Created-By: 1.7.0_06 (Oracle Corporation)
Name: com/foo/first/package/
Sealed: true
Name: com/foo/second/package/
Sealed: true
```

Aplicando este mecanismo al ejemplo anterior, se produciría un error indicado que se está cargando perteneciente al *package* `com.foo.first.package` independientemente del orden en que los componentes de aplicación web y servidor de aplicaciones se ejecutasen. 


```java
java.lang.SecurityException: sealing violation: package com.foo.first.package is sealed
```

Si bien no evita la carga de clases desde diferentes ubicaciones, si se evitan los errores y efectos colaterales asociados.


## Detección y corrección del error

El ejemplo mostrado en el apartado anterior puede parecer un ejemplo forzado, pero no es tan raro encontrar problemas de este tipo con las librerías que suelen incorporar los servidores de aplicaciones o plataformas con posibilidad de ejecutar código de terceros. Clásicos son los problemas con librerías para el tratamiento de XML como pueden ser `Stax`, `Saaj`, `Jaxb` ahora que no es parte del core de la JDK... Las aplicaciones que se ejecutan en dichos entornos pueden incorporar sus propias versiones de las mismas librerías y presentar problemas de este tipo. Cuando se trabaja en un entorno que puede presentar problemas así, es importante analizar las dependencias que proporciona dicho entorno. Esto incluye librerías proporcionadas por el servidor de aplicaciones o plataforma donde se va a ejecutar la aplicación, librerías proporcionadas por la instalación de la JRE, tanto proporcionadas por la API como posibles extensiones u otras ubicaciones dependientes del entorno. Una vez se conocen las versiones de las librerías que entrarían en conflicto con las de la aplicación se deberá alinear estas versiones y evitar que estas se integren en el distribuible final. En **Maven** esto se consigue aplicando el *scope* **provided** a las dependencias conflictivas para poder compilar el código de la aplicación pero indicar que en tiempo de ejecución se cargaran las librerías proporcionadas por el entorno y no se deben incluir en el empaquetado final. Se puede utilizar el siguiente comando de **Maven** para extraer una lista de las dependencias finales que utiliza la aplicación así como su *scope*.

```sh
mvn dependency:list > dependencies.txt
```

También existe la posibilidad de analizar en tiempo de ejecución las ubicaciones desde las que son cargadas las clases. Para ello se debe utilizar la opción `-verbose:class` al inicial la aplicación:

```sh
java -jar -verbose:class -cp libs/* Application.jar
```

Esto reportará una línea de *log* por la salida estándar por cada clase cargada, con el nombre de esta y la ubicación desde la que ha sido cargada que será útil para detectar problemas de este tipo:

```
[Opened C:\Program Files\Java\jre1.8.0_144\lib\rt.jar]
[Loaded java.lang.Object from C:\Program Files\Java\jre1.8.0_144\lib\rt.jar]
[Loaded java.io.Serializable from C:\Program Files\Java\jre1.8.0_144\lib\rt.jar]
[Loaded java.lang.Comparable from C:\Program Files\Java\jre1.8.0_144\lib\rt.jar]
[Loaded java.lang.CharSequence from C:\Program Files\Java\jre1.8.0_144\lib\rt.jar]
[Loaded java.lang.String from C:\Program Files\Java\jre1.8.0_144\lib\rt.jar]
[Loaded java.lang.reflect.AnnotatedElement from C:\Program Files\Java\jre1.8.0_144\lib\rt.jar]
[Loaded java.lang.reflect.GenericDeclaration from C:\Program Files\Java\jre1.8.0_144\lib\rt.jar]
[Loaded java.lang.reflect.Type from C:\Program Files\Java\jre1.8.0_144\lib\rt.jar]
. . .
[Loaded com.foo.first.package.Bar from file:/C:/path/to/AppServer/lib/foo-1.0.0.jar]
. . .
[Loaded com.foo.first.package.Bar from file:/C:/path/to/AppServer/webapps/application1/WEB-INF/lib/foo-2.0.0.jar]
. . .
```


[//]: # (Links)
[jar-hell]:http://en.wikipedia.org/wiki/Java_Classloader#JAR_hell

