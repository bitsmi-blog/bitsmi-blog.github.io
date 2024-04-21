---
author: Antonio Archilla
title: Multi-release JARs
date: 2022-04-05
categories: [ "references", "java", "build tools" ]
tags: [ "java", "maven" ]
layout: post
excerpt_separator: <!--more-->
---

En los últimos años Java ha estado evolucionando muy rápido con el nuevo ciclo de distribución en el que se liberan 2 nuevas versiones por año. Con la nueva versión **17** *Long Time Support* (**LTS**) de la **JDK** y la versión **18** a la vuelta de la esquina, muchos desarrollos aún están asimilando la anterior versión **LTS**, la **JDK 11**. Se hace patente el hecho que los desarrollos de aplicaciones Java no pueden seguir el ritmo en el que van apareciendo las nuevas características del lenguaje y por eso muchas de ellas tardan en ser de uso general. Una de las consecuencias de este hecho es que los desarrolladores de librerías y *frameworks* están forzados esperar hasta que la base de aplicaciones a los que dan soporte se adapta para seguir siendo compatibles con ellas.

Desde la aparición de **Java 9** han aparecido mecanismos para paliar este hecho, posibilitando la construcción de artefactos compatibles con múltiples versiones de **JDK**. Uno de ellos son los **Multi-Release JARs** (**MRJAR**), que hace posible integrar en un mismo componente (fichero **JAR**) diversas versiones de código compatibles con múltiples versiones de **JDK**.

En este artículo se explica el funcionamiento de los **MRJAR** así como su integración en un proyecto construido mediante **Maven**.

<!--more-->

Este mecanismo se basa en construir una estructura de clases paralela dentro del directorio `META-INF` del fichero **JAR** a fin de no provocar conflictos con versiones de **JRE** anteriores a la **9**, ja que estas no las reconocerán como clases por estar dentro de este directorio. Para las versiones de **JRE** que sí son compatibles con este mecanismo, la estructura paralela de clases define un directorio por cada versión de **JDK** donde ubicar las clases que aplicarían las nuevas características no compatibles.

Un ejemplo de estructura sería el siguiente:

```
my-lib.jar
|- mypackage (1)
|  |- Sample.class
|- META-INF
   |- versions
      |- 11 (2)
      |  |- mypackage
      |  |- Sample.class
      |- 17 (3)
         |- mypackage
            |- Sample.class
```

En este caso, la librería presenta 3 versiones de la misma clase apropiadas para diferentes versiones de **JDK**. La selección de la versión de la clase que la **JRE** cargará en tiempo de ejecución viene determina por la versión máxima permitida por la **JRE**. A continuación se muestran diferentes escenarios para el caso de ejemplo:

- La aplicación es ejecutada por una **JRE 11**: Se selecciona la versión **(2)** de la clase ya que hay correspondencia directa
- La aplicación es ejecutada por una **JRE 13**: Se selecciona la versión **(2)** de la clase ya que la versión máxima permitida por la **JRE**, la **13**, no tiene versión especifica. En este caso se escoge la versión menor más próxima.
- La aplicación es ejecutada por una **JRE 9**: Se selecciona la versión por defecto **(1)** de la clase ya que no hay una versión apropiada dentro del directorio `META-INF/versions`
- La aplicación es ejecutada por una **JRE 8**: Se selecciona la versión por defecto **(1)** de la clase ya que la **JRE** no interpreta el directorio `META-INF/versions` como una ubicación con clases que se deban cargar.

El aspectos más importante a tener en cuenta cuando se definen diferentes versiones de una misma clase es que la API que ofrezcan las diferentes versiones de la clase debe ser la misma. No se deberá añadir, quitar o modificar la firma de los métodos públicos de la misma. En caso contrario, la creación del **MRJAR** fallará.

A la hora de compilar las clases para empaquetarlas en el fichero **JAR** se hace uso de la opción `--release` del compilador para especificar la versión de ***bytecode*** que se generará. Por ejemplo, para una librería que debe ser compatible con **Java 8** y **11** la compilación ser realizaría de la siguiente manera, teniendo en cuenta siempre que el compilador debe pertenecer a la versión mayor y siempre de una versión **>= 9** ya que las versiones anteriores no soportan esta opción.

**Compilar las clases por defecto**
Deben ser compatibles con **Java 8** por lo que se compilaran con `--release 8`

```sh
javac --release 8 -d build/classes src/main/java/mypackage/*.java
```

