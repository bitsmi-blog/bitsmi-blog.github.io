---
author: Antonio Archilla
title: OCP11 - Understanding Modules
date: 2021-04-04
categories: [ "java", "ocp-11-17" ]
tags: [ "ocp-11", "ocp-17" ]
layout: post
excerpt_separator: <!--more-->
---

<br/>**Java Platform Module System** or **JPMS** was introduced in **Java 9** as a form of encapsulation package.

A **module** is a group of one or more packages and a `module-info.java` file that contain its metadata.

In other words it consists in a '**package of packages**'.

## Benefits of using modules:

While using modules in a Java 9+ application is *optional*, there are a series of benefits from using them:

* **Better access control:** Creates a fifth level of class access control that restricts packages to be available to outer code. Packages that are not explicitly exposed through `module-info` will be not available on modules external code. This is useful for encapsulation that allows to have truly **internal packages**.

* **Clear dependency management:** Application's dependencies will be specified in `module-info.java` file. This allows us to clearly identify which are the required modules/libraries.

* **Custom java builds:** **JPMS** allow developers to specify what modules are needed. This makes it possible to create smaller *runtime images* discarding JRE modules that the application doesn't need (AWT, JNI, ImageIO...).

* **Performances improvements:** Having an static list of required modules and dependencies at start-up allows JVM to reduce load time and memory footprint because it allows the JVM which classes must be loaded from the beginning.

* **Unique package enforcement:** A package is allowed to be supplied by only one module. **JPMS** prevents **JAR hell** scenarios such as having multiple library versions in the *classpath*.

The main **counterpart** is not all libraries have module support and, while it is possible it also makes more difficult to switch to a modular code that depends on this kind of libraries. For example, libraries that make an extensive use of **reflection** will need an extra configuration step because **JPMS** cannot identify and load classes at runtime.

<!--more-->

## Building modular applications

An application module usually is structured as it follows: 
* **/mods folder**: Contains the required third party modules as the **/lib** folder done in traditional Java applications.
* **/src folder**: Contains the source code of the module as a set of one or more packages. Usually this folder is renamed with the same name as the module.
* **/src/module-info.java file**: Module's metadata file containing its definition. It's placed in the root source code folder.

#### module-info.java file

The `module-info.java` file contains the description of current module's metadata. This includes:
1. the ability of mark packages as visible to outer modules
2. list a set of modules that will be required by the current module as dependencies 
3. configure **service providers** 
4. enable features like **reflection**

The following example describes an application formed by multiple modules:

* **mod.external**: A third party module that will provide some external functionality to the application.
* **mod.services**: The module that will provide the service layer for the application.
* **mod.application**: The top module and application's entry point.

```java
module mod.external
{
	exports com.foo.external.util;	// (1)
	exports com.foo.external.service;	// (2)
}
```

```java
module mod.services
{
	requires mod.external;	// (3)
	// requires transitive mod.external;	// (3.1)
	
	exports com.bar.service to mod.application;		//(4)
	
	// (5)
	uses com.foo.external.service.IExternalService;
	provides com.foo.external.service.IExternalService with com.bar.service.impl.ExternalServiceImpl;
	
	// (6)
	opens
}
```

```java
module mod.application
{
	requires mod.external; 	// (7)
	requires mod.services;
}
```

`export` statement allows outer modules to use the classes of the specified package by defining them as **visible**. 

By default, all module packages are hidden from the outside unless they are exported explicitly. 

In the example, `mod.external` marks packages `com.foo.external.util` and `com.foo.external.services` as visible on **(1)** and **(2)**. These packages can be used in `mod.services` requiring the `mod.external` module **(3)**. 

It's also possible to export packages to specific target modules **(4)** so only these modules can access to them. In this example, `com.bar.service` will only be visible to '*mod.application*'. **Multiple modules** can be specified separated by commas.

Modules can also be required in a transitive way as in **(3.1)**. By using the `transitive` keyword, modules depending on `mod.services` also acquire the ability to use `mod.external` exported packages because `mod.services` **also exports them transitively**.

These modules can optionally declare its dependency on `mod.external` in  addition to `mod.services`, but it's not necessary.

In this example, if statement **(3.1)** was included in place of **(3)**, statement **(7)** wouldn't be necessary. Take into account that requiring multiple times the same module will produce a compilation error. 

`uses` / `provides`**(5)** and `opens` **(6)** statements enables the use of the **service provider** mechanism and reflection, respectively.
**Note**: This features will be described in more detail in later posts.

