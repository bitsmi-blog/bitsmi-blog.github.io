---
author: Xavier Salvador
title: Appendix A.- Concurrency II
page_order: APENDICE_A
date: 2025-02-26
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

El Apéndice A, escrito por Brett L. Schuchert, amplía el capítulo 13 sobre concurrencia con análisis más profundos: ejemplo cliente/servidor, posibles caminos de ejecución, interbloqueo y estrategias de incremento de throughput.

<!--more-->

## Ejemplo Cliente/Servidor

### Versión de un solo hilo

Un servidor espera en un socket, procesa cada petición y vuelve a esperar. Un test de rendimiento exige que procese un conjunto de peticiones en menos de 10 segundos:

```java
@Test(timeout = 10000)
public void shouldRunInUnder10Seconds() throws Exception {
    Thread[] threads = createThreads();
    startAllThreads(threads);
    waitForAllThreadsToFinish(threads);
}
```

Si el test falla, la pregunta es: ¿dónde se gasta el tiempo?

- **Operaciones de I/O** (sockets, bases de datos, memoria virtual): la CPU espera.
- **Operaciones de CPU** (cálculos, regex, GC): la CPU trabaja.

Si el sistema es I/O-bound, el multithreading puede mejorar el rendimiento al solapar esperas con procesamiento.

### Añadiendo hilos

Una solución naive es crear un hilo por cada petición:

```java
void process(final Socket socket) {
    Runnable clientHandler = new Runnable() {
        public void run() {
            String message = MessageUtils.getMessage(socket);
            MessageUtils.sendMessage(socket, "Processed: " + message);
            closeIgnoringException(socket);
        }
    };
    new Thread(clientHandler).start();
}
```

Esto pasa el test, pero viola el Principio de Responsabilidad Única. La función `process` gestiona simultáneamente: conexión de sockets, procesamiento de clientes, política de threading y política de cierre.

### Diseño limpio con SRP

Se introduce una interfaz `ClientScheduler` que aísla toda la lógica de threading:

```java
public interface ClientScheduler {
    void schedule(ClientRequestProcessor requestProcessor);
}
```

Implementaciones intercambiables: `ThreadPerRequestScheduler` y `ExecutorClientScheduler` (usando `java.util.concurrent.Executors.newFixedThreadPool`). El código de negocio no sabe nada sobre los hilos.

## Posibles caminos de ejecución

Una línea Java aparentemente inocua puede expandirse en varios bytecodes JVM:

```java
return ++lastIdUsed;
```

Esta operación comprende: leer `lastIdUsed`, incrementar, escribir y retornar. Con dos hilos que empiezan con `lastIdUsed = 93`, los posibles resultados son:

- T1 obtiene 94, T2 obtiene 95, `lastIdUsed` = 95 ✓
- T1 obtiene 95, T2 obtiene 94, `lastIdUsed` = 95 ✓
- T1 obtiene 94, T2 obtiene 94, `lastIdUsed` = 94 ✗ (condición de carrera)

El número de posibles caminos de ejecución para N bytecodes y T hilos crece exponencialmente. Para evitar resultados incorrectos, las secciones críticas deben protegerse con `synchronized` o usando clases del paquete `java.util.concurrent.atomic`.

## Interbloqueo (Deadlock)

### Las cuatro condiciones

El interbloqueo requiere que se cumplan simultáneamente cuatro condiciones:

1. **Exclusión mutua**: el recurso no puede usarse por varios hilos a la vez.
2. **Lock & Wait**: un hilo retiene un recurso mientras espera obtener otro.
3. **No expropiación**: un hilo no puede quitarle un recurso a otro.
4. **Espera circular**: T1 espera un recurso que tiene T2, y T2 espera uno que tiene T1.

### Ejemplo concreto

Un servidor web con dos pools (conexiones DB y conexiones MQ):

- Los hilos de "crear" adquieren DB primero, luego MQ.
- Los hilos de "actualizar" adquieren MQ primero, luego DB.

Si todos los recursos de un tipo se agotan en el momento equivocado, el sistema se bloquea indefinidamente.

### Romper el interbloqueo

Basta con romper *una* de las cuatro condiciones:

| Condición | Estrategia |
|-----------|-----------|
| Exclusión mutua | Usar recursos concurrentes (`AtomicInteger`); aumentar el número de recursos |
| Lock & Wait | Verificar disponibilidad antes de adquirir; si alguno está ocupado, liberar todos y reintentar |
| No expropiación | Raramente aplicable directamente |
| Espera circular | Acordar un orden global para la adquisición de recursos y respetarlo siempre |

La estrategia más robusta es ordenar los recursos: si todos los hilos adquieren siempre los recursos en el mismo orden (primero DB, luego MQ), la espera circular es imposible.

## Locking en cliente vs servidor

El locking en el cliente (cada consumidor sincroniza antes de usar el objeto) tiene múltiples problemas: duplicación, propensión a errores y acoplamiento. El locking en el servidor (el propio objeto sincroniza sus métodos) es preferible:

- Reduce código repetido.
- Permite intercambiar una implementación thread-safe por una no thread-safe en despliegues de un solo hilo.
- Centraliza la política: si hay un error de concurrencia, hay un solo lugar donde buscar.

Si no se puede modificar el servidor, se usa un ADAPTER que añade sincronización alrededor de la API existente.

## Incremento de throughput

Para un sistema que descarga páginas y las procesa:

- Tiempo de I/O por página: 1 s (0% CPU)
- Tiempo de procesamiento: 0,5 s (100% CPU)

Con un solo hilo: 1,5 s × N páginas.

Con tres hilos: las descargas se solapan con el procesamiento. Throughput ≈ 3×. La clave es mantener el bloque `synchronized` tan pequeño como sea posible (solo la sección crítica de obtención de la siguiente URL).

## Reglas clave

| Principio | Descripción |
|-----------|-------------|
| SRP en concurrencia | El código que gestiona hilos no debe hacer nada más |
| Secciones críticas pequeñas | Sincronizar lo mínimo indispensable |
| Clases thread-safe del JDK | Preferir `java.util.concurrent` a gestión manual |
| Orden de adquisición de recursos | La estrategia más eficaz contra el interbloqueo |
| Testing de concurrencia | Variar configuraciones, número de hilos y cargas para exponer condiciones de carrera |

## Resumen

La concurrencia exige disciplina adicional: el SRP aplicado a los hilos, la conciencia de los posibles caminos de ejecución y el conocimiento de las cuatro condiciones del interbloqueo son las herramientas fundamentales para escribir sistemas concurrentes correctos y mantenibles.