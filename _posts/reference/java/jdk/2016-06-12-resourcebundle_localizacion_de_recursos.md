---
author: Antonio Archilla
title: ResourceBundle – Localización de recursos
date: 2016-06-12
categories: [ "references", "java", "jdk" ]
tags: [ "java" ]
layout: post
excerpt_separator: <!--more-->
---

La API estándar de Java provee de mecanismos para la localización de recursos (mensajes de texto, URLs a imágenes u otros recursos…) mediante la utilización de la clase `ResourceBundle`. 
La forma más conocida y habitual de usarlos es a través de ficheros de propiedades, en los que se especifican los recursos a utilizar para cada localización en forma de clave – valor, 
pero existen otras posibilidades, como por ejemplo la utilización de clases java.

<!--more-->

En el caso de la utilización de ficheros de propiedades, si nuestra aplicación requiere de localizar cadenas de texto a varios idiomas, se definirán varios de estos ficheros, uno para cada idioma. 
Por ejemplo, en el caso que se quiera definir un conjunto de textos internacionalizados en castellano e inglés, se definirían los ficheros de propiedades siguientes para definir 
un conjunto de recursos definido como `Messages`:

**Messages_en.properties (inglés)**

```properties
messages.car=car
messages.house=house
```

**Messages_es.properties (castellano)**

```properties
messages.car=coche
messages.house=casa
```

Habiendo definido los ficheros de propiedades, dentro del código de la aplicación se pueden obtener los recursos definidos de la siguiente forma:

```java
// Se obtiene el conjunto de recursos definidos como Messages para el idioma inglés (en)
ResourceBundle bundle = ResourceBundle.getBundle("Messages", new Locale("en"));
// Se obtiene la cadena de texto del conjunto de recursos a través de la clave asociada. En este caso, el valor será "car"
String message = bundle.getString("messages.car");
Assert.assertEquals("car", message);
 
// Una vez cargado el conjunto de recursos, se pueden obtener varias cadenas        
message = bundle.getString("messages.house");
Assert.assertEquals("house", message);
```
`

Las reglas de nomenclatura para que los conjuntos de recursos son las siguientes:

`nombreConjunto[_idioma[_país]].properties`

Donde:

- `nombreConjunto` hace referencia al identificador del conjunto de recursos que se está definiendo. En el ejemplo anterior seria `Messages`. 
El usuario es libre de escoger el identificador que más le convenga para despues poder utilizarlo dentro del código de la aplicación.
- `idioma` hace referencia al código del idioma en formato i18n. Es decir, para el castellano seria `es` y para el inglés `en`. 
La indicación del idioma és opcional si se quiere definir el conjunto de recursos que corresponderá a la localización por defecto definida para la JVM en la que se ejecute la aplicación.
- `país` hace referencia al código nacional asociado al idioma seleccionado. Si por ejemplo un mismo idioma tiene múltiples variantes, 
como por ejemplo el inglés con la variante de Gran Bretaña y la de Estados Unidos, se permitirá diferenciar entre ellas utilizando esté código, en este caso `en_GB` y `en_US` respectivamente. 
Si el conjunto de recursos se define de forma general para un idioma sin tener en cuenta las variantes, no es necesario especificar este código.

La obtención del conjunto de recursos dependerá del Locale especificado. En este se encuentran especificados los códigos de idioma y país (opcional) requeridos. 
En el caso de que no se haya especificado ninguno, se utilizará el Locale por defecto de la JVM dónde se está ejecutando la aplicación.

Al requerir un conjunto de recursos dentro de la aplicación se sigue el siguiente orden para escogerlo:

- Hay definido un conjunto de recursos definido con el identificador especificado para los códigos de `país` e `idioma` especificados en el `Locale`. 
Por ejemplo, `Messages_en_GB.properties`. Este paso será obviado si el Locale definido sólo tiene especificado el código de idioma.
- Hay definido un conjunto de recursos definido con el identificador especificado para los códigos de país especificados en el `Locale`. Por ejemplo, `Messages_en.properties`
- Hay definido un conjunto de recursos definido por defecto (sin códigos de idioma o país) con el identificador especificado. Por ejemplo, `Messages.properties`

La posibilidad no tan habitual de utilizar clases Java cómo medio para implementar los conjuntos de recursos permite una mayor versatilidad a la hora de definir los soportes de dónde 
se obtendrán los datos más allá del típico fichero de propiedades. A continuación se muestra un ejemplo de la implementación con clases Java del mismo caso que se ha mostrado anteriormente 
para la utilización de ficheros de propiedades. En este caso se ha utilizado un `Map` como backend de los textos internacionalizados, pero este mecanismo hace posible obtener los textos des 
de otros soportes, como por ejemplo base de datos. Para ello sólo se tendría que modificar el método `populateData` para que obtuviera los datos a través de una conexión jdbc. 
Este método no forma parte de la API de la clase `ResourceBundle` y sólo sirve a afectos de mostrar un posible mecanismo para indicarle a la implementación realizada la lista de mensajes que se soporta.

Los puntos a resaltar de la implementación son:

- Las clases implementadas deben extender de la clase [ResourceBundle](https://docs.oracle.com/javase/7/docs/api/java/util/ResourceBundle.html)
- En el nombre de la clase se debe incluir el identificador del [ResourceBundle](https://docs.oracle.com/javase/7/docs/api/java/util/ResourceBundle.html) 
así como el idioma y el código de país si procede, de la misma forma que en el caso de los ficheros de propiedades.
- Se deben implementar el método `handleGetObject` para acceder a los mensajes a través de su clave
- También se debe implementar el método `getKeys` para poder acceder al índice de todas las claves que proporciona la implementación del [ResourceBundle](https://docs.oracle.com/javase/7/docs/api/java/util/ResourceBundle.html)

```java
import java.util.Collections;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.ResourceBundle;
 
