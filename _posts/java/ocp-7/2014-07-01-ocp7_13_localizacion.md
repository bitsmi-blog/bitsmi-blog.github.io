---
author: Xavsal
title: OCP7 13 – Localización
date: 2014-07-01
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

## Localización

La localización o regionalización es el proceso mediante el cual un producto internacionalizado se configura para una determinada región, aprovechando las opciones que la internacionalización previa de este producto ha permitido (i18n). 
Por ejemplo, la internacionalización puede permitir utilizar distintos formatos de fecha, y la localización consiste en escoger el adecuado para una región específica.

<!--more-->

Puede encontrase información adicional en los siguientes enlaces: [aquí](http://www.w3c.es/Divulgacion/GuiasBreves/internacionalizacion) y [aquí](https://es.wikipedia.org/wiki/Internacionalizaci%C3%B3n_y_localizaci%C3%B3n)

## Ventajas

- Permite que se adapte un software para una región o idioma específicos añadiendo componentes específicos locales y texto traducido a la región o idioma.
- La mayor parte de la tarea consiste en la traducción del idioma pero existen también otras tareas como formatos de fechas, cambio de moneda,  tipo de calendario, y cualquier otro elemento distintivo de la región.

El objetivo principal de la localización persigue la adaptación a la referencia cultural sin realizar ninguna modificación en el código fuente que implementa la aplicación.

Una aplicación con localización se divide en dos bloques principales:

1. Elementos de la interfaz de usuario localizable para la referencia cultural como textos, menús, etc…
2. Código Ejecutable:  Código de la aplicación a ser utilizado por todas las referencias culturales.

Ejemplos prácticos de localización: Establecer el idioma al inglés, salir de la aplicación, etc…

## Paquete de Recursos en Java

La clase `ResourceBundle` aísla los casos específicos de los locales.
Esta clase devuelve **parejas clave-valor** de forma independiente que pueden ser programadas en una clase que extienda de `ResourceBundle` en un archivo de propiedades.
Para utilizarla debe crearse el archivo de paquetes y después llamar a cada localización específica des de nuestra aplicación. Cada **clave identifica un componente específico de la aplicación**.

Ejemplo clave-valor:

```properties
my.hello=Hello
my.goodbye=Bye
```

Cada fichero del paquete de recursos, sea un fichero de `properties` o una clase, dispone de un nombre que sigue la siguiente estructura:

- Para un fichero de properties: `Message_Bundle_<language>_<country>.properties`
- Para una clase: `Message_Bundle_<language>_<country>.java`

**Ejemplo de los ficheros de properties:**

`MessageBundle_en_EN.properties`

```properties
my.hello=Hello
my.goodbye=Bye
my.question=Do you speak English?
```

`MessageBundle_es_ES.properties`

```properties
my.hello=Hola
my.goodbye=Adios
my.question=u00bfHablas inglu00e9s?
```

`MessageBundle_sv_SE.properties`

```properties
my.hello=Hejsan
my.goodbye=Hejd?
my.question=Pratar du engelska?
```

**Ejemplo de implementación mediante clases**

En el ejemplo que se muestra a continuación se implementan 3 clases correspondientes a los mismos casos de uso que en el ejemplo de los ficheros `properties`. 

Los puntos importantes a resaltar son:

- Las clases implementadas deben extender de la clase `ResourceBundle`
- En el nombre de la clase se debe incluir el identificador del `ResourceBundle` así como el idioma y el código de país.
- Se deben implementar el método `handleGetObject` para acceder a los mensajes a través de su clave
- También se debe implementar el método `getKeys` para poder acceder al índice de todas las claves que proporciona la implementación del ResourceBundle
- En los ejemplos, se ha utilizado un `Map` como _backend_ de los textos internacionalizados, pero este mecanismo hace posible obtener los textos des de otros soportes, 
como por ejemplo base de datos. Para ello sólo se tendría que modificar el método `populateData` para que obtuviera los datos a través de una conexión jdbc. 
Este método no forma parte de la API de la clase `ResourceBundle` y sólo sirve a afectos de mostrar un posible mecanismo para indicarle a la implementación realizada la lista de mensajes que se soporta.

`MessageBundle_en_EN.java`

```java
public class MessageBundle_en_EN extends ResourceBundle 
{
 HashMap data; 
    
    
 public MessageBundle_en_EN()
 {
  data = new HashMap(); 
  populateData();
 }
  
 protected void populateData()
 {
  data.put("my.hello", "Hello");                               
  data.put("my.goodbye", "Bye");                               
  data.put("my.question", "Do you speak English?");        
 }
  
 @Override
 protected Object handleGetObject(String key) 
 {
  return data.get(key);
 }
 
 @Override
 public Enumeration getKeys() 
 {
  return Collections.enumeration(data.keySet());
 }
}
```

`MessageBundle_es_ES.java`

```java
public class MessageBundle_es_ES extends ResourceBundle 
{
 HashMap data; 
    
    
 public MessageBundle_es_ES()
 {
  data = new HashMap(); 
  populateData();
 }
  
 protected void populateData()
 {
  data.put("my.hello", "Hola");                                
  data.put("my.goodbye", "Adios");                             
  data.put("my.question", "¿Hablas inglés?");                    
 }
  
 @Override
 protected Object handleGetObject(String key) 
 {
  return data.get(key);
 }
 
 @Override
 public Enumeration getKeys() 
 {
  return Collections.enumeration(data.keySet());
 }
}
```

`MessageBundle_sv_SE.properties`

```java
public class MessageBundle_sv_SE extends ResourceBundle 
{
 HashMap data; 
    
    
 public MessageBundle_sv_SE()
 {
  data = new HashMap(); 
  populateData();
 }
  
 protected void populateData()
 {
  data.put("my.hello", "Hejsan");                              
  data.put("my.goodbye", "Hejd?");                             
  data.put("my.question", "Pratar du engelska?");       
 }
  
 @Override
 protected Object handleGetObject(String key) 
 {
  return data.get(key);
 }
 
 @Override
 public Enumeration getKeys() 
 {
  return Collections.enumeration(data.keySet());
 }
}
```

## Formateo especial números y fechas

Existen clases específicas para formatear fechas y números:

Declaraciones de las variables para estos formatos:

```java
NumberFormat currency;
 
Double money = new Double(1000000.00);
 
Date date = new Date();
 
DateFormat dtf;   
```

A continuación se detalla el código fuente a modo de ejemplo para la inicialización de algunas variables declaradas con anterioridad.

- DateFormat: El Javadoc puede encontrarse aquí.

```java
public void showDate() {
 
     df = DateFormat.getDateInstance(DateFormat.DEFAULT, currentLocale);
 
     pw.println(df.format(today)+" "+currentLocale.toString());
 
}
```

- NumberFormat: El Javadoc puede encontrarse aquí.

```java
public void showMoney() {
 
     currency = NumberFormat.getCurrencyInstance(currentLocale);
 
     pw.println(currency.format(money)+" "+currentLocale.toString());
 
}
```

A continuación se detalla un caso de ejemplo de localización que muestra mensajes de texto en distintos idiomas (español, inglés y sueco) .

La clase se llama TestLocaleI18N y su implementación es la siguiente:

```java
package i18n; 
  
import java.util.Locale;
import java.util.ResourceBundle;
  
public class TestLocaleI18N { 
  
 /*  
 La carga del ResourceBundle puede hacerse des de fichero, des del contexto de una aplicación,  
 des del propio entorno en el que se esté ejecutando esta clase Java. 
   
 En este caso de ejemplo se utiliza el acceso al fichero properties ubicado dentro  
 del mismo paquete que la clase principal.  
 En un futuro, se realizaran pruebas con el resto de mecanismos de acceso.    
 */
 public static void main(String[] args) throws Exception {
  
  ResourceBundle bundle1 = ResourceBundle.getBundle("i18n.TestResourceBundle");
  visualizar(bundle1, null);
  
  Locale deLocale = Locale.getDefault();
  ResourceBundle bundle2 = ResourceBundle.getBundle("i18n.TestResourceBundle", deLocale);
  visualizar(bundle2, deLocale);
  
  Locale svLocale = new Locale("sv", "SE");
  ResourceBundle svBundle = ResourceBundle.getBundle("i18n.TestResourceBundle", svLocale);
  visualizar(svBundle, svLocale);
  
  Locale spLocale = new Locale("es", "ES");
  ResourceBundle spBundle = ResourceBundle.getBundle("i18n.TestResourceBundle", spLocale);
  visualizar(spBundle, spLocale);
    
  Locale enLocale = new Locale("en", "US");
  ResourceBundle enBundle = ResourceBundle.getBundle("i18n.TestResourceBundle", enLocale);
  visualizar(enBundle, enLocale);
    
 } 
  
 public static void visualizar(ResourceBundle bundle, Locale lo) {
  if(lo == null) { lo = Locale.getDefault();}
  System.out.println("Idioma: "+lo.getLanguage()); 
  System.out.println(".........................................................");
  System.out.println("Contenido Mensaje -->hello: " +" "+ bundle.getString("my.hello"));
  System.out.println("Contenido Mensaje -->goodbye: " +" "+ bundle.getString("my.goodbye"));
  System.out.println("Contenido Mensaje -->question: " +" "+ bundle.getString("my.question"));
  System.out.println("=========================================================");
 } 
}
```

El resultado de la ejecución se mostraría mediante la consola y sería algo así:

```
Idioma: es
…………………………………………………
Contenido Mensaje –>hello:  Hola
Contenido Mensaje –>goodbye:  Adios
Contenido Mensaje –>question:  ¿Hablas inglés?
=========================================================
Idioma: es
…………………………………………………
Contenido Mensaje –>hello:  Hola
Contenido Mensaje –>goodbye:  Adios
Contenido Mensaje –>question:  ¿Hablas inglés?
=========================================================
Idioma: sv
…………………………………………………
Contenido Mensaje –>hello:  Hejsan
Contenido Mensaje –>goodbye:  Hejd?
Contenido Mensaje –>question:  Pratar du engelska?
=========================================================
Idioma: es
…………………………………………………
Contenido Mensaje –>hello:  Hola
Contenido Mensaje –>goodbye:  Adios
Contenido Mensaje –>question:  ¿Hablas inglés?
=========================================================
Idioma: en
…………………………………………………
Contenido Mensaje –>hello:  Hello
Contenido Mensaje –>goodbye:  Bye
Contenido Mensaje –>question:  Do you speak English?
=========================================================
```