**Compilar las clases especificas para Java 11**
Se compilaran con `release 11`

```sh
javac --release 11 -d build/classes11 src/main/java11/mypackage/*.java
```

**Crear el fichero JAR**
Finalmente, se deberan unir los resultados de las diferentes compilaciones para crear el fichero **JAR** resultante

```sh
jar --create --file target/mrjar.jar
  -C build/classes . --release 11 -C build/classes11 .
```

Adicionalmente, el fichero `MANIFEST.MF` del **JAR** resultante deberá especificar el siguiente atributo en su interior (No se genera automáticamente):

```properties
Multi-Release: true
```

En el siguiente apartado se mostrará la manera de hacer todo este proceso de una forma más automatizada mediante **Maven**.

## Construcción mediante Maven

Para un proyecto basado en **Maven**, es posible realizar de una forma sencilla una configuración de sus *plugins* `maven-compiler-plugin` y `maven-jar-plugin` para que realicen todo el trabajo anteriormente comentado

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <version>3.10.1</version>
    <executions>
        <!-- (1) -->
        <execution>
            <id>compile-java-8</id>
            <goals>
                <goal>compile</goal>
            </goals>
            <configuration>
                <source>${java.version}</source>
                <target>${java.version}</target>
                <encoding>${project.build.sourceEncoding}</encoding>
                <!-- (2) -->
                <release>8</release>
            </configuration>
        </execution>
        <!-- (3) -->
        <execution>
            <id>compile-java-11</id>
            <phase>compile</phase>
            <goals>
                <goal>compile</goal>
            </goals>
            <configuration>
                <!-- (4) -->
                <release>11</release>
                <!-- (5) -->
                <compileSourceRoots>                    <compileSourceRoot>${project.basedir}/src/main/java11</compileSourceRoot>
                </compileSourceRoots>
                <!-- (6) -->
                <multiReleaseOutput>true</multiReleaseOutput>
            </configuration>
        </execution>        
    </executions>
</plugin>
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-jar-plugin</artifactId>
    <version>3.2.0</version>
    <configuration>
        <archive>
            <manifest>
                <mainClass>snippets.mrjar.MainProgram</mainClass>
            </manifest>                     
            <manifestEntries>
                <!-- (7) -->
                <Multi-Release>true</Multi-Release>                         
            </manifestEntries>
        </archive>
    </configuration>
</plugin>
```

Aspectos a comentar de la configuración:
- **1** y **3**: Las diferentes versiones de las clases se deberán compilar con el compilador correspondiente. Para ello se definirá una ejecución para el código por defecto, que irá en la raíz del fichero **JAR** `(1)` y otras tantas para las diferentes versiones para **JRE**s especificas, que irán dentro de la estructura `META-INF/versions` del **JAR** resultante `(3)`. 
- **2** y **4**: Se marcará con la opción `release` la compatibilidad del código generado en cada caso para que se pueda ejecutar en una **JRE** específica.
- **5**: Los directorios que contengan el código versionado para las diferentes **JRE**s soportadas, se deberá especificar como `compileSourceRoot` en las correspondientes configuraciones de ejecución del compilador.
- **6**: En las opciones de las ejecuciones del compilador que se encarguen de compilar el código para las clases versionadas, se deberá especificar la opción `multiReleaseOutput` para que el resultado de dicha compilación se coloque dentro de la estructura `META-INF/versions` del **JAR** resultante.
- **7**: Se debe especificar la opción `Multi-Release` en la configuración del plugin `maven-jar-plugin` para que incluya en el `Manifest.MF` la entrada correspondiente. De otra manera, el **JAR** resultante no sería reconocido como un **MRJAR** por ninguna **JRE** compatible.

Un aspecto a remarcar es que la versión de la **JDK** que ejecutará el compilador para cada una de las ejecuciones, debe soportar el código de `release` mayor. Por ejemplo, no se podrá especificar una release `17` si el plugin `maven-compiler-plugin` está utilizando la **JDK** `11`. En ocasiones en que se deba forzar una **JDK** especifica, será posible utilizar el plugin `maven-toolchains-plugin` para especificar una versión concreta que será utilizada de forma global en todo el proceso de construcción

```xml
<plugin>                    
    <artifactId>maven-toolchains-plugin</artifactId>
    <executions>
      <execution>
        <goals>
          <goal>toolchain</goal>
        </goals>
      </execution>
    </executions>
    <configuration>
      <toolchains>
        <jdk>
          <version>11</version>
        </jdk>
      </toolchains>
    </configuration>
