---
author: Xavier Salvador
title: OCP7 11 – Hilos (03) – Mecanismos básicos en la plataforma Java
date: 2018-01-27
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

En este artículo se exponen los mecanismos básicos que proporciona la plataforma estándar de Java para la implementación de tareas concurrentes detallada para su versión 7. 

Se tratarán los siguientes conceptos:

* Implementación de tareas mediante hilos de ejecución
* Gestión del ciclo de vida de los hilos de ejecución mediante API

<!--more-->

## Hilos de ejecución

Los hilos de ejecución son representados en la plataforma Java cómo instancias de la clase Thread. Para que los hilos de ejecución lleven a cabo la tarea para la que han sido creados será necesario especificar el código que la haga posible. 
Esto se podrá hacer mediante la implementación de uno de los mecanismos que se explican a continuación.

### Implementación de un objeto Runnable

Java define la interfaz `Runnable` con el propósito que dentro de la implementación de su único método `run()` se indique el código a ejecutar por el hilo. 
La nueva instancia derivada de la implementación de la interfaz `Runnable` será pasada a un objeto `Thread` a través de su constructor para ser ejecutada en el hilo que este representa.
En el siguiente ejemplo se crea una clase `SimpleRunnable` que implementa la interfaz `Runnable` para especificar el código que será ejecutado en 2 hilos diferentes. 
Su tarea es la de imprimir por pantalla 10 número consecutivos a partir de una semilla especificada en la creación del objeto. 
Para ejecutar este código, se crearán 2 objetos Thread a cada uno de los cuales se le proporcionará una instancia de la implementación de `SimpleRunnable` 
inicializada con valores diferentes (10 y 20 respectivamente):

```java
public class SimpleRunnable implements Runnable {
 
    private int seed;
 
    public SimpleRunnable(int seed) {
        this.seed = seed;
    }
 
    /**
     * Implementación del còdigo que será ejecutado por el hilo
     */
    @Override
    public void run() {
        for (int i = 0; i &lt; 10; i++) {
            System.out.print((seed + i) + " ");
        }
    }
}
 
public class RunnableMain {
    public static void main(String... args) {
        /*
         * Creación de los hilos a partir de la la instancia de la tarea Runnable
         */
        Thread t1 = new Thread(new SimpleRunnable(10));
        Thread t2 = new Thread(new SimpleRunnable(20));
 
        /*
         * Se inicia la ejecución de los hilos que se ejecutaran concurrentemente
         */
        t1.start();
        t2.start();
    }
}
```

Cómo se puede observar en el resultado de la ejecución del programa, los valores de las 2 implementaciones se entremezclan en la impresión de resultados en consola, dada la ejecución concurrente de los 2 hilos.

![](/assets/posts/java/ocp-7/2018-01-27-ocp7_11_hilos_03_mecanismos_basicos_en_la_plataforma_java_fig1.png)

Un aspecto importante a tener en cuenta, es que **el orden de ejecución de las tareas concurrentes no puede ser previsto y se tiene que asumir que será diferente entre ejecuciones del programa**. 
En caso de tener la necesidad de controlar este aspecto, será necesaria **la utilización de mecanismos de sincronización u otras formas de control**.

## Extensión de la clase Thread

Dado que la clase `Thread` implementa la interfaz `Runnable` , es posible usar la extensión directa o indirecta de la clase `Thread` para especificar el código a ejecutar por el hilo.
El siguiente ejemplo implementa el mismo comportamiento que el mostrado en el apartado anterior, imprimir por pantalla 10 número consecutivos a partir de una semilla especificada 
en la creación del objeto. **La única diferencia es que en este caso se realiza a través de la extensión directa de la clase `Thread`**. Este es el segundo mecanismo de creación y ejecución 
de hilos mediante la clase `Thread`.

```java
public class SimpleThread extends Thread {
    private int seed;
 
    public SimpleThread(int seed) {
        this.seed = seed;
    }
 
    /**
     * Implementación del còdigo que será ejecutado por el hilo
     */
    @Override
    public void run() {
        for (int i = 0; i < 10; i++) {
            System.out.print((seed + i) + " ");
        }
    }
}
 
public class ThreadMain {
    public static void main(String... args) {
        /*
         * Creación de los hilos a partir de la extensión de la clase Thread
         */
        Thread t1 = new SimpleThread(10);
        Thread t2 = new SimpleThread(20);
 
        /*
         * Se inicia la ejecución de los hilos que se ejecutaran concurrentemente
         */
        t1.start();
        t2.start();
    }
}
```

Al trabajar directamente sobre una clase que hereda la API de la clase `Thread` y de la interfaz `Runnable`, 
no será necesaria la creación de objetos diferentes para el hilo de ejecución y la implementación del código de la tarea, como en el caso del apartado anterior. 
No obstante, un inconveniente de trabajar directamente sobre la extensión de la clase `Thread` es que imposibilita que la clase que ha de implementar el método `run()` extienda de otra clase. 
En casos en que sea necesaria dicha herencia, es mas apropiado trabajar sobre la interfaz `Runnable` ya que permitirá implementar dicha herencia y del método `run()` a la vez.

## Gestión de los hilos de ejecución

Hay 2 formas básicas de gestionar el ciclo de vida de los hilos de ejecución:

