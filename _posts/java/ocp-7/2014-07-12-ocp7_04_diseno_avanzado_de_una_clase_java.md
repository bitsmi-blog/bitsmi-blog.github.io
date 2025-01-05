---
author: Antonio Archilla
title: OCP7 04 – Diseño avanzado de una clase Java
date: 2014-07-12
categories: [ "java", "ocp-7" ]
tags: [ "java", "ocp-7" ]
layout: post
excerpt_separator: <!--more-->
---

## Classes

Las clases **abstractas** sirven para indicar el comportamiento general que deben tener sus subclases sin implementar algunos métodos. Dichas subclases son las que se encargan de implementar estos métodos.

```java
abstract class FiguraGeometrica {
     abstract void dibujar();
}
 
class Circulo extends FiguraGeometrica {
    void dibujar() {
     // codigo para dibujar Circulo
   }
}
```

Una clase que tenga uno o más métodos abstractos se llama clase abstracta. Debe contener en su declaración el termino `abstract`. A su vez, esta clase puede también contener **métodos que no sean abstractos**.
Un **método abstracto** contiene el termino `abstract` en su declaración y no dispone de ninguna implementación: `abstract type nom_metodo();`
Es obligatorio que todas las subclases que heredan de la clase abstracta realicen la implementación de todos los métodos abstractos de la superclase dentro de su especificidad.

Aunque una clase abstracta puede ser utilizada como tipo de referencia, ésta no puede ser instanciada ya que su implementación está completa y si se intenta se producirá un error de compilación.

## Palabras Reservadas 

### Static

Es útil disponer de una variable compartida por todas las instancias de una clase mediante el modificador `static`.
Los campos que tienen static en su declaración se llaman campos estáticos o variables de clase.

Si existen por ejemplo tres objetos definidos que tienen el campo definido como estático, todas sus instancias pueden modificar 
el valor de dicho campo dado que está compartido por todos los objetos de la misma clase.

Para referenciar el campo estático es suficiente utilizar el nombre de la clase para acceder al campo.

Un método estático también tiene el modificador static en su declaración. También puede ser invocado sólo con el nombre de clase sin necesidad de instanciar el tipo.
Cualquier de acceso a campos o métodos no estáticos provocará un error de compilación.
Una clase también puede contener bloques de código estáticos que no forman parte de los métodos normales. Estos bloques estáticos se encuentran encerrados entre llaves. El código dentro de los bloques estáticos sólo se ejecuta una única vez, cuándo la clase se carga por primera vez. Si aparecen varios bloques dentro de la clase, éstos se ejecutan por orden de aparición en la clase.
Importaciones static: Pueden utilizarse cuándo queramos importar campos o métodos estáticos de una clase sin anteponer el nombre de la misma:       

```java
import static java.lang.Math.random
```

y al no ser necesario anteponer el nombre de la clase al utilizar la importación estática su implementación queda de la siguiente manera:

```java
double d = random();
System.out.println(d);
```

### Final

Las clases, los métodos y las variables pueden ser finales.

- En las clases. No se pueden generar subclases a partir de esta clase.
- En los métodos. No pueden ser sobrescritos.
- En las variables: campos, parámetros o variables locales.

Una variable de referencia como final no puede hacer referencia a otro objeto (aunque puede modificarse el estado del mismo)
Un campo puede posponer su inicialización (inicializarse mediante un constructor de la clase) o inicializarse en su declaración. Una vez está inicializado no es posible modificar su valor. El intento de modificarlo provoca un error de compilación.

Si se marca una variable como local se le podrá asignar el valor en cualquier momento dentro del cuerpo del método pero sólo una vez.

Dentro de los parámetros formales de un método si marcamos uno de los parámetros como final, el valor recibido en el método no podrá ser modificado dentro del cuerpo del método dando un error de compilación si se intenta.
Si se utilizan `static` y `final` conjuntamente como en el caso de ejemplo:

```java
private static final int field;   
```

se puede considerar el campo como una constante.  Las constantes no se pueden reasignar y se producirá un error de compilación si se intenta.

## Enumeraciones

```java
public enum Day {
	 SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY,
	 SATURDAY;
}
```

