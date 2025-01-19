---
author: Antonio Archilla
title: Patrón Cadena de Responsabilidad con Spring
date: 2015-12-07
categories: [ "spring", "patterns" ]
tags: [ "spring", "patterns" ]
layout: post
excerpt_separator: <!--more-->
---

El patrón de diseño Cadena de Responsabilidad (Chain of Responsability) es un patrón de tipo «comportamiento», es decir, que establece protocolos de interacción entre clases y objetos emisores y receptores de los mensajes a procesar. Es usado para desacoplar las diferentes implementaciones de un algoritmo de su uso final, ya que el emisor del mensaje no tiene porqué conocer el componente que finalmente procesará el mensaje.

Su funcionamiento básico es el siguiente:

- Se forma una lista encadenada con todos los posibles receptores del mensaje, de forma que cada uno de ellos tengo un enlace al siguiente, si se quiere, ordenados pueden ordenarse por prioridad de forma que en caso de que varios de ellos sean capaces de procesar un mismo mensaje, prevalezca el que tenga una prioridad mas alta según criterios funcionales.
- El emisor del mensaje, sólo ha de tener acceso al primero de los receptores. Será a este al que se le hará la llamada inicia y quien proporcionará el resultado al emisor.
- Cada uno de los receptores, evaluará el mensaje proporcionado por el emisor y decidirá si es capaz de procesarlo y proporcionar un resultado. En caso afirmativo, se acabará la cadena de llamadas a posteriores receptores y se retornará. Esto hará que el resultado pase por todos los receptores ejecutados anteriormente hasta devolvérselo al emisor. En caso que el receptor actual no sea capaz de evaluar el mensaje, delegará en el siguiente receptor en la cadena esperando el resultado que le proporcione, sea el o no el que finalmente se haga cargo de proporcionárselo.Todo lo explicado hasta ahora se puede resumir en el siguiente diagrama de secuencia:

<!--more-->

![](/assets/posts/spring/patterns/2015-12-07-patron_cadena_de_resposnabilidad_con_spring_fig1.png)

En él se puede observar una situación en la que se dispone de un emisor y 4 receptores capaces de procesar diferentes mensajes. El emisor hace la llamada al primer de los receptores para que le proporcione el resultado. Éste, al evaluarlo, ve que no es capaz de procesarlo y delega en el segundo de los receptores y así sucesivamente hasta llegar al tercero de ellos, que si es capaz de hacerlo y proporciona un resultado, haciendo innecesaria la propagación del mensaje al cuarto de ellos. El resultado se propaga por los receptores 1 y 2 hasta llegar al emisor de forma transparente.

Un ejemplo de su uso muy simple seria el siguiente. Se quiere construir un sistema capaz de traducir palabras en diferentes idiomas al castellano. Utilizando este patrón de diseño, se dispondría de un componente capaz de procesar mensajes de un idioma concreto, uno en ingles y otro en alemán, por ejemplo. También sería posible que para un mismo idioma hubiera diferentes receptores para, por ejemplo, procesar mensajes de saludo. En este caso este receptor específico tendría que estar situado en posiciones anteriores de la cadena de receptores al otro mas genérico. El siguiente diagrama muestra el comportamiento descrito:

![](/assets/posts/spring/patterns/2015-12-07-patron_cadena_de_resposnabilidad_con_spring_fig2.png)

## Implementación mediante Spring

A continuación se muestra una posible implementación del patrón utilizando el contenedor IOC Spring. La propuesta que se describe aquí dista un poco de la realizada en el texto anterior, aunque el concepto subyacente es el mismo: Delegar la responsabilidad de realizar una acción a componentes organizados en forma de lista priorizada en la que en caso que un integrante no sea capaz de realizar la acción, delega en el siguiente en la lista y así sucesivamente hasta que uno de ellos pueda hacerse cargo y proporcionar un resultado.

En este caso, en lugar de que cada uno de los componentes receptores sea responsable de llamar al siguiente en la cadena si no es capaz de procesar el mensaje y de proporcionar el resultado final al receptor anterior o el emisor si se trata del primero en la cadena de llamadas, se implementa un servicio centralizado de ejecución en el cual se registraran todos los receptores que intervendrán en la cadena. De esta forma, el componente emisor sólo tiene conocimiento de la existencia del servicio de ejecución y se permite el registro dinámico de nuevos componentes de forma más sencilla que en el caso de tener los receptores encadenados los unos con los otros. 

![](/assets/posts/spring/patterns/2015-12-07-patron_cadena_de_resposnabilidad_con_spring_fig3.png)

Para la implementación del ejemplo se han realizado los siguientes pasos:

- Se define la interfaz `IChainExecutionElement` que establecerá el contrato que todas las implementaciones del servicio de traducción deberán cumplir. En este caso, se define un método principal `doChain` que recibirá el mensaje de entrada a procesar y devolverá un booleano dependiendo de si ha podido procesarlo (true) o no (false). De esta manera el servicio de ejecución de la cadena de receptores sabe si debe propagar el mensaje al siguiente receptor.

```java
public interface IChainExecutionElement 
{
    public boolean doChain(TranslationChainMessage action) throws Exception;
}
```

- Se define el formato del mensaje que se proporcionará desde el emisor a cada uno de los receptores encargados de realizar la traducción. En este caso, el mensaje estará formado inicialmente por la cadena de texto a traducir y el idioma en que se encuentra. También cuenta con los campos necesarios para que el receptor sea capaz de especificar el resultado obtenido, esto es, el texto traducido y un indicador de quien ha sido el componente responsable de la traducción, puesto aquí para poder ver cómo funciona el algoritmo implementado.

```java
ublic class TranslationChainMessage 
{
    private String language;
    private String message;
      
    private String translation;
    private String processorName;
        . . .
}
```