public class Messages_es_ES extends ResourceBundle 
{
    HashMap<String, String> data; 
             
    public Messages()
    {
        data = new HashMap<String, String>(); 
        populateData();
    }
     
    protected void populateData()
    {
        data.put("messages.car","coche");
        data.put("messages.house","casa");
    }
     
    @Override
    protected Object handleGetObject(String key) 
    {
        return data.get(key);
    }
 
    @Override
    public Enumeration<String> getKeys() 
    {
        return Collections.enumeration(data.keySet());
    }
}
```

La implementación de los conjuntos de recursos mediante clases Java permite además hacer uso de características de dichos elementos que proporcionan extras útiles a la hora de usar estos conjuntos. 
Por ejemplo, se puede utilizar el mecanismo de herencia de clases para definir una cadena de delegación para elementos comunes entre conjuntos de un mismo tipo. 
Por ejemplo, se puede definir el conjunto de recursos por defecto con las funcionalidades, como por ejemplo los mecanismos de carga, y datos compartidos 
y hacer que los conjuntos específicos extiendan de este. Así se sigue cumpliendo que todos los conjuntos de recursos extienden de la clase ResourceBundle y además se favorece a la reutilización de código. 

```java
import java.util.Collections;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.ResourceBundle;
 
public class Messages extends ResourceBundle 
{
    HashMap<String, String> data; 
             
    public Messages()
    {
        data = new HashMap<String, String>(); 
        populateData();
    }
     
    protected void populateData()
    {
        data.put("messages.error","error");
        data.put("messages.car","coche");
        data.put("messages.house","casa");
    }
     
    @Override
    protected Object handleGetObject(String key) 
    {
        return data.get(key);
    }
 
    @Override
    public Enumeration<String> getKeys() 
    {
        return Collections.enumeration(data.keySet());
    }
}
```

```java
public class Messages_en extends Messages 
{
    @Override
    protected void populateData()
    {
        // Se sobreescriben sólo los datos propios del idioma ya que el resto es comun (messages.error)
        data.put("messages.car","car");
        data.put("messages.house","house");
    }
}
```

Una vez definidos los conjuntos de recursos, la forma en que se hace uso de ellos es exactamente la misma que en el caso de los ficheros de propiedades.Este hecho hace que estos 2 mecanismos sean interoperables, podiendo hacer uso de uno u otro a través del mismo código fuente, teniendo en cuenta las siguientes consideraciones:

- Se aplican las reglas de nomenclatura para los conjuntos de recursos indistintamente para clases y ficheros properties, 
por lo que en caso de tener un conjunto de recursos formado por los 2 tipos de elementos, se escogerá en primera instancia aquel que mejor se ajuste al [Locale](https://docs.oracle.com/javase/7/docs/api/java/util/Locale.html) indicado.
- En el caso que haya 2 elementos con el mismo nombre, una clase y un fichero de propiedades, la primera tendrá preferencia.