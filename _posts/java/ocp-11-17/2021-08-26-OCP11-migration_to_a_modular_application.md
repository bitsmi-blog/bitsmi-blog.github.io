---
author: Antonio Archilla
title: OCP11 - Migration to a Modular Application
date: 2021-08-26
categories: [ "java", "ocp-11-17" ]
tags: [ "ocp-11", "ocp-17" ]
layout: post
excerpt_separator: <!--more-->
---

<br/>Following the [introductory post](/java/ocp-11-17/2021-04-04-OCP11-understanding_modules) of **Java Platform Module System** , also known as **JPMS**, this post exposes different strategies to migrate applications developed in Java as they can make use of it. This covers the cases where original application is based on a non compatible Java version (**< Java 9**) or it is compatible (**>=Java9**) but it was not originally implemented, since the use of this mechanism is fully optional.


## Migration strategies

The first step to perform in the migration of an application to the module system is to determine which modules / JAR files are present in an application and what dependencies exists between them. A very useful way to do so is through a hierarchical diagram where these dependencies are represented in a layered way. 

This will help giving an overview of the application's components and which one of them and in which order they can be migrated, identifying those which won't be able to adapt temporarily or definitively. 

The latter case can be given for example in third parties libraries that have stopped offering support and that will hardly become modules. This overview will help determine the migration strategy that will be carried out. 

Next, 2 migration mechanisms are exposed that respond to different initial situations.

<!--more-->

To illustrate the process in each of them, the following scenario is presented: 

It is intended to migrate an application composed of 3 JARs representing the different layers of the application: `Application`, `Services` and `Utils`. 

The following diagram shows the dependencies between these layers where `Application` depends on `Services` and `Utils` and `Services` depends on `Utils`:

![](/assets/posts/java/ocp-11-17/2021-08-26-OCP11-migration_to_a_modular_application_fig1.webp)

#### Bottom-Up migration strategy

In this strategy initially all JAR files that are part of the application will be located at its **classpath**. Then, following the steps described below, all of them can be migrated one by one to the **module path**.

The steps that are part of the process are the following:

1. Choose the project with the lowest position in dependencies hierarchy that has not yet been migrated to module.
2. Add the `module-info.java` file to the project. It is needed to add the required **export** statements to make current module packages available to hierarchy higher-level modules.
3. Move the migrated project as a **named module** from application's **classpath** to its **module path**.
4. Ensure that all not yet migrated modules remain as **unnamed modules** in application's **classpath**.
5. Repeat this process with the next lowest-level project in the hierarchy that is not migrated yet.

In this case, the migration process would be seen as follows:

![](/assets/posts/java/ocp-11-17/2021-08-26-OCP11-migration_to_a_modular_application_fig2.png)

The **Bottom-Up migration** strategy works best when you have the ability to modify any jar that has not yet been converted to module. 

It makes easier the migration of the projects that are at the top of the dependency diagram and encourages care in what is exposed to other modules. 

The modules of the lower levels of the hierarchy will be found in the **module path** without access to the **packages** of **unnamed modules** while these **unnamed modules** that have not yet been migrated and are located in the **classpath** will be able to access the **packages** located in both **classpath** and **module path**.


#### Top-Down migration strategy

In this strategy initially all JAR files that are part of the application will be located at its **module path**, so all non-migrated projects are treated as **automatic modules**. Then the steps to be done are the following:

1. Choose the higher-level project in the dependencies hierarchy that has not yet been migrated to module.
2. Add the `module-info.java` file to the project to transform it from a **automatic module** to a **named module**. 
	1. It is needed to add the necessary **export** statements to make current module packages available to other modules and the necessary **requires** statements that makes available other modules exposed packages to the current one. 
	2. In case of reference to a module not yet migrated, it should be done through its **automatic module name**. When these have been migrated, these references should be changed to their definitive module names.
3. Repeat this process with the next higher-level project in the hierarchy that is not migrated yet.

In this case, the migration process would be seen as follows:

![](/assets/posts/java/ocp-11-17/2021-08-26-OCP11-migration_to_a_modular_application_fig3.png)

The **Top-Down migration** strategy works best when you do not have the possibility of modularizing all the dependencies of the application, whether temporary or definitively (E.G. non-modularized third party dependencies). 

Although the lower dependencies of the application have not yet been modularized, the application itself can be converted into a module. **Named modules** that have already been migrated will be found in the **module path** with access to the entire code contained in the **automatic modules** that are also found in **module path**.


## Splitting a big project into multiple modules

The adaptation of the code of an application to the module system that requires the division of the basecode base in several modules implies series of restrictions. The most important one is that the definition of the resulting modules cannot contain direct or indirect **cyclical dependencies** between the modules.

For example, starting from an initial monolithic application for the management of a store that has the following packages:

- `user.info`: Provides operations to retrieve and manage user information. Uses `order` package to retrieve user's related orders.
- `user.notification`: Provides operations that allow notifying the user.
- `product.info`: Provides operations to retrieve and manage product information.
- `product.stock`: Provides operations to retrieve and manage product stocks.
- `order`: Provides operations to retrieve and manage orders. Uses `payment` package to perform the payment of user's purchase order.
- `payment`: Provides operations to manage and payments. Uses `user.notification` to send order details to the user.

An initial division of these packages in different modules can be made as it follows:

![](/assets/posts/java/ocp-11-17/2021-08-26-OCP11-migration_to_a_modular_application_fig4.webp)

In that case, the `user` module has a **cyclic dependency** through `order` and `payment` modules. This makes that `user` module cannot be compiled as **JPMS** don't allow this to happen.

A common way to solve this issue consists in the creation of an intermediate module which contains the shared code, so the cycle is broken. 

In the example, this is the `User notification shared` module that contains the code that must be accessible by `user` and `payment` modules. 

Remember that a package name can be only defined by a single module, so the new module's package is named `user.notification.shared` and not `user.notification` as this package already exists in `user` module.

![](/assets/posts/java/ocp-11-17/2021-08-26-OCP11-migration_to_a_modular_application_fig5.webp)

**NOTE:** Java still **allows cyclic dependencies** between packages within the same module. **This restriction only applies to modules**.

