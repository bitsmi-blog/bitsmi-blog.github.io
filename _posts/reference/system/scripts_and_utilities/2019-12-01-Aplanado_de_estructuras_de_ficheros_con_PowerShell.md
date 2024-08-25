---
author: Antonio Archilla
title: Aplanado de estructuras de ficheros con PowerShell
date: 2019-12-01
categories: [ "references", "system", "scripts and utilities" ]
tags: [ "windows" ]
layout: post
excerpt_separator: <!--more-->
---

En este post se muestra una implementación de copia plana de los contenidos de un árbol de directorios determinado mediante un script de **PowerShell**. 
Dicho de otra manera, el resultado de la ejecución de este _script_ copiará en un mismo directorio destino todos los ficheros contenidos en un directorio origen y todos sus subdirectorios.

<!--more-->

## Función de copia de ficheros

La función de copia plana de ficheros implementada tiene como entrada 2 parámetros que indican el directorio origen a copiar y el destino.  
Hace uso de la función `Get-ChildItem` de la librería estándar de **Windows** para recorrer los ficheros (flag `-File`) de un directorio de forma recursiva (flag `-recurse`). 
Con cada uno de ellos se llamará a la función de copiado `Copy-Item` (o su alias `cp`) indicando el origen y destino de la copia. 
Cabe remarcar el uso del atributo Fullname sobre el origen para obtener el la ruta completa del fichero origen y del atributo name para obtener solamente el nombre 
del fichero para así componer la ruta destino del mismo. A continuación se muestra el código de la función:

```sh
function flatten-copy($srcdir,$destdir) 
{ 
    Get-ChildItem $srcdir -recurse -File | foreach($_) {
        try{ 
            cp $_.Fullname ($destdir+'/'+$_.name) -ErrorAction Stop 
        } 
        catch{ 
            log-write "$_" 
        } 
    } 
}
```

El tratamiento de errores de las operaciones de copia implementa un bloque `try / catch` donde se utiliza la función `log-write` para escribir 
la correspondiente traza en un fichero de log identificado con la fecha actual. Mediante el flag `-ErrorAction Stop` se le indica al comando `cp` que propague el error 
hacia el bloque `try / catch`. El código de dicha función se muestra a continuación:

```sh
function log-write
{   
    Param ([string]$message)
    
    $logFile = 'log_' + (get-date).ToString('yyyyMMdd') + '.txt'
    $logTimestamp = (get-date).ToString('dd/MM/yyyy HH:mm:ss')

    Add-content $logfile "$logTimestamp - $message"
}
```

## Habilitar los permisos de ejecución en Powershell

Para ejecutar el script de copia expuesto arriba, es necesario habilitar los permisos permisos de ejecución en **PowerShell**. 
Se puede comprobar si están habilitados ejecutando el siguiente comando en **PowerShell**:

```sh
Get-ExecutionPolicy
```

Si el resultado es `Restricted`, será necesario habilitarlos de la siguiente manera:

```sh
Set-ExecutionPolicy Unrestricted
```

A continuación **PowerShell** pedirá la confirmación de la acción. Si se ha habilitado la ejecución, el resultado del comando `Get-ExecutionPolicy` será `Unrestricted`.


## Ejecución del script de Powershell des de CMD

Para ejecutar el script anterior des de CMD se utilizará el siguiente comando:

```
powershell -command "& { . <ruta script>; <nombre funcion copia> <directorio origen> <directorio destino> }"
```

Donde:

- **\<ruta script\>**: Es la ruta completa al script de **PowerShell** que implementa la función de copiado
- **\<nombre función copia\>**: Nombre de la función de copia implementada en el script. En el ejemplo, `flatten-copy`
- **\<directorio origen\>**: Parámetro de la función de copia que indica el directorio que contiene los ficheros que se quieren copiar.
- **\<directorio destino\>**: Parámetro de la función de copia que indica el directorio que contiene los ficheros que se quieren copiar.

Por ejemplo, si el script tiene como nombre `FlattenFolder.ps1`, se encuentra en el directorio `c:\test\bin` y se quiere copiar el contenido del 
directorio `c:\test\source en c:\test\target`, el comando sería como el siguiente:

```sh
powershell -command "& { . c:\test\bin\FlattenFolder.ps1; flatten-copy c:\test\source c:\test\target }"
```

