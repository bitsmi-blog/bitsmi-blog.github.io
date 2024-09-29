---
author: Antonio Archilla
title: Gestión de dependencias Maven mediante la librería Aether
date: 2016-03-26
categories: [ "references", "java", "libraries" ]
tags: [ "java", "maven", "aether" ]
layout: post
excerpt_separator: <!--more-->
---

**Aether** es una librería Java que permite integrar en cualquier aplicación Java el mecanismo de resolución de dependencias de **Maven**. 
Se trata de una forma mucho más simple de hacerlo que integrar la distribución completa de **Maven** o incrustar **Plexus** dentro de la aplicación.

La API de **Aether** provee funcionalidades para:

- Definir y gestionar de un repositorio local de artefactos.
- Recuperar artefactos desde múltiples repositorios remotos para su consumo local.
- Publicar artefactos locales en múltiples repositorios remotos.
- Resolver las dependencias transitivas de los artefactos.
- Inspeccionar el grafo de dependencias de un artefacto.

En este post se exponen ejemplos concretos de implementaciones para las funcionalidades anteriormente mencionadas.

<!--more-->

## Conceptos y arquitectura de Aether

La arquitectura interna de **Aether** está basada en la definición una estructura de componentes configurable que permita adaptar el sistema a su uso final en diferentes entornos y 
ampliarlo con nuevas implementaciones en caso de ser necesario.Mediante la definición de interfaces que definen el contrato que deben cumplir los conectores, es posible configurar 
diferentes implementaciones en el sistema según el uso que se quiera hacer. **Aether** dispone de las siguientes interfaces para definir diferentes conectores:

- `RepositoryConnector`: Componente responsable de la lógica de descarga y envío de los artefactos y los meta datos hacia un repositorio remoto. 
Su configuración en el sistema se hará través de la definición de la factoría `RepositoryConnectorFactory`.
- `Transporter`: Componente responsable de transferir recursos entre el repositorio remoto y el  sistema local a través de diferentes protocolos. 
Por ejemplo, se disponen de diferentes implementaciones para la transferencia a través de **FTP**, **HTTPS**, **sistema de ficheros local**, etc. 
Su configuración en el sistema se hará través de la definición de la factoría `TransporterFactory`. 
- `RepositoryLayout`: Componente responsable de definir la estructura interna de directorios de los repositorios **Maven** remotos accesibles vía URI. 
Su configuración en el sistema se hará a través de la definición de la factoría `RepositoryLayoutFactory`.

Existen dos mecanismos básicos para configurar los componentes del sistema:

- **Utilizar el sistema de `ServiceLocator`**: **Aether** proporciona mecanismos para la consulta y configuración de conectores dispuestos en diferentes componentes del *classpath* 
de la aplicación mediante el patrón `ServiceLocator`. En los ejemplos de este post, se utilizará esta manera de configurar el sistema, ya que simplifica el código resultante. 
En la sección de **Configuración e inicialización** de este mismo post se puede ver cómo se utiliza esta API para llevar a cabo esta tarea.
- **Utilizar un sistema de inyección de dependencias (Guice)**: Los componentes de **Aether** llevan configuradas de serie anotaciones de tipo `javax.inject` 
definidas en la **JSR-330** y un módulo **Guice** preparado para su uso en el que se encuentran configuradas las implementaciones por defecto de los diferentes componentes. 
También es posible utilizar *frameworks* como **Eclipse SISU**, basado en **Guice**, mediante el cual se pueden enlazar estos componentes de forma automática a través del escaneo automático del *classpath*, 
en vez de tener que definir los módulos **Guice** de forma manual. La Wiki de **Aether** dispone de varios ejemplos de cómo configurar dichos componentes en los 2 casos.

Una vez configurado el sistema con los diferentes conectores, la API de **Aether** permitirá realizar todo tipo de operaciones contra el sistema de repositorios mediante todo tipo de peticiones. 
Por ejemplo, algunos de los tipos que proporciona:

