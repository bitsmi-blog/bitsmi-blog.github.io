---
author: Antonio Archilla
title: OCP11 - Localization & Internationalization
date: 2022-01-16
categories: [ "java", "ocp-11-17" ]
tags: [ "ocp-11", "ocp-17" ]
layout: post
excerpt_separator: <!--more-->
---

**Internationalization** is the process by which an application is designed to adapt to multiple regions and languages using the mechanisms provided by the platform, Java Platform in this case. This includes placing text strings in properties files for every supported language, ensure that a proper formatting is used when data is displayed (E.G. numbers and dates), etc. This process is also known as **I18N** 

A **localized** application is compatible with multiple language and country/region configurations (**locales**). The **localization** process is also known as **L12N**.

<!--more-->

## Choosing a locale

**Locale** can be represented by a string including a lower case language code or a language code and a uppercase region code separated by an underscore. E.G:
- **en_US**: Locale for english language of the USA
- **en**: Locale for english language 

Java platform provides the `java.util.Locale` class which allows working with locales. There are multiple ways to choose a locale:

- Default **locale** for the current user. This locale is defined by the system:
```java
Locale locale = Locale.getDefault();
```
- Locale constants for common languages and country / language pairs:
```java 
Locale.GERMAN;   // de
Locale.GERMANY;  // de_DE
Locale.FRENCH;	// fr
Locale.FRANCE;	// fr_FR
```
- Using `Locale` constructor:
```java
Locale locale = new Locale("de_DE");
```
- Using a builder:
```java
// de_DE
Locale locale = new Locale.Builder()
		.setlanguage("de")
		.setRegion("DE")
		.build();
```

The default locale for the current user can be changed as follows:
```java
Locale locale = ...
Locale.setDefault(locale);
```
This will only change the locale for the current application execution. It does not change any system settings.

You can control which operations the default specified **locale** applies to. A 2 parameter variant of `Locale.setDefault()` method allows you to choose if the **locale** will be used in data formatting operations or just to display data from the locale itself specifying a `Locale.Category` enum value, `Locale.Category.FORMAT` for formatting operations and `Locale.Category.DISPLAY` for display locale data operations.

```java
Locale english = new Locale("en_US");
Locale spanish = new Locale("es_ES");

// Set default locale to english
Locale.setDefault(english); 
// Set display locale data translated to spanish language
Locale.setDefault(Locale.Category.DISPLAY, spanish); 

double n = 1.23;

// Displays currency in en_US locale format and locale name translated to spanish ($1.23, inglés)
System.out.println(NumberFormat.getCurrencyInstance().format(n) + ", " + english.getDisplayLanguage()); 

```

## Resource bundles

The **Localization** process requires externalizing application's text strings to specific objects that can be switched according to the current user's regional configuration. This objects are known as **Resource Bundles**.

The specifications for the use of resource files through Java's **ResourceBundle API** define rules for the naming and location of these files that must be followed so that the JVM can locate and recover the resources defined in them:

- The files must have a name in the following format `<BundleName>[_<language>[_<country>]].<java | properties>`, where:
	- `BundleName` refers to the identifier of the set of resources that is being defined. The user is free to choose the identifier that suits you the most and then be able to use it within the application code.
	- `language` refers to the language code in **I18N** format. E.G. `es` for spanish or `en` for english. The indication of the language is optional if you want to define the set of resources that will correspond to the default location defined for the JVM in which the application is executed.
	- `country` refers to the country code associated with the selected language. If, for example, the same language has multiple variants, such as UK and USA english variants, it will be allowed to differentiate between them using this code, in this case `en_GB` and `en_US` respectively. If the resources set is generally defined for a language without taking into account the variants, it is not necessary to specify this code.
- Every filename component must be separated by an underscore
- The files must be located within the Classpath of the application
- Resources bundles can be defined as **properties files** or **java classes**

#### Properties resource bundle

A **resource bundle properties file** is defined as a regular properties file in which every key / value pair corresponds to an externalized text string. The following example shows a **resource bundle** for **en_EN** locale:
```properties
message.hello=Hello
message.goodbye=Bye
message.question=Do you speak English?
```

#### Properties resource bundle

A **resource bundle java class** must extend `java.util.ResourceBundle` class and implement `handleGetObject` and `getKeys` abstract methods. The following code snippet shows the definition of the previous **resource bundle** as a java class:
```java
// MessageBundle_en_EN.java
import java.util.ResourceBundle;
import java.util.HashMap;
import java.util.Collections;

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
		data.put("message.hello", "Hello");                               
		data.put("message.goodbye", "Bye");                               
		data.put("message.question", "Do you speak English?");        
	}
  
	/**
	 * Returns the value defined in this resource bundle for the provided key or null if it's not defined.
	 */
	@Override
	protected Object handleGetObject(String key) 
	{
		return data.get(key);
	}
 
	/**
	 * Provides the list of supported keys for this resource bundle
	 */
	@Override
	public Enumeration getKeys() 
	{
		return Collections.enumeration(data.keySet());
	}
}
``` 

