---
author: Antonio Archilla
title: OCP11 - Services in a Modular Application
date: 2021-08-28
categories: [ "java", "ocp-11-17" ]
tags: [ "ocp-11", "ocp-17" ]
layout: post
excerpt_separator: <!--more-->
---

Since **Java 6** the Java platform provides a mechanism to implement dynamic service loading. Starting from **Java 9**, it is possible to implement this mechanism together with **JPMS**. 

In this post we will expose the way to implement a modular service.  

<!--more-->

## Dynamic service loading

In a common **dynamic service loading** setup there are **4 main parts**: 
1. **service definition**. 
2. **concrete implementations**. 
3. **away to locate this implementations**. 
4. a **client part** that uses the service. 

The **service** part is composed by the **definition** and the **service location mechanism**, while the **concrete implementations** and the **consumer** are not part of the service. 

![](/assets/posts/java/ocp-11-17/2021-08-28-OCP11-services_in_modular_application_fig1.png)

Detailed explanation of each section:
- **Service Provider Interface** or **SPI**: Refers to the contract defining service operations and it's related to support classes. While the contract is usually defined by an interface, it may also be defined by a **abstract class**.

- **Service Locator**: It's a mechanism that provides a way to look up for service implementations of an **SPI**. In other words, classes that implement the service interface. Java API provides the `java.util.ServiceLoader` class that helps to perform this lookup. The lookup call may be expensive, so it is best to cache the obtained results.

- **Consumer** or **Client**: Refers to the class that uses a service obtained through **service locator**. 

- **Service Provider**: Refers to the concrete implementation of a **service provider interface**. It is possible to have multiple implementations of the same service.

In a non modular application, the way in which the association of the **SPI** and its **implementations** is done is using a file inside **service provider**'s `META-INF/services` folder. For example, if we have the `sample.spi.ILanguageTranslationService` interface and the `sample.provider.EnglishTranstationServiceImpl` class that implements it, we will have to create the `META-INF/services/sample.spi.ILanguageTranslationService` file in the **service provider project** with the following content:

```
sample.provider.EnglishTranstationServiceImpl
``` 

If a **service provider** provides multiple implementations of the same service, we have to add each of them in a new line of the file:

```
sample.provider.EnglishTranstationServiceImpl
sample.provider.GermanTranstationServiceImpl
``` 

In a modular application, the components described above are usually implemented in different modules, but in some cases the **service locator** and the **consumer** may be on the same module. The association of the **SPI** and its **implementations** is done in **service provider**'s module definition (`module-info.java`). See next section for details.


## Modular service implementation

