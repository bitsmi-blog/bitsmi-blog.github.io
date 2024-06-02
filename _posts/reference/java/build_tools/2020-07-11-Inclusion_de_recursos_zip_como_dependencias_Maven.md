---
author: Antonio Archilla
title: Inclusión de recursos zip como dependencias Maven
date: 2020-07-11
categories: [ "references", "java", "build tools" ]
tags: [ "java", "maven" ]
layout: post
excerpt_separator: <!--more-->
---

**Maven** es una herramienta altamente utilizada en el ecosistema **Java** para gestionar los módulos y librerías que componen una aplicación, ya sea directamente a través del própio **Maven** o de otras herramientas, como **Gradle**, **SBT**, **Ivy**, etc., que utilizan los repositorios de este para obtener dichos recursos. A parte de artefactos de tipo **jar**, **war** o definiciones **pom**, **Maven** también permite gestionar empaquetados de tipo **zip** en los repositorios. Esto permite gestionar dependencias a recursos estáticos comunes en varios proyectos **Maven** sin necesidad de duplicarlos en cada uno de ellos, facilitando así su mantenimiento y actualización. En este artículo se muestra de forma genérica como incluir recursos comunes en un proyecto **Maven** a través de una dependencia y un caso concreto de como aprovechar esto para gestionar paquetes **npm** de forma local sin tener que hacer uso de un repositorio **npm** remotoé

<!--more-->

## Gestión de dependencias mediante artefactos zip

En el siguiente apartado se muestra como producir mediante **Maven** un artefacto de tipo **zip** y como hacer uso de él en forma de dependencia dentro de otro proyecto **Maven**. Este mecanismo tiene diferentes utilidades, desde incluir los mismos recursos web dentro de ficheros **war** generados por diferentes proyectos, incluir ficheros de propiedades o configuración comunes o utilizar recursos compartidos para *testing*. 

#### Configuración del artefacto zip

Para crear el artefacto **zip**, se creará un proyecto **Maven** en el que se incluirá todo el contenido que se desea incluir en el fichero **zip** a distribuir. No es necesario que el proyecto tenga la configuración de `packaging jar` ya que el artefacto final al que se hará referencia será de tipo **zip**. Se puede definir como `pom` para que el proceso de *packaging* no genere ningún fichero **jar** adicional.

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                             http://maven.apache.org/maven-v4_0_0.xsd">
    <modelVersion>4.0.0</modelVersion>
	
	<groupId>com.bitsmi</groupId>
	<artifactId>maven-zip-artifact</artifactId>    
	<version>1.0.0-FINAL</version>
	<name>Sample Maven ZIP artifact</name>
	<packaging>pom</packaging>
	
	. . .
</project>
```

Mediante el *plugin* de **Maven** `maven-assembly-plugin` en el `pom` del proyecto se especificará el contenido y se generará el fichero **zip**. 

La configuración del *plugin* es la siguiente:

```xml
. . .
<build>
	<plugins>
		<plugin>
			<groupId>org.apache.maven.plugins</groupId>
			<artifactId>maven-assembly-plugin</artifactId>
			<executions>
				<execution>
					<id>resources</id>
					<goals>
						<goal>single</goal>
					</goals>
					<phase>package</phase>
					<configuration>							
						<descriptors>
							<descriptor>/src/main/assembly/resources.xml</descriptor>
						</descriptors>
					</configuration>
				</execution>
			</executions>
		</plugin>
	</plugins>
</build>
. . .
```

Es importante tener en cuenta que el `id` especificado, en este caso `resources`, corresponderá con el `classifier` utilizado para hacer referencia a la dependencia en el proyecto que la consuma. 

La configuración del ensamblado especificará qué ficheros y directorios serán incluidos en el **zip** resultante. 

Esta configuración se especifica en el parámetro de configuración `descriptor` del *plugin*, en este caso `/src/main/assembly/resources.xml`. 

Su contenido es el siguiente:

```xml
<assembly xmlns="http://maven.apache.org/plugins/maven-assembly-plugin/assembly/1.1.2" 
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xsi:schemaLocation="http://maven.apache.org/plugins/maven-assembly-plugin/assembly/1.1.2 http://maven.apache.org/xsd/assembly-1.1.2.xsd">
	<id>resources</id>
	<formats>
		<format>zip</format>
	</formats>
	<includeBaseDirectory>false</includeBaseDirectory>
	<fileSets>
		<fileSet>
			<directory>${project.basedir}/test-data</directory>
			<outputDirectory>/test-data</outputDirectory>			
		</fileSet>		
	</fileSets>
