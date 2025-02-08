---
author: Xavier Salvador
title: Discusión - Fork vs Branch en Git
date: 2020-05-04
categories: [ "references", "scm", "scripts and utilities" ]
tags: [ "git" ]
layout: post
excerpt_separator: <!--more-->
---

#### Conceptos
La diferencia conceptual entre **forking** y **branching** viene dada por desarrollo ***divergente vs convergente***:

- Concepto de **Forking**
Se refiere al proceso de generar una copia exacta del repositorio origen a uno nuevo en ese instante temporal. Es una copia física real y diferente, la operativa surge para realizar separaciones reales y crear nuevas lógicas bajo una base común, se asume que es poco probable que vuelvan a reunirse con el parent.

- Concepto de **Branching**
Se refiere a generar un copia del repositorio dentro del mismo repositorio origen, un pointer. Las ramas son espacios temporales sobre los que cuales realizar desarrollos nuevos o cambios. Su objetivo es volver a converger con el repositorio siempre.

La diferencia conceptual es el **scope de la copia** (copia separada del parent o dentro de éste) y **vida** (vida independiente contra tiempo de vida efímero).

La **razón** de la diferencia parece ser la necesidad de controlar *quién puede o no realizar push de código a la rama principal*, la práctica del forkeo es más común en el open source cuando los posibles colaboradores no tienen permisos sobre el repositorio original, de ahí la copia que genera otro repositorio de facto y luego la posibilidad de converger con el parent o no.

<!--more-->

#### Diferencias
1. **Forking** es más costoso al tener que comparar dos *codebases* una contra la otra, ya que el **fork** representa una copia literal del repositorio original (doble de espacio de almacenamiento).

2. **Branching** sólo añade una rama sobre el árbol actual, el tamaño de la rama viene ligada literalmente a los cambios de ésta.

3. **Forking** ofusca más ver en que anda trabajabando el equipo, al tener que moverse entre repositorios distintos en vez de sobre ramas sobre uno solo repositorio.

4. **Forking** al no ser un workflow colaborativo, los cambios residen en la copia de cada uno y puede llevar a mayores problemas a la hora de mergear, perecer (políticas internas de la casa para autoborrado de forks por falta de uso para liberar espacio…) o pérdida de conocimiento.

5. **Branching** al centralizar el workflow sobre un sólo repositorio permite, al actualizar sus copias, 1 remote recibir el estado de todos los remotos de las features de sus compañeros.

#### Why?

> *The Bitbucket team recommends branching for development teams on Bitbucket*.
>> ***— Bitbucket ***

> *[…]People refer to Git’s branching model as its “killer feature,” and it certainly sets Git apart in the VCS community. Why is it so special? The way Git branches is incredibly lightweight, making branching operations nearly instantaneous, and switching back and forth between branches generally just as fast. Unlike many other VCSs, Git encourages workflows that branch and merge often, even multiple times in a day.*
>> ***Pro Git Book by Scott Chachon and Ben Straub***

Aparte de una diferencia de estilo de trabajo, de que conceptualmente los forks son para otra cosa, y el coste real es espacio en disco y tiempo de copia… en realidad ambas operativas son similares e incluso complementarias, no excluyentes.

#### Razón
La razón para utilizar únicamente branches es:

1. Una forma más rápida y cómoda de recorrer el código (1 repositorio, 7 ramas de feature; en vez de bajarse 7 forks y sin saber si existirán más ramas dentro del fork).
2. Implementar ***GitFlow*** o una aproximación a éste en nuestra forma de trabajar de forma más realista.

#### Requerimientos
Para poder empezar a trabajar con **branches** sin repercutir en la productividad deben tenerse en cuenta los siguientes pasos:

1. Plan fijado de sobre como implementar la CI en las branches.
   * Protección de ramas a **commit** de developers.
     - **hotfix branches**, quién, cómo se crean y cierran.
       + **release** branches.
     - **master** es productivo.
       + preproducción queda atada a **release branches** o se puede añadir una **branch** específica para preproducción sobre cada **release**.
2. Pipelines de la **CI/CD**.
   * Activación automática de la **CI** en **branches**.
     - En vez de activación por **commit** en **master** de los **forks**, que se activen también por **commit** en **branches**.
     - Para *reducir ejecuciones* podría *restringirse la ejecución manual de la CI* en las ramas **feature**.

#### Refs 
- GitFlow: [A Successful git branching model](https://nvie.com/posts/a-successful-git-branching-model/ "A Successful git branching model").
- Bitbucket: [Branch of Fork your repository](https://confluence.atlassian.com/bitbucket/branch-or-fork-your-repository-221450630.html "Bitbucket: Branch of Fork your repository").
- Pluralsight: [The definitive guide to forks and branches in git](https://www.pluralsight.com/blog/software-development/the-definitive-guide-to-forks-and-branches-in-git "Pluralsight: The definitive guide to forks and branches in git").
- Toolsqa: [Diferencias entre branch y fork](https://www.toolsqa.com/git/difference-between-git-clone-and-git-fork "Toolsqa: Diferencias entre branch y fork").
- Reddit: [/r/devops - branching vs forking](https://old.reddit.com/r/devops/comments/7gvamp/github_branching_vs_forking_in_a_team_environment/dqmbtrx/ "Reddit: /r/devops - branching vs forking").
- [Pro Git Book by Scott Chachon and Ben Straub](https://github.com/progit/progit2/releases/download/2.1.198/progit.pdf "Pro Git Book by Scott Chachon and Ben Straub").

Se puede descargar este post mediante este enlace [sod_branching-vs-forking](/assets/posts/reference/scm/scripts_and_utilities/sod_branching-vs-forking.pdf)