In this section you can find an example of modular service implementation. The whole code can be found at [Bitbucket repository](https://bitbucket.org/bitsmi/ocp11/src/master/t6-modules/service/).

This example implements a translation service that is able to translate a given word between 2 languages, selecting the "translator" between 2 service implementations according to the translation target language. 

The implementation defines 3 modules as follows:

![](/assets/posts/java/ocp-11-17/2021-08-28-OCP11-services_in_modular_application_fig2.png)

As we can see in this example, there is only one **service provider** module. In a real case, there can be multiple modules providing different implementations for the service. The **consumer** and the **service locator** are also placed in the same module because it is a very simple example, but as we said before, they can be placed in different modules. 

#### Service provider interface

Corresponding to the `ocp11-t6-service-spi` module in the example, it defines the `ILanguageTranslationService` interface that will be implemented by the **service providers**.

```java
package com.bitsmi.ocp11.t6.service.spi;

import com.bitsmi.ocp11.t6.service.spi.dto.TranslationDto;

public interface ILanguageTranslationService 
{
	public String getLanguage();
	
	public TranslationDto translate(String srcLanguage, String word);
}

```

Its module definition exports the required packages, where the interface and support classes are defined to make them available to the other modules:

```java
module com.bitsmi.ocp11.t6.service.spi 
{
	exports com.bitsmi.ocp11.t6.service.spi;
	exports com.bitsmi.ocp11.t6.service.spi.dto;
}
```	

#### Service provider

Corresponding to the `ocp11-t6-service-impl` module in the example, it contains 2 implementations of the translation service that will be available to clients: `EnglishTranstationServiceImpl` and `GermanTranstationServiceImpl`. The module definition for the service provider specifies the association of the interface and the implementations in `module-info.java` file using the `provides` statement:

```java
import com.bitsmi.ocp11.t6.service.impl.EnglishTranstationServiceImpl;
import com.bitsmi.ocp11.t6.service.impl.GermanTranslationServiceImpl;
import com.bitsmi.ocp11.t6.service.spi.ILanguageTranslationService;

module com.bitsmi.ocp11.t6.service.impl 
{
	requires com.bitsmi.ocp11.t6.service.spi;
	
	provides ILanguageTranslationService with EnglishTranstationServiceImpl, GermanTranslationServiceImpl;
}
```

**Multiple service implementations are separated using the commas**. 

It is also required to include the `required` statement with the **service provider interface** module that contains the service definition. 

It is not required to export the "**impl**" package because services implementations are specified through `provides` statements.


#### Service locator

Included as part of `ocp11-t6-service-impl` module in the example, the class `com.bitsmi.ocp11.t6.service.consumer.ServiceLocator` shows how to use the `ServiceLoader` provided by the Java API to retrieve all implementations available at runtime:

```java
Map<String, ILanguageTranslationService> cache = ServiceLoader.load(ILanguageTranslationService.class)
				.stream()
				.map(Provider::get)
				.collect(Collectors.toMap(ILanguageTranslationService::getLanguage, Function.identity()));
```

The results provided by `ServiceLoader` API are compatible with **Java's Stream API**, so they can be manipulated for filtering, or indexing the retrieved implementations. 

In the example, these are indexed according to its language to make easier to choose the required implementation in the client code.

The module definition of a **service locator** must contain a `uses` statement for the service definition and `requires` statements for both **SPI** and **service provider** modules so it can access to the interface and its implementations.

```
import com.bitsmi.ocp11.t6.service.spi.ILanguageTranslationService;

module com.bitsmi.ocp11.t6.service.impl 
{
	// Require both service provider interface and service provider modules
	requires com.bitsmi.ocp11.t6.service.spi;
	requires com.bitsmi.ocp11.t6.service.impl;
	
	uses ILanguageTranslationService;
}
```

**NOTE**: As the **service locator** is integrated into **consumer**'s code in this example, they share the same `module-info.java` definition.

#### Consumer

Included as part of `ocp11-t6-service-impl` module in the example, test implemented in class `com.bitsmi.ocp11.t6.service.consumer.test.TranslationTestCase` uses the `ServiceLocator` implemented to retrieve the required service implementation and perform a word translation:

```java
. . .
ILanguageTranslationService translationService = ServiceLocator.getInstance().getLanguageTranslationService("English");
// Input: source language and word
TranslationDto result = translationService.translate("Spanish", "Casa");
// Result is "House"
. . .

```

Generally speaking, it is mandatory that **consumer** module definition contains the `required` statements for **SPI** and **service locator** modules. 

In the example, as the **service locator** is already found in the same module, the **service locator** statement is not needed but it's still needed to include **service locator**'s `requires` and `uses` statements, so the module definition will be the same as that described in the previous section.

```java
import com.bitsmi.ocp11.t6.service.spi.ILanguageTranslationService;

module com.bitsmi.ocp11.t6.service.impl 
{
	// Require both service provider interface and service provider modules
	requires com.bitsmi.ocp11.t6.service.spi;
	requires com.bitsmi.ocp11.t6.service.impl;
	
	uses ILanguageTranslationService;
}
```

If **consumer** and **service locator** were in two different modules, the definition would include only `required` statements for **SPI** and **service locator** modules because this one will grant access to service implementations:

```java
import com.bitsmi.ocp11.t6.service.spi.ILanguageTranslationService;

module com.bitsmi.ocp11.t6.service.consumer 
{
	// Require both service provider interface and service locator modules
	requires com.bitsmi.ocp11.t6.service.spi;
	requires com.bitsmi.ocp11.t6.service.locator;
}
```
 