- `CollectRequest`: Permite descargar las dependencias transitivas de un artefacto y construir su grafo de dependencias.
- `DependencyRequest`: Permite resolver las dependencias transitivas de un artefacto. Se puede usar en conjunción con una CollectRequest obtenerlas.
- `MetadataRequest`: Permite resolver los meta datos de un artefacto en el repositorio remoto o local.
- `VersionRangeRequest`: Permite resolver rangos de versiones en los artefactos.

En el apartado de **Operaciones** de este mismo post se podrán encontrar diferentes ejemplos de utilización de estas.
En la mayoría de estas operaciones interviene el uso de descriptores de artefactos **Maven**. **Aether** utiliza la siguiente notación 
para crear los identificadores de artefacto que se utilizan en las operaciones en las que es necesario trabajar con este tipo de elementos.

```
<groupId>:<artifactId>[:[:]]:<version>
```

Corresponden a los campos homónimos de las dependencias que se configuran en los ficheros `pom.xml` de **Maven** y admiten los mismos tipos de valores. 
Los campos extensión y *classifier*, como en el caso de los ficheros `pom.xml` son opcionales.

## Configuración e inicialización

La siguiente lista muestra las dependencias **Maven** para el uso de la librería y de los conectores necesarios en la mayoría de casos. Los descriptores de cada una se encuentra 
especificados en formato `<group id>:<artifactId>` para ahorrar espacio. No se incluyen todas las dependencias transitivas. 
Las versiones utilizadas para elaborar los ejemplos que se muestran en este post, se pueden consultar directamente en el fichero `pom.xml` del proyecto de código anexo:

- `org.eclipse.aether:aether-api`: Contiene las interfaces que han de utilizar las aplicaciones que hagan uso de **Aether**. El punto de entrada a toda la infraestructura es org.eclipse.aether.RepositorySystem.
- `org.eclipse.aether:aether-impl`: Implementación interna de la API expuesta en el módulo aether-api
- `org.eclipse.aether:aether-util`: Colección varias utilidades y componentes para gestionar el sistema de repositorios
- `org.eclipse.aether:aether-connector-basic`: Interfaces de conexión a los repositorios a través de los conectores. Este componente por si sólo no tiene capacidad para realizar ninguna operación y necesita de las implementaciones concretas para cada protocolo (Módulos de transporte).
- `org.eclipse.aether:aether-transport-file`: Módulo de transporte que añade soporte para el acceso a repositorios a través del sistema de ficheros.
- `org.eclipse.aether:aether-transport-http`: Módulo de transporte que añade soporte para el acceso a repositorios a través de **http** y **https**
- `org.eclipse.aether:aether-transport-wagon`: Módulo de transporte que habilita la inclusión de diferentes proveedores basados en **Maven Wagon** para la conexión a repositorios a través de varios protocolos
- `org.apache.maven:maven-aether-provider`: Provee de funcionalidades para manipular descriptores de artefactos Maven y meta datos provistos en los ficheros **POM** y otras fuentes del repositorio **Maven**.
- `org.apache.maven.wagon:wagon-ssh`: Complementa al módulo aether-transport-wagon añadiendo soporte para el acceso a través de los protocolos **SCP** y **SFTP**

Una vez resueltos los componentes de Aether para su uso, se debe inicializar el sistema.Supongamos que se quiere gestionar un entorno básico bastante común formado por un repositorio de 
artefactos local ubicado en el sistema de ficheros y se quiere poder acceder a un repositorio central, como podría ser Maven Central, que alimente el repositorio local con los artefactos 
que este no contenga.

Todo el código que se mostrará a continuación se puede consultar en el proyecto de código anexo.

Concretamente los extractos de código se pueden ver en su contexto original en la clase `snippets.tools.aether.service.MavenRepositoryService`.

Como se ha explicado en el apartado de conceptos y arquitectura de la librería, **Aether** está construido de forma modular en la que cada componente provee de los mecanismos necesarios 
para acceder a un repositorio a través de diversos protocolos.Se utiliza el mecanismo de servicios de Java para localizar y «atar» las diferentes definiciones de las funcionalidades 
con las implementaciones finales.

Si se utiliza la clase org.eclipse.aether.impl.DefaultServiceLocator que proporciona el componente **Aether-Impl** muchas de las configuraciones necesarias 
ya estarán pre-inicializadas pero será necesario realizar algunos ajustes adicionales:

- Se inicializa el sistema básico de conectores con la implementación básica que proporcionará la mayoría de funcionalidades necesarias, 
en este caso el componente `org.eclipse.aether.connector.basic.BasicRepositoryConnectorFactory`. 
Será necesario especificar qué conectores se utilizaran para acceder a los diferentes repositorios.
- En el caso de este ejemplo, se usará uno de tipo `org.eclipse.aether.transport.file.FileTransporterFactory` para acceder al repositorio local 
y otro `org.eclipse.aether.transport.http.HttpTransporterFactory` para acceder al repositorio remoto.

```java
DefaultServiceLocator locator = MavenRepositorySystemUtils.newServiceLocator();
locator.addService(RepositoryConnectorFactory.class, BasicRepositoryConnectorFactory.class);
locator.addService(TransporterFactory.class, FileTransporterFactory.class);
locator.addService(TransporterFactory.class, HttpTransporterFactory.class);
```

- También será posible especificar un gestor para tratar los errores. En este caso, sólo se registrará un evento de log, pero esto añade la posibilidad de implementar gestiones 
mas complejas en caso de que se produzca un error.

```java
locator.setErrorHandler(new DefaultServiceLocator.ErrorHandler()
{
        @Override
        public void serviceCreationFailed(Class type, Class impl, Throwable exception)
        {
         log.error("ERROR: {}", exception.getMessage(), exception);
        }
} );
```

- Se inicializa el sistema de repositorios y especifica la ubicación del repositorio local (ruta al directorios raiz) y la url del repositorio remoto

```java
RepositorySystem system = locator.getService(RepositorySystem.class);
DefaultRepositorySystemSession session = MavenRepositorySystemUtils.newSession();
   
// Especificación del repositorio local que se utilizará a través de la ruta al directorio raíz
LocalRepository localRepository = new LocalRepository(localRepositoryLocation);  session.setLocalRepositoryManager(system.newLocalRepositoryManager(session, localRepository));
     
// Especificación del repositorio remoto que se utilizará (Maven central)
RemoteRepository remoteRepository = new RemoteRepository.Builder("central", "default", "http://central.maven.org/maven2/").build();
```

## Operaciones

Una vez se ha configurado el contexto necesario para la utilización del sistema de resolución, será posible realizar acciones como las que se exponen a continuación.
Todas están contenidas en el código de ejemplo adjunto en la sección de enlaces de interés del post.

El proyecto de ejemplo consta de 2 clases principales:

- `MavenRepositoryService`: Implementa las diferentes operaciones de gestión del repositorio **Maven** a través de **Aether**.
- `MavenRepositoryTestCase`: Contiene casos de prueba que utilizan las operaciones definidas en `MavenRepositoryService` para mostrar su funcionamiento. 

### Descargar un artefacto desde un repositorio remoto junto con sus dependencias

A partir de un descriptor de artefacto **Maven** se podrán descargar en el repositorio local dicho artefacto y sus dependencias. En el siguiente código se muestra cómo realizarlo.

```java
String artifactDescriptor = "org.eclipse.aether:aether-impl:1.0.0.v20140518";
 
// Se construye el artefacto a partit de su descriptor
Artifact artifact = new DefaultArtifact(artifactDescriptor);
// Sólo se resolverán las dependencias de compilación
DependencyFilter classpathFlter = DependencyFilterUtils.classpathFilter(JavaScopes.COMPILE);
 
// Se crea la petición con el artefacto principal que se quiere descargar en el repositorio local
CollectRequest collectRequest = new CollectRequest();
collectRequest.setRoot(new Dependency(artifact, JavaScopes.COMPILE));
// Es necesario indicar el repositorio remoto para que descargue el artefacto en caso de que no se encuentre en el local
collectRequest.setRepositories(Arrays.asList(remoteRepository));
 
// Se crea la petició de resolución de dependencias a partir de la petición del artefacto creada anteriormente y el filtro
DependencyRequest dependencyRequest = new DependencyRequest(collectRequest, classpathFlter);
// Se resuelve y descargan la dependencias a través de la session creada anteriormente en el "setUp"
List artifactResults = system.resolveDependencies(session, dependencyRequest).getArtifactResults();
 
// Se listan los resultados de la descarga
for(ArtifactResult artifactResult:artifactResults){
    log.info(artifactResult.getArtifact() + " resuelto en " + artifactResult.getArtifact().getFile());
}
```

