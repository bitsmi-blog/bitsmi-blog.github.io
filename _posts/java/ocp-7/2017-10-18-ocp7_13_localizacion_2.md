---
author: Xavier Salvador
title: OCP7 13 – Localización
date: 2017-10-18
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

Las especificaciones para el uso de recursos en formato de fichero de propiedades a través de la API ResourceBundle de Java definen unas reglas para la nomenclatura 
y ubicación de dichos ficheros que hay que seguir de forma que la JVM pueda localizar y recuperar los recursos definidos en ellos. 
No obstante, dicha API proporciona mecanismos que permiten personalizar este proceso. En este POST se explica cómo hacerlo.

<!--more-->

Las reglas estándar para la definición de recursos en formato de ficheros de propiedades definen lo siguiente:

- Los ficheros deben tener un nombre en el siguiente formato:
```
nombreConjunto[_idioma[_país]].properties
```
Donde:
	- `nombreConjunto` hace referencia al identificador del conjunto de recursos que se está definiendo. El usuario es libre de escoger el identificador que más le convenga 
para después poder utilizarlo dentro del código de la aplicación. 
	- `idioma` hace referencia al código del idioma en formato i18n. Es decir, para el castellano seria es y para el inglés en. 
La indicación del idioma es opcional si se quiere definir el conjunto de recursos que corresponderá a la localización por defecto definida para la JVM en la que se ejecute la aplicación.
	- `país` hace referencia al código nacional asociado al idioma seleccionado. Si por ejemplo un mismo idioma tiene múltiples variantes, 
como por ejemplo el inglés con la variante de Gran Bretaña y la de Estados Unidos, se permitirá diferenciar entre ellas utilizando esté código, en este caso en_GB y en_US respectivamente. 
Si el conjunto de recursos se define de forma general para un idioma sin tener en cuenta las variantes, no es necesario especificar este código. 

- Cada uno de los componentes de dicho nombre se deberán separar por el carácter «_» de forma predefinida.
- Los ficheros de propiedades deben estar ubicados dentro del classpath de la aplicación.

Si se desea modificar alguna de estas condiciones, cabe la posibilidad de implementar el nuevo comportamiento implementado un nuevo componente de tipo ResourceBundle.Control. 
Su definición viene proporcionada por la API de Java y permite modificar diferentes aspectos de la localización de los recursos estándar. 
A continuación se expone un ejemplo en el que se modifica el mecanismo de localización de los ficheros y el formato de su nombre para adecuarlo al siguiente escenario:

- El formato del nombre de los ficheros de recursos seguirán el patrón `nombreConjunto[-idioma[_país]].properties`. 
Nótese que la separación entre el nombre del conjunto y el idioma se ha modificado para que sea a través del carácter `-`
- La ubicación del fichero de propiedades se encontrará fuera del _classpath_ de la aplicación. En este caso se trata de un directorio externo. 

La implementación es la siguiente:

```java
/**
 * Recuperación de los recursos. A la creación del objeto ResourceBundle 
 * se le proporciona un componente ResourceBundle.Control que permite 
 * personalizar la localización y recuperación de los recursos
 */
ResourceBundle bundle = ResourceBundle.getBundle("bundles.Messages", new Locale("en"), 
  new ResourceBundle.Control()
{
 /**
  * Sobreescritura del método de la API que permite localizar un fichero de recuros a través
  * de su nombre base y el Locale. Permitirá modificar la estructura del nombre del fichero
  */
 @Override
 public String toBundleName(String baseName, Locale locale) 
 {
  . . .
 }
 
 /**
  * Sobreescritura del método de la API que recuperar un fichero de recuros 
  * desde una ubicación predefinida. 
  * Permitirá modificar la ubicació estándar del fichero
  */
 @Override
 public ResourceBundle newBundle(String baseName, 
   Locale locale, 
   String format, 
   ClassLoader loader, 
   boolean reload) throws IllegalAccessException, InstantiationException, IOException 
 {
  . . .
 }
});
 
// A partir de aqui se podrán usar los recursos recuperados
String message = bundle.getString("messages.car");Assert.assertEquals("car",message);
 
message=bundle.getString("messages.house");Assert.assertEquals("house",message);
```