</assembly>
```

Las claves de esta configuración son las siguientes:

* El valor del campo `id` ha de coincidir con el especificado en la configuración del *plugin* `maven-assembly-plugin` mostrada anteriormente.
* El valor del campo `format` corresponderá con el `type` utilizado para hacer referencia a la dependencia en el proyecto que la consuma.
* En caso de querer que los ficheros escogidos por los filtros queden directamente en la raíz del fichero **zip** se deberá especificar el campo `includeBaseDirectory` a `false`. En caso contrario el proceso de ensamblado creará un directorio base con el nombre del artefacto donde incluirá todo el contenido.
* En el ejemplo se incluye el directorio `test-data` ubicado en el directorio raíz del proyecto y todo su contenido dentro de un directorio con el mismo nombre dentro del fichero **zip**.

En la [documentación del *plugin*][maven-assembly-plugin] se pueden consultar opciones adicionales para el filtrado de contenidos y construcción del fichero comprimido resultante.

#### Consumo del artefacto zip

Para consumir el artefacto de tipo ZIP generado en el paso anterior de forma que los recursos que contiene estén disponibles para su uso en un proyecto **Maven** cualquiera, será necesario añadir en el fichero `pom.xml` la dependencia a éste mediante las coordenadas proporcionadas por su `groupId` y el `artifactId`:

```xml
. . .
<dependencies>
	<dependency>
		<groupId>com.bitsmi</groupId>
		<artifactId>maven-zip-artifact</artifactId>    
		<version>1.0.0-FINAL</version>
		<classifier>resources</classifier>
		<type>zip</type>		
	</dependency>
</dependencies>
. . .
```

Hay que prestar atención a los valores de los campos `classifier` y `type` ya que corresponden con los valores especificados en el `id` y el `format` especificados durante la operación de `assembly` del artefacto **zip**. En este caso el `scope` de la dependencia es `compile` dado que se quieren incluir los recursos en el artefacto final, pero también se puede especificar el `scope test` en caso de que sólo se vayan a utilizar durante la fase de test del módulo y no se incluyan en el artefacto final.

A diferencia de otro tipo de dependencias como los **jar**, que **Maven** incluye directamente en el *classpath* de compilado, las dependencias de tipo **zip** no tienen una acción especifica asignada. Por esto hay que especificar qué hacer con ellas. Lo más comodo es descomprimir el contenido del **zip** en algún directorio controlado y, si se quiere, añadirlo a los directorios gestionados por **Maven** en caso de que se vayan a incluir en el artefacto final. 

Para ello se puede utilizar el *plugin* de **Maven** `maven-dependency-plugin` de la siguiente manera en el `pom` del proyecto:

```xml
. . .
<build>
	<plugins>
		<plugin>
			<groupId>org.apache.maven.plugins</groupId>
			<artifactId>maven-dependency-plugin</artifactId>
			<executions>
				<execution>
					<id>unpack-zip-artifacts</id>
					<goals>
						<goal>unpack-dependencies</goal>
					</goals>
					<phase>generate-resources</phase>
					<configuration>
						<outputDirectory>${project.build.directory}/zip-resources</outputDirectory>							
						<!--<includeClassifiers>resources</includeClassifiers>-->
						<includeTypes>zip</includeTypes>							
					</configuration>
				</execution>
			</executions>
		</plugin>
	</plugins>
</build>
. . .
```

Las claves de esta configuración del *plugin* son las siguientes:

* La `phase` especificada debe ser la apropiada para que el *plugin* descomprima la dependencia en el momento indicado. En el ejemplo se realiza durante `generate-resources` para que los recursos estén disponibles al iniciar la construcción del `package`. Si utiliza la dependencia sólo en la fase de test, se puede utilizar la `phase generate-test-resources`.
* El campo `outputDirectory` especifica la ubicación donde se descomprimirán las dependencias, en este caso dentro de un directorio dentro de `target`. De esta manera, junto con la configuración del `resource` asociado se consigue que **Maven** tenga en cuenta estos ficheros para el resto de operaciones (test, generación del `package`). La configuración de este `resource` se puede encontrar más abajo.
* Los artefactos sujetos a ser descomprimidos en el directorio especificado se pueden filtrar a través de las opciones de configuración del *plugin*. En este caso, las opciones `includeClassifiers` y `includeTypes` permiten filtrar las dependencias según su `classifier` o `type` para incluir en el proceso sólo las que corresponda. Se pueden especificar múltiples valores separados con comas. 

En la [documentación del *plugin*][maven-dependency-plugin] se pueden consultar el resto de opciones de filtrado.

Para incluir el contenido descomprimido en los recursos que gestiona automáticamente **Maven** se puede incluir en la configuración de los `resources` del `pom` del proyecto.

**Recursos disponibles en el artefacto final**

```xml
. . .
build>
	<resources>	
		<!-- Unzipped resources -->
		<resource>
			<directory>${project.build.directory}/zip-resources</directory>
			<filtering>true</filtering>
		</resource>
	</resources>