A través de la API del objeto `Artifact` obtenido en el resultado será posible obtener toda la información necesaria referente al artefacto **Maven**, 
cómo por ejemplo, la **versión base**, si se trata de una **versión Snapshot**, el **clasificador**, etc.

### Resolver si un artefacto está instalado en el repositorio local y obtener su ruta de disco

A partir de un descriptor de artefacto **Maven** se identificará si este se ha descargado previamente en el repositorio local configurado y se podrá obtener su ubicación en disco. 
Este es un ejemplo de cómo utilizar el manager del sistema de repositorios mediante su API para realizar consultas sobre este.

```java
String artifactDescriptor = "org.eclipse.aether:aether-impl:1.0.0.v20140518";
 
// Se construye el artefacto a partir de su descriptor
Artifact artifact = new DefaultArtifact(artifactDescriptor);
 
String repositoryLocation = localRepository.getBasedir().getAbsolutePath();
// Se obtiene el path relativo del artefacto dentro del repositorio local y se concatena con la ruta raíz de este para construir la ruta completa 
String artifactRelativePath = session.getLocalRepositoryManager().getPathForLocalArtifact(artifact);
File file = new File(repositoryLocation + "/" + artifactRelativePath);
if(file.exists()){
 // El artefacto existe en el repositorio local
        String ruta = file.getAbsolutePath();
        . . . 
}
else{
 // El artefacto no existe en el repositorio local
        . . . 
}
```

### Obtener una lista de las versiones disponibles de un artefacto

A partir de un descriptor de artefacto **Maven** se podrá realizar una consulta de la versión más alta disponible en el repositorio remoto, 
pudiendo especificar un rango de versiones para acotar la búsqueda en caso de ser necesario. La notación que se utiliza para describir estos rangos permite especificar límites inclusivos, 
mediante los caracteres `[` / `]` según sea límite inferior o superior, o exclusivos mediante `(` / `)`, pudiéndolo combinar en caso de ser necesario.
A continuación se muestra un ejemplo en el que se quiere resolver la versión más alta de un artefacto dentro del rango de versiones 0 exclusive – 2.0 inclusive:

```java
String artifactDescriptor = "org.eclipse.aether:aether-impl:(0,2.0]";
Artifact artifact = new DefaultArtifact(artifactDescriptor);
          
VersionRangeRequest request = new VersionRangeRequest();
request.setArtifact(artifact);
request.setRepositories(Arrays.asList(remoteRepository));
  
VersionRangeResult result = system.resolveVersionRange(session, request);
  
Version version = result.getHighestVersion();
log.info("Versión encontrada " + version.toString() + " en el repositorio " + result.getRepository(version));
```

## Posibles aplicaciones

La integración de estas funcionalidades en una aplicación abre la puerta a nuevas maneras de gestionar los componentes de esta. 
Por ejemplo, seria posible crear un mecanismo de plugins gestionados en un repositorio **Maven** remoto al que la aplicación pueda tener acceso. 
Seria posible implementar de forma sencilla las funcionalidades de instalación de plugins des de la misma aplicación, consulta de nuevas versiones y actualizaciones, 
sin tener que crear y mantener un protocolo para que la aplica. Si se combina con tecnologías que permitan la carga dinámica de clases, como por ejemplo **OSGI** o **JBoss Modules**, 
sería incluso posible instalar estos plugins en caliente desde la misma aplicación sin necesidad de reiniciarla.

## Enlaces de interés

- [Página principal de la librería Eclipse Aether](http://www.eclipse.org/aether/)
- [Maven The Complete Reference](http://books.sonatype.com/mvnref-book/reference/index.html)
- [POM Reference: Especificación de los ficheros POM de Maven](https://maven.apache.org/pom.html)
- [Repositorio público de los ejemplos](https://bitbucket.org/bitsmi/snippets/src/24ef1671ba65998903f46b70c107609a35606e52/tools/aether/?at=default)