#### Load a resource bundle

**Resource bundles** can be loaded through `getBundle()` method:

```java
// Default locale
ResourceBundle rb1 = ResourceBundle.getBundle("messages");
// Specific locale
ResourceBundle rb2 = ResourceBundle.getBundle("messages", new Locale("en_US"));
```

Which will try to find a resource with the specified name according these rules in that order:

1. Java class for requested locale (Both language and country codes)
2. Properties file for requested locale (Both language and country codes)
3. Java class for requested locale's language
4. Properties file for requested locale's language
5. Java class for default locale (Both language and country codes)
6. Properties file for default locale (Both language and country codes)
7. Java class for default locale's language
8. Properties file for default locale's language
9. java class with no locale
10. Properties file with no locale
11. Throw MissingResourceException

#### Using a resource bundle

Once **resource bundle** has been resolved, the externalized string can be retrieved through the `getString()` method.

```java
ResourceBundle rb = ...
String message = rb.getString("messageKey");
```

Resource bundles are hierarchical so if a key is not found it will be searched in any parent of the matching resource bundle. E.G. For the matching resource bundle `messages_en.java`, keys can come from `messages_en.java` or `messages.java` but not from `messages_en_US.java`. Note that if the matching resource bundle is a Java class or a properties file, **hierarchic search will only be made on the same type resource bundle**. If the key is still not found at the end, a `MissingResourceException` will be thrown.

Resource bundles doesn't support variable substitution of externalized strings. Using `MessageFormat` class we can parameterize them as follows:

Given the following resource bundle properties file:

```properties
message.hello=Hello {0} {1}
```

Variable placeholders are specified as numbers wrapped into braces. The number indicates the order in which the parameters will be passed to the `Message.format` method, starting from **0**. Then, we can format the message with the appropriate values before display it:

```java
ResourceBundle rb = ...
String messageFormat = rb.getString("message.hello");
String formattedMessage = MessageFormat.format(messageFormat, "Ms.", "Jane Doe");
// Hello Ms. Jane Doe
System.out.println(formattedMessage);
```

## Localizing numbers

Currency and numeric values format depends on your locale. For example, for currency values, in the United States the dollar sign is prepended before the value and the cents are separated by a dot character (E.G. $1.23). In most of Europe regions, the Euro sign is appended to the value and the cents are separated by a comma character (E.G. 1,23 €).

The `java.text` package includes the `NumberFormat` class that make easier parse and format numeric values depending on locale.

Java platform provides the `java.text.NumberFormat` class which allows working with numeric / currency values and locales. There are multiple ways to retrieve a `NumericFormat` instance:

- General-purpose formatter
```java
/* For default locale */
NumberFormat f1 = NumberFormat.getInstance();
// Same as getInstance()
NumberFormat f2 = NumberFormat.getNumberInstance();
/* For specific locale */
NumberFormat f3 = NumberFormat.getInstance(locale);
// Same as getInstance()
NumberFormat f4 = NumberFormat.getNumberInstance(locale);
```
- Currency formatter
```java
/* For default locale */
NumberFormat f1 = NumberFormat.getCurrencyInstance();
/* For specific locale */
NumberFormat f2 = NumberFormat.getCurrencyInstance(locale);
```
- Percent values formatter
```java
/* For default locale */
NumberFormat f1 = NumberFormat.getPercentInstance();
/* For specific locale */
NumberFormat f2 = NumberFormat.getPercentInstance(locale);
```
- Decimal round formatter
```java
/* For default locale */
NumberFormat f1 = NumberFormat.getIntegerInstance();
/* For specific locale */
NumberFormat f2 = NumberFormat.getIntegerInstance(locale);
```

#### Formatting numeric values examples

```java
int value = 123_456;

NumberFormat f_en = NumberFormat.getInstance(Locale.US);
NumberFormat f_de = NumberForamt.getInstance(Locale.GERMANY);

// 123,456
System.out.println(f_en.format(value));
// 123.456
System.out.println(f_de.format(value));
```

#### Parsing numeric values

```java 
String strValue = "123.456";

NumberFormat f_en = NumberFormat.getInstance(Locale.US);
NumberFormat f_fr = NunberForamt.getInstance(Locale.FRANCE);

// 123.456
Double numValue_en = (Double)f_en.parse(strValue);
// 123
Double numValue_fr = (Double)f_fr.parse(strValue);
```

