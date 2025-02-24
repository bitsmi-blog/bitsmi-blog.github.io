---
author: Antonio Archilla
title: Orden de ejecución de los métodos de un test de JUnit4
date: 2016-02-14
categories: [ "testing", "junit" ]
tags: [ "junit4" ]
layout: post
excerpt_separator: <!--more-->
---

Aunque quizá **JUnit4** sea el framework de testing más extendido en el ecosistema Java, adolece de ciertas limitaciones *de fábrica* que según como se mire son difíciles de explicar. 
Una de ellas para mi gusto es la dificultad de poder marcar el orden de ejecución de los métodos de una clase de test de forma sencilla. 
Entiendo que mirándolo de una forma purista cada uno de los métodos de un test case debe ser independiente y su ejecución no se debería ver afectada por el resto, 
pero en determinados casos es de mucha ayuda poder marcar el orden de ejecución, como por ejemplo poder probar la conexión a una fuente de datos antes de obtener los datos.

En este articulo se pretende exponer diferentes alternativas para dar respuesta a este caso de uso.

<!--more-->

La solución que proporciona JUnit a partir de su versión 4.11 para esto es la anotación `@FixMethodOrder` que permite definir 3 métodos de ordenación para los métodos:

- **DEFAULT**: Ordenación determinista pero no predecible
- **JVM**: Mantiene la ordenación con la que la máquina virtual devuelve los métodos
- **NAME_ASCENDING**: Ordenación lexicográfica según los nombres de los métodos. En la realidad, este es el único valor que proporciona una forma determinista y controlable por el programador de definir el orden de ejecución de los métodos de un test case.

Un ejemplo de uso de esta anotación es el siguiente:

```java
import org.junit.runners.MethodSorters;
import org.junit.FixMethodOrder;
import org.junit.Test;
  
@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class SampleTestCase 
{
    @Test
    public void t1_firstTest() 
    {
        System.out.println("primero");
    }
  
    @Test
    public void t2_secondTest() 
    {
        System.out.println("segundo");
    }
}
```

Según lo visto, este mecanismo es poco flexible y limitado ya que obliga a mantener una nomenclatura de los métodos de test rígida y compleja. 
Además, presenta problemas cuando se quieren realizar modificaciones en el orden establecido al requerir el renombrado de los métodos.

No obstante, JUnit provee de los mecanismos para implementar una solución algo más óptima para realizar esta ordenación. 
Para ello será necesario implementar nuestro propio Runner que extienda de la clase de **JUnit** `BlockJUnit4ClassRunner`. 
De esa manera se puede personalizar la obtención de los métodos de test. En este ejemplo nos ayudaremos de una anotación para indicar el orden de cada método:

```java
import java.lang.annotation.ElementType;
import java.lang.annotation.Inherited;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
  
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Inherited
public @interface OrderedTest
{
    int order() default 0; 
}
```

El *runner* de **JUnit** que implementaremos se encargará de obtener todos los métodos anotados con la nueva anotación y `@Test` y ordenarlos con un comparador:

```java
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import org.junit.Test;
import org.junit.runners.BlockJUnit4ClassRunner;
import org.junit.runners.model.FrameworkMethod;
import org.junit.runners.model.InitializationError;
  
public class TestRunner extends BlockJUnit4ClassRunner
{
    public TestRunner(Class<?> klass) throws InitializationError 
    {
        super(klass);
    }
      
    @Override
    protected List<FrameworkMethod> computeTestMethods() 
    {
        ArrayList<FrameworkMethod> result = new ArrayList<FrameworkMethod>();
        result.addAll(getTestClass().getAnnotatedMethods(OrderedTest.class));
        List<FrameworkMethod> testAnnotatedMethods = getTestClass().getAnnotatedMethods(Test.class);
        for(FrameworkMethod method : testAnnotatedMethods){
            if(!result.contains(method)){
                result.add( method );
            }
        }
          
        Collections.sort(result, new TestMethodOrderComparator());
        return result;
    }
}
```

La implementación del comparador es muy simple. Dados dos métodos, si están anotados con la nueva anotación, su orden estará marcado por ella.

```java
import java.util.Comparator;
import org.junit.runners.model.FrameworkMethod;
  
public class TestMethodOrderComparator implements Comparator<FrameworkMethod> 
{
    @Override
    public int compare(FrameworkMethod method1, FrameworkMethod method2) 
    {
        OrderedTest annotation1 = method1.getAnnotation(OrderedTest.class);
        OrderedTest annotation2 = method2.getAnnotation(OrderedTest.class);
        if(annotation1 != null && annotation2 != null){
            return Integer.valueOf(annotation1.order()).compareTo(Integer.valueOf(annotation2.order()));
        }
        return 0;
    }
}
```

La utilización de todo el conjunto permite escribir clases de test de una forma más flexible que en el ejemplo mostrado al principio:

```java
import org.junit.runners.MethodSorters;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.fenrir.kraft.test.util.OrderedTest;
import org.fenrir.kraft.test.util.TestRunner;
   
@RunWith(TestRunner.class)
public class SampleTestCase 
{
    @OrderedTest(order=1)
    public void metodoDeTest1() 
    {
        System.out.println("primero");
    }
   
    /**
     * Con la nueva anotación el nombre del método ya no se tiene que ser
     * lexicográficamente posterior al método de test 1, permitiendo mayor flexibilidad
     */
    @OrderedTest(order=2)
    public void aaaMetodo() 
    {
        System.out.println("segundo");
    }
}
```

Hay detalles de esta implementación que pueden estar sujetos al criterio propio de cada uno, por ejemplo el tratamiento de los métodos anotados con la anotación estándar `@Test`
que presentan un orden no determinista de ejecución, pero espero que este post pueda servir de punto de partida.

## Enlaces de interés

- [El código completo correspondiente a la implementación realizada se puede encontrar en el repositorio de código a través de la siguiente url](https://bitbucket.org/fenrir/kraft/src/2c1a00f7e5ec4f0548bf88d20deb7817226a0037/src/test/java/org/fenrir/kraft/test/util/?at=master)
- [Un ejemplo algo más complejo de su utilización](https://bitbucket.org/fenrir/kraft/src/2c1a00f7e5ec4f0548bf88d20deb7817226a0037/src/test/java/org/fenrir/kraft/test/ElasticSearchConceptTestCase.java?at=master&fileviewer=file-view-default)

