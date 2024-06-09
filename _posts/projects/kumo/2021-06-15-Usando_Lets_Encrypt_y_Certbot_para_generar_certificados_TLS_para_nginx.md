---
author: Antonio Archilla
title: Usando Let's Encrypt y Certbot para generar certificados TLS para nginx
date: 2021-06-15
categories: [ "project", "kumo" ]
tags: [ "certbot", "nginx" ]
layout: post
excerpt_separator: <!--more-->
---

[Let's Encrypt](https://letsencrypt.org) es una autoridad de certificación que proporciona **certificados TLS** de forma gratuita a todo *host* que lo necesite para securizar las comunicaciones con éste. Si además se utiliza un sistema NOIP como [DuckDNS](http://www.duckdns.org) como servidor DNS, se consigue sin costes adicionales tener un servidor publicado en la red aunque no se disponga de IP fija. 

Las **únicas contrapartidas** que tiene son que el host ha de ser **accesible desde internet**, lo que deja fuera a hosts dentro de intranets, y que la duración del certificado generado es de 3 meses, lo que implica una renovación constante. 

Afortunadamente, el proceso de generación y renovación de los certificados se puede automatizar completamente mediante la herramienta [Certbot](https://certbot.eff.org) que tiene soporte para multitud de sistemas operativos y plataformas cloud.

En este post se describe el proceso de generación de certificados para un servidor HTTP **nginx** ubicado en un sistema **Ubuntu 20.04** con IP dinámica gestionada por el servicio **DuckDNS**.

<!--more-->

## Instalación de Certbot

**Certbot** se puede obtener en **Ubuntu** mediante el correspondiente paquete **Snap**. Para su instalación se deberán ejecutar los siguientes comandos:

- Asegurar que se tiene instalada la última versión de **snapd** (actualizarla en caso contrario) 
```sh
sudo snap install core
sudo snap refresh core
```

- Instalar Certbot
```sh
sudo snap install --classic certbot
```

- Crear un acceso directo en el Path del sistema
```sh
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

## Generación del certificado mediante Certbot

El proceso de generación y renovación de los certificados se realiza mediante una llamada a **Certbot** que utiliza el protocolo [ACME](https://en.wikipedia.org/wiki/Automated_Certificate_Management_Environment) para validar que el servidor sobre el que se está generando el certificado sea quien dice ser. 

**Certbot** dispone de modos automáticos para gestionar diferentes plataformas y aplicativos, como por ejemplo utilizando el *flag* `--nignx`, este se encarga de gestionar también la configuración de **nginx**. 

La página oficial de [Certbot](https://certbot.eff.org) dispone de un selector que permite consultar los comandos disponibles para cada sistema/plataforma. En el proceso que se detalla en este post se utilizará la opción `--manual` junto con `certonly` para gestionar, por un lado los certificados y por otro, la configuración del servidor http de forma manual:

```sh
certbot certonly -n -q --agree-tos --email foo@bar.com --manual -d "*.foo-bar.duckdns.org" --preferred-challenges dns --manual-auth-hook /usr/local/certbot/duckdns-certbot --manual-cleanup-hook "/usr/local/certbot/duckdns-certbot clear"
```

Entre las opciones adicionales que se utilizan en el comando, se encuentran las siguientes:

- `-n`: Modo no interactivo. Útil para lanzar el proceso mediante tarea programada.
- `-q`: Mostrar sólo los errores en los reportes de log.
- `--agree-tos`: Aceptar el ACME server's Subscriber Agreement.
- `--email foo@bar.com`: Email usado para el registro y como contacto de recuperación.
- `-d "*.foo-bar.duckdns.org"`: Dominios que se quiere registra. Admite subdominios mediante el uso de *.
- `--preferred-challenges dns`: Mecanismo usado para la validación del dominio. En este caso se utilizan los registros TXT del servicio DNS para albergar valores especificados por **Certbot** en el proceso de generación del certificado y que este pueda validar que puede acceder a ellos. Requiere el uso de *hooks* para cargar los valores de los registros TXT.
- `--manual-auth-hook /usr/local/certbot/duckdns-certbot` y `--manual-cleanup-hook "/usr/local/certbot/duckdns-certbot cleanup"`: *Hooks* utilizados para crear los registros TXT en el servidor DNS y limpiarlos una vez finalizado el proceso. En el caso del ejemplo se utilizará la rest API del servicio DuckDNS para ello ejecutando las llamadas correspondientes en el script `duckdns-certbot`. En el siguiente apartado se muestra su contenido.

Adicionalmente se puede añadir la opción `--dry-run` para simular todo el proceso sin generar los certificados y ver si todo funciona correctamente.

El siguiente código corresponde al script `/usr/local/certbot/duckdns-certbot` utilizado como ***hook*** para cargar los registros TXT en el servicio **DuckDNS** para que **Certbot** pueda validarlo. 

```sh
#!/bin/bash

# Substituir el valor por el código proporcionado por DuckDNS
DUCKDNS_TOKEN = "12345678-1234-1234-1234-1234567890"

# Se verifica que Certbot proporcione el parámetro con el valor del dominio que se está validando
if [[ ! $CERTBOT_DOMAIN ]]; then
    echo "Dominio no proporcionado"
    exit 1
fi

# DuckDNS usa un único registro TXT para todos los sub dominios pertenecientes a una misma cuenta
# Para dominios con la forma *.foo-bar.duckdns.org se obtiene el sub dominio principal eliminando las partes "duckdns.org" y el *wildcard*
# En este caso el valor que se pasa a la Rest API de DuckDNS es "foo-bar"
CERTBOT_DOMAIN=${CERTBOT_DOMAIN%%.duckdns.org}
CERTBOT_DOMAIN=${CERTBOT_DOMAIN##*.}

if [[ $1 == "clear" ]]; then
	# En caso que se ejecute el reset de los registros TXT, se envia una petición con "crear=true" a DuckDNS
    echo "Reset del dominio ${CERTBOT_DOMAIN}"
    curl -s "https://www.duckdns.org/update?domains=${CERTBOT_DOMAIN}&token=${DUCKDNS_TOKEN}&txt=whatever&clear=true"	
elif [[ $CERTBOT_VALIDATION ]]; then
	# Con el código de validación que proporciona Certbot, se actualiza el registro TXT de DuckDNS para el sub dominio indicado
    echo "Actulizando registros del dominio ${CERTBOT_DOMAIN}"
    curl -s "https://www.duckdns.org/update?domains=${CERTBOT_DOMAIN}&token=${DUCKDNS_TOKEN}&txt=${CERTBOT_VALIDATION}"
else
    echo "Error: No se ha proporcionado código de validación"
    exit 1
fi

# Se espera un tiempo para que se propague el cambio en el DNS
sleep 10s
```

Una vez ejecutado el comando `certbot` descrito en este apartado, si todo ha ido bien, los certificados generados se encontrarán en un sub directorio dentro de `/etc/letsencrypt/live` correspondiente al dominio generado, siendo `/etc/letsencrypt/live/foo-bar.duckdns.org` en el caso de ejemplo ilustrado en este post. 

Dentro se encontrarán los siguientes ficheros:
- `privkey.pem`: La clave privada del certificado
- `fullchain.pem`: El fichero que contiene la cadena completa de certificación a usar en la configuración del servidor **HTTP**
- `chain.pem`: Usado para [OCSP stapling](https://en.wikipedia.org/wiki/OCSP_stapling) en **Nginx** >=1.3.7
- `cert.pem`: Contiene la clave pública del certificado. Este fichero no se debe usar en configuraciones de servidor a menos que se sepa lo que se hace ya que puede provocar errores

En caso de haberse producido un error en la ejecución de **Certbot** se podrá consultar dicha causa en los ficheros de log ubicados en el directorio `/var/log/letsencrypt`

## Configuración de los certificados en Nginx

Para especificar los certificados en la configuración de **nginx** se deberá crear un fichero de *snippet* en el directorio `/etc/nginx/snippets`, por ejemplo `/etc/nginx/snippets/letsencrypt.conf` con el siguiente contenido:
```
ssl_certificate /etc/letsencrypt/live/foo-bar.duckdns.org/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/foo-bar.duckdns.org/privkey.pem;
```
dónde se especifican las rutas a los ficheros de la cadena de certificación completa y la clave privada del certificado. 

Se deberá eliminar toda configuración de certificados anterior en caso de existir alguna y añadir este *snippet* en la configuración de *sites* de **nginx** correspondiente dentro del directorio `/etc/nginx/sites-available` mediante la sentencia `include snippets/letsencrypt.conf;`. 

Esto puede variar según la configuración que se haya establecido en el servidor, por ejemplo si no se utilizan *snippets* y se añaden directamente las configuraciones de los certificados en la configuración de los sites.

Una vez hecha la modificación de la configuración, se deberá reiniciar el servidor para que los cambios tengan efecto:

```sh
sudo restart nginx
```

## Programación de la renovación del certifcado

**NOTA:** Si `certbot` ha sido instalado mediante el gestor de paquetes **snap**, automáticamente se habrá programado un *timer* que se ejecutará diariamente u será el encargado de comprobar si el certificado se tiene que renovar.

Esto implica que el procedimiento explicado aquí sólo se deberá de llevar a cabo si se decide obviar el servicio de actualización por defecto (`snap.certbot.renew.service` y `snap.certbot.renew.timer`). 

Para consultar si el servicio por defecto se encuentra activo, se podrá hacer mediante los comandos:
```sh
sudo systemctl list-timers
sudo systemctl status snap.certbot.renew.timer
sudo systemctl status snap.certbot.renew.service
```

Dado que los certificados generados tienen una validez de 3 meses y para no tener que estar pendientes de si estos expirarán pronto o no, se puede utilizar una tarea programada que vuelva a ejecutar el comando de **Certbot** periódicamente. 

En este ejemplo se utilizará un servicio del sistema **systemd** disparado mensualmente por un temporizador. De igual modo, este proceso también se podría ejecutar mediante un **crontab**.

La definición del servicio es la siguiente (Fichero `/etc/systemd/system/certbot-renew.service`). Se deberá adecuar el comando indicado en `ExecStart` con los parámetros adecuados:
```
[Unit]
Description=Servicio de renovación de Certbot
Documentation=https://certbot.eff.org/docs/ http://www.duckdns.org/spec.jsp
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=certbot certonly -n -q --agree-tos --email foo@bar.com --manual -d "*.foo-bar.duckdns.org" --preferred-challenges dns --manual-auth-hook /usr/local/certbot/duckdns-certbot --manual-cleanup-hook "/usr/local/certbot/duckdns-certbot clear"
```

La definición del temporizador que ejecuta el servicio es la siguiente (Fichero `/etc/systemd/system/certbot-renew.timer`):
```
[Unit]
Description=Ejecución mensual del servicio de renovación de Certbot

[Timer]
OnCalendar=Monthly
Persistent=true

[Install]
WantedBy=multi-user.target
```

Para activar el temporizador se deberá ejecutar el siguiente comando:
```sh
sudo systemctl start certbot-renew.timer
```