Un tipo enumerado es un tipo cuyos campos son un conjunto de constantes. Proporciona una comprobación de rango en tiempo de compilación.
El compilador interpreta la Enum como una clase Java por lo que es posible declararla fuera de una clase o dentro de ella como una clase interna.
Todas las enumeraciones extienden implícitamente de la clase Enum.
Las enumeraciones pueden ser importadas estáticamente:

```java
import static package.Day.*;
```

Esto permite no ser necesario que el nombre de la enumeración preceda la constante.

Una enumeración proporciona una comprobación de rango en tiempo de compilación. Si se intenta asignar un valor que no se encuentra en la enumeración se produce un error de compilación.
Debido a que los tipos enumerados son como una clase Java además de declarar constantes, un tipo enumerado puede contener:

- campos
- métodos
- constructores privados. El constructor de una enumeración es privado por lo que no es posible crear instancias de una enumeración.  Los argumentos del constructor se suministran después de cada valor declarado:

```java
public enum Day {
 
    SUNDAY("Sunday"),
    MONDAY("Monday"),
    TUESDAY("Tuesday"),
    WEDNESDAY("Wednesday"),
    THURSDAY("Thursday"),
    FRIDAY("Friday"),
    SATURDAY("Saturday");
 
    private final String name;
 
    private Day(String name) {
        this.name = name;
    }
 
    public String getName() {
        return name;
    }   
}
```

Cuándo hay campos, métodos o constructores, la lista de constantes de la enumeración debe terminar con un punto y coma.

Las enumeraciones pueden implementar interfaces pero no pueden extender otras enumeraciones. Una posible utilidad de esto es «esconder» la enumeración referenciando a la interfaz:

```java
public enum Day implements IDayOfWeek
{
             SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY,
             SATURDAY;
}
 
...
 
IDayOfWeek dow = Day.SUNDAY;
```

## Clases Anidadas

Es una clase declarada en el cuerpo de otra clase.

```java
import java.util.ArrayList;
 
public class Coordenadas {
 
    private class Punto {
        private int x, y;
 
        public Punto(int x, int y) {
            fijarX(x);
            fijarY(y);
        }
 
        public void fijarX(int x) {
            this.x = x;
        }
 
        public void fijarY(int y) {
            this.y = y;
        }
 
        public int retornarCuadrante() {
            if (x > 0 && y > 0)
                return 1;
            else if (x < 0 && y > 0)
                return 2;
            else if (x < 0 && y < 0)
                return 3;
            else if (x > 0 && y < 0)
                return 4;
            else
                return -1;
        }
    }
 
    private ArrayList<Punto> puntos;
 
    public Coordenadas() {
        puntos = new ArrayList<Punto>();
    }
 
    public void agregarPunto(int x, int y) {
        puntos.add(new Punto(x, y));
    }
 
    public int cantidadPuntosCuadrante(int cuadrante) {
        int cant = 0;
        for (Punto pun : puntos)
            if (pun.retornarCuadrante() == cuadrante)
                cant++;
        return cant;
    }
 
}
```

Pueden dividirse en dos categorías:

### Clases Internas.

- **Clases miembro**: Están declaradas dentro de una clase y fuera de cualquier método. Esta clase tiene acceso a los campos y a los métodos de la clase anterior, así como de los campos y los métodos de la superclase de la que herede.  
**No es posible declarar ninguna clase miembro estático debido a que una clase miembro es cargada sólo dentro del contexto de una instancia de su clase exterior.**

```java
public class DataStructure {
     
    // Create an array
    private final static int SIZE = 15;
    private int[] arrayOfInts = new int[SIZE];
     
    public DataStructure() {
        // fill the array with ascending integer values
        for (int i = 0; i < SIZE; i++) {
            arrayOfInts[i] = i;
        }
    }
     
    public void printEven() {
         
        // Print out values of even indices of the array
        DataStructureIterator iterator = this.new EvenIterator();
        while (iterator.hasNext()) {
            System.out.print(iterator.next() + " ");
        }
        System.out.println();
    }
     
    interface DataStructureIterator extends java.util.Iterator<Integer> { } 
 
    // Inner class implements the DataStructureIterator interface,
    // which extends the Iterator<Integer> interface
     
    private class EvenIterator implements DataStructureIterator {
         
        // Start stepping through the array from the beginning
        private int nextIndex = 0;
         
        public boolean hasNext() {
             
            // Check if the current element is the last in the array
            return (nextIndex <= SIZE - 1);
        }        
         
        public Integer next() {
             
            // Record a value of an even index of the array
            Integer retValue = Integer.valueOf(arrayOfInts[nextIndex]);
             
            // Get the next even element
            nextIndex += 2;
            return retValue;
        }
    }
     
    public static void main(String s[]) {
         
        // Fill the array with integer values and print out only
        // values of even indices
        DataStructure ds = new DataStructure();
        ds.printEven();
    }
}
```