In this example, the parsed value for french locale is trunk at dot character because it doesn't use dot characters to separate numbers. The formatter will parse each character until a non recognized one is found. Then it discards the rest of the value and transform it into a number. This is because for french locale the value is trimmed to `123`. 

#### Custom formatters

Using the `DecimalFormatter` you can build **custom number formatters** as follows:

```java
NumberFormat f = new DecimalFormat("000,000.00");
```

The parameter received by the constructor specifies the pattern for parsing / formatting numbers. The permitted symbols in pattern are:

- **0**: Put a 0 in the position if no digit exists for it
- **#**: Omit the position if no digit exists for it

For example, the `0###.0#` will produce the following results:
```java
NumberFormat f = new DecimalFormat("0###.0#");

// 0123.4
System.out.println(f.format(123.4));
// 1234.567
System.out.println(f.format(1234.567));
```

## Localizing dates

As for numbers, date format can also depend on locale. The `java.time.format.DateTimeFormatter` allows format and parse date values. `DateTimeFormatter` instances can be retrieved through factory methods and pre-configured constants for the most common formats:

- For formatting dates
```java
DateTimeFormatter.ofLocalizedDate(dateStyle);
```
- For formatting time
```java
DateTimeFormatter.ofLocalizedTime(timeStyle);
```
- For formatting dates and time
```java
DateTimeFormatter.ofLocalizedDateTime(dateStyle, timeStyle);
```

`DateStyle` and `timeStyle` possible values are one of:
- `java.time.format.FormatStyle.SHORT`: Short text style, typically numeric.
- `java.time.format.FormatStyle.MEDIUM`: Medium text style, with some detail.
- `java.time.format.FormatStyle.LONG`: Long text style, with lots of detail.
- `java.time.format.FormatStyle.FULL`: Full text style, with the most detail.

Pre-configured instances of `DateTimeFormatter` include:
- `DateTimeFormatter.BASIC_ISO_DATE`: Basic ISO date. E.G. '20111203'
- `DateTimeFormatter.ISO_LOCAL_DATE`: ISO Local Date. E.G. '2011-12-03'
- `DateTimeFormatter.ISO_OFFSET_DATE`: ISO Date with offset. E.G. '2011-12-03+01:00'
- `DateTimeFormatter.ISO_DATE`:	ISO Date with or without offset. E.G. '2011-12-03+01:00'; '2011-12-03'
- `DateTimeFormatter.ISO_LOCAL_TIME`: Time without offset. E.G. '10:15:30'
- `DateTimeFormatter.ISO_OFFSET_TIME`: Time with offset. E.G. '10:15:30+01:00'
- `DateTimeFormatter.ISO_TIME`:	Time with or without offset. E.G. '10:15:30+01:00'; '10:15:30'
- `DateTimeFormatter.ISO_LOCAL_DATE_TIME`: ISO Local Date and Time. E.G. '2011-12-03T10:15:30'
- `DateTimeFormatter.ISO_OFFSET_DATE_TIME`: Date Time with Offset. E.G. '011-12-03T10:15:30+01:00'
- `DateTimeFormatter.ISO_ZONED_DATE_TIME`: Zoned Date Time. E.G. '2011-12-03T10:15:30+01:00[Europe/Paris]'
- `DateTimeFormatter.ISO_DATE_TIME`: Date and time with ZoneId. E.G. '2011-12-03T10:15:30+01:00[Europe/Paris]'
- `DateTimeFormatter.ISO_ORDINAL_DATE`: Year and day of year. E.G. '2012-337'
- `DateTimeFormatter.ISO_WEEK_DATE`: Year and Week. E.G. '2012-W48-6'
- `DateTimeFormatter.ISO_INSTANT`: Date and Time of an Instant. E.G. '2011-12-03T10:15:30Z'
- `DateTimeFormatter.RFC_1123_DATE_TIME`: RFC 1123 / RFC 822. E.G. 'Tue, 3 Jun 2008 11:05:30 GMT'

Formatter's locale can be specified through it's `withLocale()` method. By default it will use system's default.

Usage examples:

```java
LocaleDateTime date = LocalDateTime.of(2021, Month.DECEMBER, 1);

// Default locale. Outputs 12/01/21
DateTimeFormatter.ofLocalizedDate(FormatStyle.SHORT)
		.format(date);
// Spanish locale. Outputs 01/12/21
DateTimeFormatter.ofLocalizedDate(FormatStyle.SHORT)
		.withLocale(new Locale("es", "ES"))
		.format(date);		
// ISO format. Output 2021-12-01
DateTimeFormatter.ISO_DATE.format(date);
```

## Further reading

* [Customize the ResourceBundle load process (In Spanish)]

[//]: # (Links)
[Customize the ResourceBundle load process (In Spanish)]:http://bitsmi.com/2017/10/18/ocp7-13-localizacion-ii/