</plugin>
```

O especificarla directamente en la configuración de la ejecución de la compilación mediante la opción `jdkToolchain`:

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <executions>
        <execution>
            <id>compile-java-11</id>
            <phase>compile</phase>
            <goals>
                <goal>compile</goal>
            </goals>
            <configuration>             
                <jdkToolchain>11</jdkToolchain>
                . . .
            </configuration>
        </execution>        
    </executions>
</plugin>
```

## Testing

Para realizar el *testing* de una implementación basada en múltiples versiones para diferentes **JRE**s no es posible ejecutar **tests unitarios** corrientes dado que para que funcione el código debe estar empaquetado en un fichero **JAR**. Como alternativa, se pueden realizar **tests integrados** en los el se ejecuta el código cuando ya está empaquetado.

Si se utiliza **Maven** será posible utilizar el plugin *plugin* `Maven-failsafe` para realizar los **tests integrados** sobre las diferentes versiones soportadas por la aplicación. A continuación se muestra un ejemplo de configuración para la ejecución de varias versiones de **JRE**s.

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-surefire-plugin</artifactId>
    <version>3.0.0-M5</version>
</plugin>
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-failsafe-plugin</artifactId>
    <version>3.0.0-M5</version>
    <executions>
        <!-- Test JRE 8 (1) -->
        <execution>
            <id>it-java-8</id>
            <goals>
                <goal>integration-test</goal>
                <goal>verify</goal>
            </goals>
            <configuration>
                <jdkToolchain>
                    <version>8</version>        
                </jdkToolchain>
                <includes>
                    <include>**/*IT</include>
                    <include>**/*ITCase</include>
                </includes>     
                <!-- El comando java no soporta la opción `module-path` en la JDK8 (2) -->
                <useModulePath>false</useModulePath>           
            </configuration>
        </execution>
        <!-- Test JRE 11 (3) -->
        <execution>
            <id>it-java-11</id>
            <goals>
                <goal>integration-test</goal>
                <goal>verify</goal>
            </goals>
            <configuration>
                <jdkToolchain>
                    <version>11</version>        
                </jdkToolchain>
                <includes>
                    <include>**/*IT</include>
                    <include>**/*ITCase</include>
                </includes>     
            </configuration>
        </execution>
    </executions>
</plugin>
```

En este ejemplo, se definen 2 ejecuciones diferentes para **Java 8** `(1)` y **Java 11** `(3)`. Hay que tener en cuenta que para versiones previas a **Java 9** se tiene que especificar la opción `useModulePath = false` `(2)` para no utilizar el **module path** al ejecutar la aplicación, ya que no está soportado.

La especificación de la **JRE** a utilizar en cada caso se hace a través de la correspondiente `jdkToolchain`, que hará referencia a una configuración que haya hecha en el fichero `toolchains.xml`  de **Maven**. Su ubicación por defecto es `~/.m2/toolchains.xml`, A continuación se muestra la configuración de las ***toolchains*** utilizadas:

```xml
<toolchains>
  <toolchain>
      <type>jdk</type>
      <provides>
          <version>8</version>
          <vendor>Oracle</vendor>
      </provides>
      <configuration>
          <jdkHome>e:\bin\jdk8u322-b06\</jdkHome>
      </configuration>
  </toolchain>
    <toolchain>
      <type>jdk</type>
      <provides>
          <version>11</version>
          <vendor>OpenJ9</vendor>
      </provides>
      <configuration>
          <jdkHome>e:\bin\jdk-11.0.9+11-openj9</jdkHome>
      </configuration>
  </toolchain>
</toolchains>
```

Se podrá utilizar el *plugin* `build-helper-maven-plugin` para especificar el directorio de código donde estan ubicados los **tests integrados**, en este caso `src/integration-test`.

```xml
<plugin>
    <groupId>org.codehaus.mojo</groupId>
    <artifactId>build-helper-maven-plugin</artifactId>
    <version>3.3.0</version>
    <executions>
        . . .
    <!-- (1) -->
        <execution>
            <id>add-integration-test-source</id>
            <phase>generate-test-sources</phase>
            <goals>
                <goal>add-test-source</goal>
            </goals>
            <configuration>
                <sources>
                    <source>src/integration-test/java</source>
                </sources>
            </configuration>
        </execution>
        <execution>
            <id>add-integration-test-resource</id>
            <phase>generate-test-resources</phase>
            <goals>
                <goal>add-test-resource</goal>
            </goals>
            <configuration>
                <resources>
                    <resource>
                        <directory>src/integration-test/resources</directory>
                    </resource>
                </resources>
            </configuration>
        </execution>
    </executions>