In this example, `mod.application` module will be capable of consuming the following packages:

* com.foo.external.util
* com.foo.external.service
* com.bar.service

#### Classpath vs Module path

The **module path** of an application is the directory or directories that contain **modules**. To maintain backward compatibility from Java 9, applications can still make use of the **classpath** that will contain all non-modularized code. Application code can access any type in **classpath** exposed via standard java access modifiers, such as public. Public types defined inside **module path** aren't automatically available. Packages must in exported by the corresponding module.

#### Module types

A **named module** is a module containing a `module-info.java` file as described above and it's in the **module path**. A **named module** that is not in **module path** is not considered a **named module**.

Along the **named modules**, there are other *module types* that must be taken into consideration:

**System modules**
Corresponding to Java SE and JDK modules. These are:

Modules in JRE

| java.base | java.naming | java.smartcardio |
| java.compiler | java.net.http | java.sql |
| java.datatransfer | java.prefs | java.sql.rowset |
| java.desktop | java.rmi | java.transaction.xa |
| java.instrument | java.scripting | java.xml |
| java.logging | java.se | java.xml.crypto |
| java.management | java.security.jgss | &nbsp; |
| java.management.rmi | java.security.sasl | &nbsp; |

Modules only in JDK

| jdk.accessibility | jdk.jconsole | jdk.naming.dns |
| jdk.attach | jdk.jdeps | jdk.naming.rmi |
| jdk.charsets | jdk.jdi | jdk.net |
| jdk.compiler | jdk.jdwp.agent | jdk.pack |
| jdk.crypto.cryptoki | jdk.jfr | jdk.rmic |
| jdk.crypto.ec | jdk.jlink | jdk.scripting.nashorn |
| jdk.dynalink | jdk.jshell | jdk.sctp |
| jdk.editpad | jdk.jsobject | jdk.security.auth |
| jdk.hotspot.agent | jdk.jstatd | jdk.security.jgss |
| jdk.httpserver | jdk.localdata | jdk.xml.dom |
| jdk.jartool | jdk.management | jdk.zipfs |
| jdk.javadoc | jdk.management.agent | &nbsp; |
| jdk.jcmd | jdk.management.jfr | &nbsp; |

**Automatic modules**

An automatic module is a normal jar file placed on the **module path** without a `module-info.java` file. In that case the list of exported packages is set to be all packages in the jar file and it will have full access to everything on the module path and the whole classpath. 

The name of the module will be determined by the `Automatic-Module-Name` **MANIFEST** property or, if it's not declared, derived from the name of the JAR following these rules:
1. Remove file extension from jar file
2. Remove any version info from the end of the file name, including labels like `SNAPSHOT`, `RC`, `GA` and similar. E.G: commons`-1.0.0`, commons`-1.0.0-SNAPSHOT`
3. Replace characters others than letters and numbers by dots.
4. Replace any sequence of multiple dots with a single dot.
5. Remove dots if it's the first or last character
	
For exemple, the module name for a jar named `commons2-x-1.0.0-SNAPSHOT.jar` will be resolved after aplying the following rules: **(1)** `commons2-x-1.0.0-SNAPSHOT` -> **(2)** `commons2-x`-> **(3)** `commons2.x`

**Unnamed modules** 

For compatibility reasons, all code **on the classpath** is packaged up as a special **unnamed module** with no hidden packages and full access to the whole JDK. 
The packages in **unnamed module** can only be read by the **unnamed module**. **Unnamed module** is only present if the application is executed using the `--classpath` option.

#### Build and run the application
Since its first release, the JDK includes multiple tools to **compile** (`javac`), **package** (`jar`) and **run** (`java`) applications.

Now, with the **JPMS**, new tools are included as well as new options for existing ones, making it possible to all of them to work with modules.

**Compile modules**

`javac` includes some new options to manage module compilation. The common way to compile a module is executing the following command:

```sh
javac --module-path <path> --d <path> <classes to compile>
```

Where:
* `--module-path`, `-p`: **Location of module dependencies** JARs.
* `-d`: **Folder** where *.class files will be generated.
* **classes to compile**: **Sources to compile**. Multiple space separated sources can be specified and they can include wildcards. For example: `javac -p mods -d build src/com/bar/service/*.java src/com/bar/service/impl/*.java src/module-info.java`

**Package modules**

Modules can be packages using `jar` command as it follows:

```sh
jar --create --file=<jar file name> [--main-class <main class fully qualified name>] -C <path to build dir> .
```

