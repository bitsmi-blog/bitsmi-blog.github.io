---
author: Xavier Salvador
title: OCP7 13 – E/S simultánea
date: 2020-05-13
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

Las llamadas de bloqueo secuencial se ejecutan en una duración de tiempo más larga que las llamadas de bloqueo simultáneo.

![](/assets/posts/java/ocp-7/2020-05-13-ocp7_11_hilos_09_es_simultanea.png)

<!--more-->

**Reloj**: Existen diferentes formas de medir el tiempo.

En el gráfico se muestran cinco llamadas secuenciales a servidores de red que tardarán aproximadamente 10 segundos si cada llamada dura 2 segundos.

En la parte derecha del gráfico, cinco llamadas simultáneas a los servidores de red solo tardan un poco más de 2 segundos si cada llamada dura 2 segundos.

Ambos ejemplos usan aproximadamente la misma cantidad de tiempo de CPU, la cantidad de ciclos de CPU.

## Cliente de red thread único

```java
public class SingleThreadClientMain {

    public static void main(String[] args) {
        String host = "localhost";
        for(int port = 10000; port <10010; port++) {
            RequestResponse lookup = new RequestResponse(host, port);
            try (Socket sock = new Socket(lookup.host, lookup.port));
            Scanner scanner = new Scanner(sock.getInputStream());) {
                lookup.response = scanner.next();
                System.out.println(lookup.host + ":" + lookup.port + " " + lookup.response);
            } catch () {
                System.out.println("Error talking to " + host + ":" + port);
            }
        }
    }
}
```

**Llamada síncrona**

En el ejemplo de esta diapositiva, estamos intentado detectar el proveedor que ofrece el precio más bajo para un artículo.

El cliente comunicará con los 10 servidores de red distintos, cada servidor tardará aproximadamente dos segundos en buscar los datos solicitados y devolverlos.

Es posible que haya retrasos adicionales introducidos por la latencia de red.

Este cliente de **thread único** debe esperar que cada servidor responda antes de moverse a otro servidor. Son necesarios cerca de 20 segundos para recuperar todos los datos.

## Cliente de red multithread (parte 1)

```java
public class MultiThreadedClientMain {

    public static void main(String[] args) {
        //  ThreadPool used to execute Callables
        ExecutorService es = Executors.newCachedThreadPool();
        //  A Map used to connect the request data with the result
        Map<RequestResponse.Future<RequestResponse>>  callables = new HashMap<>();

        String host = "localhost";
        //loop to create and submit a bunch Callable instances
        for(int port = 10000; port < 10010; port++)  {
            RequestResponse lookup = new RequestResponse(host, port);
            NetworkClientCallable callable = new NetworkClientCallable(lookup);
            Future<RequestResponse> future = es.submit(callable);
            callables.put(lookup, future);
        }
    }

}
```

**Llamada asíncrona**

En el ejemplo estamos intentando detectar el proveedor que ofrece el precio más bajo para un artículo.

El cliente comunicará con los 10 servidores de red distintos, cada servidor tardará aproximadamente dos segundos en buscar los datos solicitados y devolverlos.

Es posible que haya retrasos adicionales introducidos por la latencia de red.

Este cliente **multithread** no espera que cada servidor responda antes de intentar comunicarme con otro servidor.

Son necesarios cerca de 2 segundos en lugar de 20 para recuperar todos los datos.

## Cliente de red multithread (parte 2)

```java
//  Stop accetping new Callables
es.shutdown();

try {
    // Block until all Callables have a chance to finish
    es.awaitTermination(5, TimeUnit.SECONDS);   
} catch(InterruptedException ex) {
    System.out.println("Stopped waiting early.");
}
```

## Cliente de red multithread (parte 3)

```java
for(RequestResponse lookup: callables.keySet()) {
    Future<RequestResponse> future = callables.get(lookup);

    try {
        lookup = future.get();
        System.out.println(lookup.host + ":" + lookup.port + " " +lookup.response);
    } catch(ExecutionException |InterruptedException ex) {
        //  This is why the callables Map exists 
        //  future.get() fails if the task failed
        System.out.println("Error talking to "+lookup.host + ":" + lookup.port);
    }   
}
```

## Cliente de red multithread (parte 4)

```java
public class RequestResponse {

    public String host; // request
    public int port; // request
    public String response:  // response

    public RequestResponse() {
        this.host = host;
        this.port = port;
    }   

    //  equals and hashCode
} 
```

## Cliente de red multithread (parte 5)

```java
public class NetworkClientCallable implements Callable<RequestResponse> {

    private RequestResponse lookup;

    public NetworkClientCallable(RequestResponse lookup) {
        this.lookup = lookup;
    }

    @Override
    public RequestResponse call() throws IOException {
        try (Socket sock = new Socket(lookup.host, lookup.port);
             Scanner scanner = new Scanner(sock.getInputStream());) {
            lookup.response = scanner.next();
            return lookup;
        }
    }
}
```