</plugin>
```

Dentro de la implementación de los **tests** es posible utilizar mecanismos como la [**API Assumptions**](https://junit.org/junit5/docs/5.0.0/api/org/junit/jupiter/api/Assumptions.html) de **JUnit** para asegurar que cada uno de los tests se ejecutan sobre la **JRE** adecuada. En el siguiente ejemplo se utiliza el valor de la propiedad del sistema `java.version` para ello: 

```java
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assumptions.assumeTrue;
import org.junit.jupiter.api.Test;

public class JavaVersionProviderITCase
{
    @Test
    public void java11Test()
    {
        int version = getJREMajorVersion();
        // Se ejecuta sólo cuando la versión de Java >= 11
        assumeTrue(version>=11);
        
        IJavaVersionProvider provider = new JavaVersionProviderImpl();
        assertEquals(provider.getProvider(), "Java11 provider");
    }
    
    @Test
    public void defaultTest()
    {
        int version = getJREMajorVersion();
        // Se ejecuta sólo cuando la versión de Java < 11
        assumeTrue(version<11);
        
        IJavaVersionProvider provider = new JavaVersionProviderImpl();
        assertEquals(provider.getProvider(), "Default provider");
    }
    
    private int getJREMajorVersion()
    {
        String javaVersion = System.getProperty( "java.version" );
        String major = javaVersion.substring(0, javaVersion.indexOf("."));
        return Integer.parseInt(major);
    }
}
```

El ejemplo completo se encuentra en el siguiente [repositorio de Bitbucket](https://bitbucket.org/bitsmi/snippets/src/master/maven/multi_release_jar/)

## Compatibilidad en los IDEs

Algunos **IDEs**, por ejemplo en **Eclipse**, no soportan adecuadamente los **MRJAR** y en los casos en que se realizan múltiples versiones de la misma clase, pueden lanzar errores por encontrar clases duplicadas. Como *workaround* para este problema, se pueden estructurar los directorios de código del proyecto para, añadiendo en el ***build path*** sólo los directorios sobre los que se quiere trabajar en un momento determinado, sólo haya una versión de las clases. Un ejemplo de estructura de trabajo puede ser la siguiente:

- `src/main/java`: Clases comunes sin versiones especificas
- `src/main/java-default`: Versiones de las clases que serán ubicadas en la estructura por defecto al construir el **MRJAR**, esto es, fuera del directorio `META-INF/versions`
- `src/main/javaXX`: Versiones de clases especificas para una **JDK** concreta, donde **XX** será la versión de la misma. P.E. **java9**, **java11**, **java17**...

En este ejemplo, en caso de trabajar sobre la versión por defecto los directorios presentes en el ***build-path*** serán `src/main/java` y `src/main/java-default`; si se trabaja para la versión de **JDK 11** serán `src/main/java` y `src/main/java11` y así sucesivamente.

Esta manera de trabajar presenta el inconveniente de tener que ir cambiando el ***build-path*** manualmente en el **IDE**, lo que es engorroso y requiere cierta precaución para no cometer errores, pero al menos permite las funcionalidades asistidas que proporciona el **IDE**.

Durante la construcción del proyecto mediante **Maven** no aparece este problema porque el **Maven-compiler-plugin** ya está preparado para ello.

Para **Intellij Idea**, en este [artículo](https://blog.jetbrains.com/idea/2017/10/creating-multi-release-jar-files-in-intellij-idea/) se explica la manera de configurarlo.

## Referencias

- [Referencia MRJAR en docs de Maven Compiler Plugin](https://maven.apache.org/plugins/maven-compiler-plugin/multirelease.html)
- [Blog Intellij Idea](https://blog.jetbrains.com/idea/2017/10/creating-multi-release-jar-files-in-intellij-idea/)
- [Ejemplo](https://bitbucket.org/bitsmi/snippets/src/master/maven/multi_release_jar/)
- [JUnit Assumptions](https://junit.org/junit5/docs/5.0.0/api/org/junit/jupiter/api/Assumptions.html)