Where:
* `--create`, `-c`: Indicates that a **jar will be created**.
* `--file`, `f`: The **jar file name**. Any directories you want the output JAR file to be under must already exist!.
* `-C`: Tells the jar command to **change directory to compiled module root directory** and then **include everything found in that directory** - **due to** the following **. argument** (*which signals "**current directory**"*).
* `--main-class`: Specifies the **fully qualified name** of the **entry point class of the jar file**.

**Run modules**

To run packaged modules with the `java` command line tool, the following commands can be used:

```sh
# Run from build folder
java --module-path <build folder> --module <module name>/<main class fully qualified name>
# Run from jar (without Main class specified in Manifest)
java --module-path <modules folder> --module <module name>/<main class fully qualified name>
# Run from jar (with Main class specified in Manifest)
java --module-path <modules folder> --module <module name>
```  

Where:
* `--module-path`, `-p`: **Location of modules**. Multiple **;** (Windows) or **:** (*nix) separated sources can be specified.
* `--module`, `-m`: **Module to execute**. If the module's jar `Manifest` doesn't spcified a **main class** it must be appended to the module name separated by **'/'**

**Inspecting modules**

Several mechanisms were added to JDK tools in order to **inspect** and **analyse module dependencies graph and resolution**, including new tools and new options to the existing ones.

##### `java` command options
* `--show-module-resolution`: Using this option when running a program with the `java` command **shows used modules in the execution**.
* `--list-modules`: **Lists application's observable modules without** actually **running** the **application**.
* `--describe-module`, `-d`: Lists module's **qualified exports** to an specific target module (**export .. to**), packages not exported (appearring as **contains** in the output), etc.

##### `jar` command options
* `--describe-module`, `-d`: similar to `javac`'s.

##### `jdeps` command options
Gives **information** about **dependencies within a module**.

It scans code in addition to `module-info` declarations so the listed results will include implicit dependencies (e.g. requires transient). 
The available options for `jdeps` includes:
* `--module-path`: **Location** of **module dependencies JARs**.
* `-summary`, `-s`: **Output summary info**. If not included, the output will contain the full information.
* `--jdk-internals`, `-jdkinternals`: List classes that use any internal unsupported API (`sun.*`). In the resulting list may also appear a suggestion to replace each use of the unsupported API.

##### `jlink` command options
**Packages** a **executable module** into an **standalone application**, *including only the needed dependency modules*.

The main use case of this tool is to **generate a JVM distribution** specially for an application that will only contain the needed JVM modules.
Its syntax is: 
```sh
	jlink --module-path <modules folder> --add-modules <local modules to include> --output <output folder>
```
Where:
* `--module-path`, `-p`: **Location of modules**. Multiple **;** (Windows) or **:** (*nix) separated sources can be specified. This parameter must contain the `%JAVA_HOME%\jmods` location which is where JDK core modules are located. e.g. `--module-path "mods;%JAVA_HOME%\jmods"`.
* `--add-modules`: Comma separated list of local modules to include.
* `--output`: Output folder where the resulting distribution will be generated.

##### `jmods` command options
Tool to create **JMOD files** and **list the content** of existing **JMOD files**. 

While modularized applications are still packaged as **JAR files**, some resources cannot be included in this JAR files, such as ***native libraries*** or ***resources*** for example. 

**JMOD** files are recommended only for package modules that contains this kind of stuff.

Its syntax is:
	```sh
	jmod (create|extract|list|describe|hash) [--class-path <path>][--cmds <path>][--config <path>] <file name>
	```
Where:
	* `create`: **Creates** a new JMOD archive file.
	* `extract`: **Extracts all** the **files** from the JMOD archive file.
	* `list`: **Prints** the names of **all** the **entries**.
	* `describe`:  **Prints** the module **details**.
	* `hash`: **Determines leaf modules** and **records the hashes of the dependencies** that directly and indirectly require them.
	* `--class-path`: On **jmod creation**, specifies the **location of application JAR files** or a **directory** containing classes to copy into the resulting **JMOD** file.
	* `--cmds`: On **jmod creation**, specifies the **location of native commands** to copy into the resulting **JMOD** file.
	* `--config`: On **jmod creation**, specifies the **location of user-editable configuration files** to copy into the resulting **JMOD** file.
	* `file name`: Specifies the **name of the JMOD file** to create or from which to retrieve information.


## Examples

* [Modules example on Bitbucket][plain-example]

[//]: # (Links)
[plain-example]:https://bitbucket.org/bitsmi/ocp11/src/master/appendix-a/modules/plain-project/