</build>
. . .
```

**Recursos disponibles sólo para Test**

```xml
. . .
<build>
	<testResources>	
		<!-- Unzipped resources -->
		<testResource>
			<directory>${project.build.directory}/zip-resources</directory>
			<filtering>true</filtering>
		</testResource>
	</testResources>
</build>
. . .
```

En caso que el artefacto final sea de tipo **war** será posible añadir el contenido dentro del mismo utilizando el plugin `maven-war-plugin` para especificar un `webResource`:

```xml
. . .
<build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-war-plugin</artifactId>
        <version>3.3.0</version>
        <configuration>
          <webResources>
            <resource>              
              <directory>${project.build.directory}/zip-resources</directory>
            </resource>
          </webResources>
        </configuration>
      </plugin>
    </plugins>
</build>
. . .
```

En el [siguiente enlace][maven-webresources] se puede ver un ejemplo completo de como incluir un directorio externo como contenido de un fichero **war**.

## Gestión de paquetes npm mediante Maven

Uno de los usos posibles del mecanismo expuesto en este artículo es el de poder gestionar paquetes **npm** locales a partir de dependencias de **Maven**. Esto es útil si se necesita una manera de distribuir de forma local este tipo de paquetes sin pasar por repositorios externos como http://www.npmjs.com u otros similares e incluirlos en el proceso de construcción de aplicaciones web basadas en Java. 

Como contrapartida, al no tratarse de un mecanismo estándar de gestión de dependencias para proyectos basados en **npm** dificulta el gestión y resolución de las mismas, por lo que sería apropiado sólo en casos en los que el grafo de dependencias locales no es muy complejo.

A modo de ejemplo, se propone el siguiente caso: 
- Un proyecto web Java construido con **Maven** necesita para su *frontend* javascript un paquete **npm** propio. 
- Este paquete implementa una serie de componentes basados en dependencias externas que se pueden obtener del repositorio central http://www.npmjs.com pero no se quiere publicar el paquete local en dicho repositorio, si no que se pretende utilizar un repositorio **Maven** local para ello, como pueden ser **Sonatype Nexus** o **Apache Archiva**.

#### Configuración del paquete npm local

La configuración base del paquete **npm**, es decir, el contenido de su fichero `package.json` de definición, se mantiene igual que si no se integrara con **Maven**. 

En él se define el identificador del paquete, la versión que implementa, las dependencias que necesita... 

Como en este caso no hay ninguna otra dependencia local que afecte a este paquete, el contenido podría ser similar al siguiente:

```json
{
  "name": "@bitsmi/custom-js-module",
  "version": "1.0.0",
  "description": "Bitsmi custom JS module",
  "module": "./src/main/index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "bitsmi",
  "license": "ISC",
  "devDependencies": {
    
  },
  "dependencies": {
    "axios": "^0.19.0",
    "rxjs": "^6.5.2",
    "vue": "^2.6.10"
  }
}
```

Para poder publicar este paquete en el repositorio **Maven**, será necesario crear una configuración de ensamblaje como se ha expuesto en apartados anteriores. 

Para ello será necesario crear un descriptor `pom` para el proyecto y un fichero de ensamblaje:

**pom.xml**

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                             http://maven.apache.org/maven-v4_0_0.xsd">
    <modelVersion>4.0.0</modelVersion>
	
	<groupId>com.bitsmi</groupId>
	<artifactId>custom-js-module</artifactId>
	<name>Bitsmi custom JS module</name>
	<packaging>pom</packaging>
	<version>1.0.0</version>	
	
	<build>
		<plugins>
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-assembly-plugin</artifactId>
				<executions>
					<execution>
						<id>resources</id>
						<goals>
							<goal>single</goal>
						</goals>
						<phase>package</phase>
						<configuration>
							<descriptors>
								<descriptor>/assembly/resources.xml</descriptor>
							</descriptors>
						</configuration>
					</execution>
				</executions>
			</plugin>
		</plugins>
	</build>
</project>
```