- **Clases locales**: Declarada dentro de un bloque de código en el cuerpo de un método y sólo es visible dentro del bloque de código en el que se ha definido. 
En las clases internas locales primero se define la clase y luego se crean uno o más objetos según la necesidad.

```java
public class LocalClassExample {
   
    static String regularExpression = "[^0-9]";
   
    public static void validatePhoneNumber(
        String phoneNumber1, String phoneNumber2) {
       
        final int numberLength = 10;
         
        // Valid in JDK 8 and later:
        
        // int numberLength = 10;
        
        class PhoneNumber {
             
            String formattedPhoneNumber = null;
 
            PhoneNumber(String phoneNumber){
                // numberLength = 7;
                String currentNumber = phoneNumber.replaceAll(
                  regularExpression, "");
                if (currentNumber.length() == numberLength)
                    formattedPhoneNumber = currentNumber;
                else
                    formattedPhoneNumber = null;
            }
 
            public String getNumber() {
                return formattedPhoneNumber;
            }
             
            // Valid in JDK 8 and later:
 
//            public void printOriginalNumbers() {
//                System.out.println("Original numbers are " + phoneNumber1 +
//                    " and " + phoneNumber2);
//            }
        }
 
        PhoneNumber myNumber1 = new PhoneNumber(phoneNumber1);
        PhoneNumber myNumber2 = new PhoneNumber(phoneNumber2);
         
        // Valid in JDK 8 and later:
 
//        myNumber1.printOriginalNumbers();
 
        if (myNumber1.getNumber() == null) 
            System.out.println("First number is invalid");
        else
            System.out.println("First number is " + myNumber1.getNumber());
        if (myNumber2.getNumber() == null)
            System.out.println("Second number is invalid");
        else
            System.out.println("Second number is " + myNumber2.getNumber());
 
    }
 
    public static void main(String... args) {
        validatePhoneNumber("123-456-7890", "456-7890");
    }
}
```

- **Clases anónimas**: Se usan para definir clases sin nombre. Cómo la clase anónima no tiene nombre sólo se puede crear un único objeto ya que las clases anónimas no pueden definir constructores.

```java
public class HelloWorldAnonymousClasses {
   
    interface HelloWorld {
        public void greet();
        public void greetSomeone(String someone);
    }
   
    public void sayHello() {
         
        class EnglishGreeting implements HelloWorld {
            String name = "world";
            public void greet() {
                greetSomeone("world");
            }
            public void greetSomeone(String someone) {
                name = someone;
                System.out.println("Hello " + name);
            }
        }
       
        HelloWorld englishGreeting = new EnglishGreeting();
         
        HelloWorld frenchGreeting = new HelloWorld() {
            String name = "tout le monde";
            public void greet() {
                greetSomeone("tout le monde");
            }
            public void greetSomeone(String someone) {
                name = someone;
                System.out.println("Salut " + name);
            }
        };
         
        HelloWorld spanishGreeting = new HelloWorld() {
            String name = "mundo";
            public void greet() {
                greetSomeone("mundo");
            }
            public void greetSomeone(String someone) {
                name = someone;
                System.out.println("Hola, " + name);
            }
        };
        englishGreeting.greet();
        frenchGreeting.greetSomeone("Fred");
        spanishGreeting.greet();
    }
 
    public static void main(String... args) {
        HelloWorldAnonymousClasses myApp =
            new HelloWorldAnonymousClasses();
        myApp.sayHello();
    }            
}
```

### Clases anidadas estáticas.

Se definen mediante el modificador static y sólo pueden ser creadas dentro de otra clase al máximo nivel, es decir, directamente en el bloque de definición de la clase contenedora y no en un bloque más interno.

```java
clase ClaseExterior
{ 
... 
    clase ClaseAnidada
    { 
        ... 
    } 
}
```