Sobreescribiendo los métodos `toBundleName` y `newBundle` que proporcionan la API, se podrá modificar el formato del nombre de los ficheros y su ubicación por defecto. 
A través del método `toBundleName`, se modifica la construcción del patrón de búsqueda por nombre de fichero a partir del baseName indicado y el `Locale`: 

```java
/**
 * Sobreescritura del método de la API que permite localizar un fichero de recuros a través
 * de su nombre base y el Locale. Permitirá modificar la estructura del nombre del fichero
 */
@Override
public String toBundleName(String baseName, Locale locale) 
{
 if (locale == Locale.ROOT) {
  return baseName;
 }
 
 String language = locale.getLanguage();
 String country = locale.getCountry();
 String variant = locale.getVariant();
 
 if (language == "" && country == "" && variant == "") {
  return baseName;
 }
 StringBuilder sb = new StringBuilder(baseName);
 // Adaptación del standard. Se utilizará "-" en vez de "_" como separador despues del baseName
 sb.append('-');
 // El resto del formato del nombre sigue el estándar
 if (variant != "") {
  sb.append(language).append('_').append(country).append('_').append(variant);
 } else if (country != "") {
  sb.append(language).append('_').append(country);
 } else {
  sb.append(language);
 }
 
 return sb.toString();
}
```

La sobreescritura del método `newBundle` permite modificar la ubicación que por defecto se encuentran en el _classpath_ de la aplicación. 
En el caso de ejemplo, esto es en el directorio externo `data`:

```java
/**
 * Sobreescritura del método de la API que recuperar un fichero de recuros desde una ubicació predefinida. 
 * Permitirá modificar la ubicació estándar del fichero
 */
@Override
public ResourceBundle newBundle(String baseName, 
  Locale locale, 
  String format, 
  ClassLoader loader, 
  boolean reload) throws IllegalAccessException, InstantiationException, IOException 
{
 // Sólo se recuperarán bundles en formato properties
 if(!"java.properties".equals(format)){
  throw new IllegalArgumentException("unknown format: " + format); 
 }
  
 String bundleName = toBundleName(baseName, locale);
 String resourceName = toResourceName(bundleName, "properties");
 // Los ficheros se localizarán dentro del directorio "data" que es relativo al directorio de la aplicación
 File bundleFile = new File("data/" + resourceName);
  
 if(!bundleFile.exists()){
  return null;
 }
 
 // En caso de que el fichero exista, se retornará el conjunto de recursos
 try(FileInputStream stream=new FileInputStream(bundleFile)){
  return new PropertyResourceBundle(stream);
 }
}
```

En otros escenarios, seria posible realizar una modificación similar para, por ejemplo, recuperar los ficheros a través del ServletContext de una aplicación J2EE. 
Esto permitiría ubicar estos recursos en una ubicación dentro del directorio `/WEB-INF` distinta a `/WEB-INF/classes` si fuera necesario:

```java
@Override
public ResourceBundle newBundle(String baseName, 
        Locale locale, 
        String format, 
        ClassLoader loader, 
        boolean reload) throws IllegalAccessException, InstantiationException, IOException 
{
    // Sólo se recuperarán bundles en formato properties 
    if(!"java.properties".equals(format)){ 
        throw new IllegalArgumentException("unknown format: " + format); 
    }
  
    String bundleName = toBundleName(baseName, locale);
    String resourceName = toResourceName(bundleName, "properties"); 
  
    /* 
     * Los ficheros se localizarán dentro del directorio "/WEB-INF" de la aplicación J2EE en vez de
     * en "/WEB-INF/classes" como sería lo estándar
     */
    try(InputStream is = context.getResourceAsStream("/WEB-INF/" + resourceName)){      
        return new PropertyResourceBundle(is);
    }
}
```

## Referencias

- [OCP7 13 – Localización](/java/ocp-7/2014-07-01-ocp7_13_localizacion) 
- [API ResourceBundle.Control](https://docs.oracle.com/javase/7/docs/api/java/util/ResourceBundle.Control.html)