**resources.xml**

```xml
<assembly xmlns="http://maven.apache.org/plugins/maven-assembly-plugin/assembly/1.1.2" 
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xsi:schemaLocation="http://maven.apache.org/plugins/maven-assembly-plugin/assembly/1.1.2 http://maven.apache.org/xsd/assembly-1.1.2.xsd">
	<id>resources</id>
	<formats>
		<format>zip</format>
	</formats>
	<baseDirectory>${project.artifactId}</baseDirectory>
	<fileSets>
		<fileSet>
			<directory>${project.basedir}/src</directory>
			<outputDirectory>/src</outputDirectory>			
		</fileSet>		
		<fileSet>
			<includes>
				<include>package.json</include>
			</includes>
			<outputDirectory>/</outputDirectory>			
		</fileSet>		
	</fileSets>
</assembly>
```

El contenido que hay que incluir en el fichero **zip** será el descriptor del módulo `package.json` y el directorio con los fuentes del paquete `src/`. Dicha selección de contenidos se realiza en las secciones `<fileset>` de la configuración de ensamblaje. Adicionalmente, se dispone que este contenido quede dentro de un directorio de primer nivel con nombre correspondiente al `artifactId` del proyecto **Maven**. Esto se hace para que al descomprimir la dependencia en el proyecto consumidor, se produzca una separación en caso que este consuma varias dependencias de este tipo.

Con la configuración del proyecto **Maven**, la publicación realizada mediante los comandos `mvn install` o `mvn deploy` producirá un artefacto con coordenadas 
- `groupId: com.bitsmi`
- `artifactId: custom-js-module` 
- `version: 1.0.0`
- `classifier: resources`
- `type: zip`.


#### Configuración del proyecto web java

Para incluir el módulo configurado en el apartado anterior en el proyecto web java, es necesario incluir las coordenadas de éste en la definición de dependencias del descriptor `pom` del proyecto:

```xml
. . .
<dependencies>
	<dependency>
		<groupId>com.bitsmi</groupId>
		<artifactId>custom-js-module</artifactId>
		<version>1.0.0</version>
		<classifier>resources</classifier>
		<type>zip</type>		
	</dependency>
</dependencies>
. . .
```

Y configurar la extracción de los recursos en un directorio específico:

```xml
<plugins>
	<plugin>
		<groupId>org.apache.maven.plugins</groupId>
		<artifactId>maven-dependency-plugin</artifactId>
		<executions>
			<execution>
				<id>unpack-zip-artifacts</id>
				<goals>
					<goal>unpack-dependencies</goal>
				</goals>
				<phase>generate-resources</phase>
				<configuration>
					<outputDirectory>${project.basedir}/target/local_node_modules</outputDirectory>							
					<includeClassifiers>resources</includeClassifiers>								
				</configuration>
			</execution>
		</executions>
	</plugin>
</plugins>
```

En este caso se seleccionarán las dependencias con `classifier: resources` para ser descomprimidas en el directorio `target/local_node_modules`. En este caso sólo se dispone de una dependencia con este `classifier`, pero en caso que haya otras con el mismo valor que no se quiera incluir en el proceso, se deberá ampliar el filtro mediante las [diferentes opciones del *plugin*][maven-dependency-plugin].

El último paso a realizar para completar el proceso es especificar en la definición de dependencias de la configuración **nodejs** asociada al proyecto web java cómo debe localizar el contenido del paquete local para su resolución. En el fichero `package.json` se deberá incluir la dependencia de la siguiente manera:

```json
"dependencies": {
    "@bitsmi/custom-js-module": "file:target/local_node_modules/custom-js-module",
}
```

Con esta configuración se consigue que la versión del paquete local sea gestionada únicamente mediante la dependencia especificada en **Maven** ya que en caso de modificarla, el nuevo contenido quedará siempre en el mismo directorio final para que **nodejs** pueda resolverla.

## Referencias

* [Referencia *plugin* Maven Assembly][maven-assembly-plugin]
* [Referencia *plugin* Maven Dependency][maven-dependency-plugin]
* [Ejemplo utilización WebResources][maven-assembly-plugin]

[//]: # (Links)
[maven-assembly-plugin]:https://maven.apache.org/plugins/maven-assembly-plugin/single-mojo.html
[maven-dependency-plugin]:https://maven.apache.org/plugins/maven-dependency-plugin/unpack-dependencies-mojo.html
[maven-webresources]:https://maven.apache.org/plugins/maven-war-plugin/examples/adding-filtering-webresources.html