* A través de la API que proporciona el objeto `Thread` que representa el hilo de ejecución.
* Delegando la gestión de los hilos a un objeto `Executor`. 
A diferencia de la gestión directa a través de la API de la clase Thread, **delegando las dichas tareas a estos nuevos componentes se consigue su separación del resto de la lógica de la aplicación**. 
Esto es muy conveniente para aplicaciones de tamaño medio-grande, ya que favorece su mantenimiento y reutilización de componentes al poder usar o implementar lógicas de gestión de hilos comunes para varias funcionalidades.

En este artículo sólo se expondrá la gestión directa a través de la API de la clase `Thread`, dejando para un artículo posterior la gestión por delegación, junto con las las novedades introducidas en la especificación Java SE 7 en este aspecto, 
como por ejemplo el nuevo framework `Fork/Join`, pensado especialmente para aprovechar los sistemas multiprocesador.

### Gestión directa de los hilos a través de su API

La clase `Thread` define una serie de métodos que proporcionan información o modifican el estado del ciclo de vida del hilo de ejecución. 
Algunos de estos métodos son estáticos y hacen referencia al hilo de ejecución desde donde se hace la llamada. Los métodos más importantes de esta API para el control del ciclo de vida son:

* **start()**: Método que causa el inicio de la ejecución concurrente del hilo. Sólo se puede ejecutar este método una sola vez sobre un mismo hilo. 
Un hilo de ejecución no puede ser reiniciado una vez ha finalizado su ejecución.
* **interrupt()**: Método que envía una señal de interrupción a un hilo de ejecución. A efectos prácticos, esto significa que le indica al hilo que debe dejar de hacer lo que estaba haciendo 
y ejecutar otra tarea. Habitualmente esto significa finalizar su ejecución, pero no siempre es así. 
Para poder utilizar este mecanismo, los hilos de ejecución deben incluir algún mecanismo para comprobar posibles interrupciones. Por ejemplo:

```java 
@Override
public void run()
{
        while(true) {
                /* Se realiza una porción de la tarea encomendada */
                doSomething();
         /* Una vez Se comprueba si el hilo ha sido interrumpido
                */
                if (Thread.interrupted()) {
          /* El hilo ha sido interrumpido desde el exterior.
           * Se finaliza la ejecución 
           */
                        return;
                }
        }
}
```

* **sleep(long millis [, int nanos])**: Método estático que causa que el hilo en el que se hace la llamada a este cese su ejecución, es decir, que pase al estado **En Espera** durante, 
como mínimo, el tiempo especificado por parámetro. Pasado este tiempo, será el planificador del sistema el que decida el momento en el que lo vuelva a pasar al esta **En Ejecución** 
de acuerdo con la política de planificación establecida. La ejecución del hilo se re-emprenderá a partir de la instrucción inmediatamente siguiente a `sleep()`. El método `sleep()` 
lanzará una excepción de tipo `InterruptedException` si durante el tiempo que está En Espera otro hilo de ejecución lo interrumpe mediante una llamada al método `interrupt()`.
* **join([long millis])**: Método que permite a un hilo de ejecución esperar a la finalización de otro. Se puede utilizar como mecanismo de sincronización. 
En el siguiente ejemplo se muestra el caso en que el hilo de ejecución principal del programa crea un hilo adicional y espera a su finalización para seguir con su ejecución.

```java
// Creación del hilo adicional
Thread t1 = new Thread();
 
// Se inicia la ejecución del hilo
t1.start();
 
/*
 * Mientras se ejecuta el nuevo hilo, se pueden continuar haciendo cosas en
 * paralelo...
 */
 
// Se espera a que el hilo "t1" finalice 
t1.join();
 
/*
 * Esta instrucción se ejecutará cuando "t1" haya finalizado y no antes
 */
System.out.println("Tareas finalizadas");
```

Adicionalmente, existe una variante del método que acepta cómo parámetro un tiempo de espera máximo. 
Si el hilo al que se espera no ha finalizado su ejecución en dicho tiempo, el hilo actual proseguirá con su ejecución.

Cabe destacar que algunos de los métodos de modificación del ciclo de vida de la clase `Thread` han sido deprecados por su naturaleza insegura, por lo que su uso debe de ser evitado. 
Es el caso de los métodos `stop()`, `suspend()` o `resume()`. En el apartado de referencias del post se ha incluido un enlace en el que se encuentran las razones por las que se desaconseja 
su uso y algunas alternativas seguras a estos.

Los siguientes métodos permiten consultar el estado del hilo de ejecución:

* **currentThread()**: Método estático que proporciona acceso al objeto Thread que representa al hilo de ejecución en el que se hace la llamada a este método.
* **getState()**: Informa del estado en el que se encuentra el hilo de ejecución. Cómo se indica en la documentación de la clase, este método se debe utilizar con fines informativos y nunca para realizar tareas de sincronización.
* **isAlive(), isInterrupted()**: Métodos de comprobación del estado de un hilo de ejecución. Permiten saber si este se encuentra activo o interrumpido respectivamente.

## Referencias

* [Thread API – Javadoc JavaSE 7](https://docs.oracle.com/javase/7/docs/api/java/lang/Thread.html)
* [Thread API – Métodos deprecados](https://docs.oracle.com/javase/7/docs/technotes/guides/concurrency/threadPrimitiveDeprecation.html)