Se implementa un servicio encargado de ejecutar el algoritmo de ejecución de la cadena, que se llevará a cabo mediante un bucle que se encarga de llamar a todos los receptores de mensajes registrados pasándoles el mensaje recibido desde el emisor. La iteración finalizará cuando uno de los receptores sea capaz de procesar el mensaje y proporcionar un resultado. Este servicio permite el registro de los componentes receptores mediante el mecanismo de inyección de dependencias que proporciona **Spring**, de forma que todos los beans de **Spring** que cumplan el contrato definido por la interfaz `IChainExecutionElement` se registrarán automáticamente. También se permite la ordenación de los componentes según prioridad haciendo uso de la anotación `@Order` que proporciona **Spring** en los diferentes componentes receptores para definir esta prioridad y ordenando la lista en el método de inicialización (anotado con `@PostConstruct`) del servicio de ejecución una vez han sido inyectados todos. 

```java
@Service
public class ChainExecutionService 
{
    @Autowired
    private List chain;
      
    @PostConstruct
    public void init() 
    {
        Collections.sort(chain, AnnotationAwareOrderComparator.INSTANCE);
    }
      
    public void setChain(List chain)
    {
        this.chain = chain;
    }
      
    public void executeChain(TranslationChainMessage action) throws Exception
    {
        boolean breakLoop = false;
        Iterator iterator = chain.iterator();
        while(iterator.hasNext() &amp;&amp; !breakLoop){
            IChainExecutionElement delegate = iterator.next();
            if(delegate.doChain(action)){
                breakLoop = true;
            }
        }
          
        if(!breakLoop){
            // No se ha encontrado ninguna implementación para tratar el elemento
            throw new Exception("No se ha encontrado ninguna implementación para tratar el elemento");
        }
    }
}
```

- Mediante el escaneo dinámico del _classpath_ que proporciona **Spring** cómo método de configuración mediante la anotación `@ComponentScan`, se pueden añadir diferentes implementaciones del servicio de traducción sin necesidad de modificar el código principal de la aplicación. En este caso todas la implementaciones disponibles se encuentran bajo el package indicado en dicha anotación, que será explorada durante la inicialización de este en busca de definiciones de beans. Lo que hace este mecanismo realmente flexible es la posibilidad de incluir estos componentes en varios módulos diferentes, incluso ubicados en ficheros jar distintos, y utilizar el escaneo dinámico para recuperarlos todos para su utilización.

```java
@Configuration
@ComponentScan({"snippets.ioc.spring.cor"})
public class ChainOfResponsabilityConfig 
{
      
}
```

- A continuación se muestra un ejemplo de implementación de un componente de tipo receptor. Se puede ver la definición como componente de Spring mediante la anotación `@Component`, la inicialización del componente estableciendo qué palabras es capaz de traducir y el método `doChain` decide si es capaz de procesar el mensaje de entrada y de proporcionar un resultado si es el caso. También se puede observar como se indica al servicio ejecutor si ha sido capaz de procesar el mensaje devolviendo `true` o `false`.

```java
@Component
public class EnglishMessageProcessor implements IChainExecutionElement 
{
    private Map translationMap;
      
    @PostConstruct
    private void setUp()
    {
        translationMap = ImmutableMap.builder()
                .put("Hello", "Hola") 
                .put("Goodbye", "Adios") 
                .put("Car", "Coche") 
                .put("House", "Casa")
                .build();
    }
      
    @Override
    public boolean doChain(TranslationChainMessage action) throws Exception 
    {
        // Sólo se procesará en caso que el idioma sea el esperado 
        // y se tenga la traducción para el mensaje recibido
        if(!"en".equals(action.getLanguage())
                || !translationMap.containsKey(action.getMessage())){
            return false;
        }
          
        action.setTranslation(translationMap.get(action.getMessage()));
        action.setProcessorName("EnglishMessageProcessor");
          
        return true;
    }
}
```

	En el repositorio adjunto en los links de interés, se pueden consultar la implementación del resto de componentes realizados para el ejemplo, todos con una estructura similar.

- Para probar la implementación de ejemplo realizada, se ha diseñado un test muy simple en el que se pasan diferentes palabras a traducir en inglés o alemán y se comprueba el resultado y quien ha sido el responsable de la traducción.

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes={ChainOfResponsabilityConfig.class})
public class ChainOfResponsabilityTestCase 
{
    @Autowired
    private ChainExecutionService executionService;
      
    @Test
    public void translationTest() throws Exception
    {
        TranslationChainMessage message1 = new TranslationChainMessage();
        message1.setLanguage("en");
        message1.setMessage("Car");
        executionService.executeChain(message1);
        Assert.assertEquals("Coche", message1.getTranslation());
        Assert.assertEquals("EnglishMessageProcessor", message1.getProcessorName());
          
        TranslationChainMessage message2 = new TranslationChainMessage();
        message2.setLanguage("de");
        message2.setMessage("Auto");
        executionService.executeChain(message2);
        Assert.assertEquals("Coche", message2.getTranslation());
        Assert.assertEquals("GermanMessageProcessor", message2.getProcessorName());
          
        TranslationChainMessage message3 = new TranslationChainMessage();
        message3.setLanguage("en");
        message3.setMessage("Hello");
        executionService.executeChain(message3);
        Assert.assertEquals("Hola", message3.getTranslation());
        Assert.assertEquals("EnglishGreetingsMessageProcessor", message3.getProcessorName());
    }
}
```

## Enlaces de interés

Todo el código desarrollado para este ejemplo se encuentra en el repositorio online BitBucket en la [siguiente URL](https://bitbucket.org/bitsmi/snippets/src/0e6b430eeb31/ioc/spring/?at=default)

