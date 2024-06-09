---
author: Antonio Archilla
title: Monitorización de sistemas mediante Grafana - 1. Instalación 
date: 2020-08-30
categories: [ "references", "devops", "monitoring" ]
tags: [ "grafana" ]
layout: post
excerpt_separator: <!--more-->
---

El monitorizado de sistemas y aplicaciones proporciona un importante mecanismo para el análisis del funcionamiento de estos, permitiendo anticipar situaciones futuras o alertando de problemas que de otra manera quedarían ocultos o difícilmente identificables.

**Grafana** es una solución que permite el monitorizado completo de sistemas y aplicaciones mediante la recolección de **métricas** y **logs** desde multitud de fuentes de datos. 

El *stack* de **Grafana** cubre todas las fases desde la recolección del dato hasta su visualización gracias a los diferentes componentes que la componen:

- **Prometheus**: Encargado de la recolección de métricas. Utiliza un modelo **Pull** de recolección por el cual es el propio **Prometheus** quien requiere los datos al sistema monitorizado, que debe disponer de un *endpoint* al cual se pueda conectar. El *stack* dispone del componente **Node-Exporter** que proporciona acceso a multitud de métricas al instalarlo en el sistema objeto (CPU, uso de memoria, disco, red...). Es apropiado para la recolección de datos en intervalos de tiempo programados, aunque también proporciona mecanismos para su uso en ejecuciones *batch* u *one-shot*.
- **Graphite**: Encargado de la recolección de métricas. A diferencia de **Prometheus**, funciona mediante un modelo **Push**, por lo que es el propio sistema objeto de la monitorización el encargado de enviar los datos a **Graphite** a través de un *endpoint* que este provee.
- **Loki**: Encargado de la recolección de trazas de *log*. Como **Graphite** utiliza un modelo **Push** para publicar los datos en **Loki** pero afortunadamente en este caso el componente **Promtail** facilita la tarea encargándose de extraer las trazas de *log* y dándoles el formato apropiado para su publicación. 
- **Grafana**: Permite la visualización y explotación de métricas y trazas de *log* accesibles mediante la conexión a diversas fuentes de datos, entre las que se incluyen los mencionados **Prometheus**, **Graphite** y **Loki**, pero que también incluyen *plug-ins* para la conexión a servicios en la nube como **AWS CloudWatch**, **Azure Monitor**, **Google Cloud Monitoring**, bases de datos relacionales (**MySQL**, **PostgreSQL**, **MSSSQL**...), NoSQL (**ElasticSearch**, **OpenTSBD**...) o sistemas de recolección de trazas de *log* (**Jaeger**, **Zipkin**...).

Este es el inicio de una serie de artículos donde se propondrá la construcción de un sistema centralizado de monitorizado de sistemas y aplicaciones con capacidad de análisis de métricas y trazas de *log*.

<!--more-->

El sistema propuesto estará compuesto por los siguientes componentes:

- **Prometheus**: Centralizará los datos de métricas de aplicaciones y sistemas. En los sistemas monitorizados se utilizará la utilidad **Node-Exporter** para extraer las métricas requeridas.
- **Loki**: Centralizará los datos de las trazas de *log* extraídas de cada una de las aplicaciones y sistemas monitorizados. La utilidad **Promtail** permitirá extraer y transformar las trazas en el sistema origen antes de enviarlas a **Loki**.
- **Grafana**: Será el componente utilizado para la presentación y análisis de los datos recogidos. Se conectará a **Prometheus** y **Loki** de los que extraerá la información requerida por las diferentes visualizaciones que se pueden configurar.

En el presente artículo se introduce el proceso de instalación del *stack* de **Grafana** propuesto. En posteriores artículos se tratarán los procesos de extracción de datos, prestando atención a las configuraciones especificas de los componentes **Promtail** y **Node-Exporter**, el proceso de integración de los datos contenidos en **Prometheus** y **Loki** dentro de **Grafana** y la visualización y explotación de estos en **dashboards**.

## Preparación

En el ejemplo expuesto en este artículo, se realizará la instalación del *stack* de **Grafana** en un sistema **Ubuntu 18.04 Bionic**, pero las instrucciones utilizadas son compatibles o son fácilmente portables a versiones posteriores.

#### Instalación de Docker

Los servicios principales del *stack* **Prometheus**, **Loki** y **Grafana** se ejecutaran como contenedores de **Docker**. Al tratarse de múltiples contenedores que se ejecutaran de forma conjunta, se utilizará **Docker Compose** para gestionarlos en bloque. Para ello, primeramente será necesario instalar los mencionados **Docker** y **Docker-Compose** realizando las siguientes acciones:

\- **Instalación de paquetes necesarios**

```sh
sudo apt-get update

sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
```

\- **Configuración del repositorio de Docker**

```sh
# Añadir la clave gpg del repositorio al registro
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Añadir el repositorio al registro
sudo add-apt-repository "deb https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```

El comando `lsb_release` sirve para inferir la versión de **Ubuntu** que se está ejecutando, en este caso `bionic`.

\- **Instalación de los paquetes de Docker necesarios**

```sh
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose
```

## Configuración de los componentes del *stack*

Los componentes de *stack* de **Grafana** propuesto en este artículo comprenden 2 tipologías de instalación:

- Los componentes **Node-Exporter** y **Promtail** se ejecutarán de forma nativa en cada uno de los sistemas de los que se quiera obtener información. Naturalmente, esto incluye el *host* que ejecutará los contenedores de **Docker** del punto anterior, pero no están limitados a este. Para garantizar la ejecución automatizada de estos componentes, se instalarán en forma de como servicios en los sistemas requeridos.
- Los componentes **Prometheus**, **Loki** y **Grafana** se ejecutarán en forma de contenedores **Docker** en el *host* principal donde se quiera centralizar la información recogida. Para estos componentes el proceso de instalación se detallará en 2 apartados diferentes en esta misma sección: Uno correspondiente a las configuraciones necesarias en el sistema (si procede) y el apartado final **Docker-Compose Service** con las instrucciones para crear la configuración de servicios unificada mediante **Docker-Compose**.
 otro con las instrucciones necesarias para crear el contenedor de **Docker** correspondiente

La instalación de los diferentes componentes en cada uno de los sistemas se realizará tomando `/usr/local/grafana` como directorio base. Todas las rutas relativas que se especifican a continuación tomarán esta ubicación como referencia a no ser que se indique lo contrario.

#### Node-Exporter

El ejecutable de **Node-Exporter** se puede descargar desde la [siguiente dirección][node-exporter-dowload] y dispone de diferentes versiones dependiendo de la arquitectura en la que se vaya a instalar.

Una vez descargado el binario y descomprimido en el directorio `node_exporter/bin`, se creará la configuración del servicio encargado de ejecutarlo. Se deberá crear el fichero `/etc/systemd/system/node_exporter.service` con la configuración expuesta a continuación. Para este ejemplo, se presupone en el sistema el usuario `grafana` con permisos de acceso a los directorios correspondientes de la instalación de **Node-Exporter**. Será posible modificar este valor con otro usuario según sea el caso.

```
[Unit]
Description=Node Exporter (Node Exporter Service)
After=syslog.target
After=network.target

[Service]
Type=simple
User=grafana
Group=grafana
WorkingDirectory=/usr/local/grafana
ExecStart=/usr/local/grafana/node_exporter/bin/node_exporter
Environment=USER=grafana HOME=/usr/local/grafana

[Install]
WantedBy=multi-user.target
```

Para habilitar y arrancar el servicio, se deberán ejecutar los siguientes comandos:

```sh
sudo systemctl enable node-exporter
sudo systemctl start node-exporter
```

Con el servicio en ejecución, se habilitará un *endpoint* http (http://localhost:9100/metrics) donde posteriormente se conectará **Prometheus** para extraer las métricas del sistema. En un posterior artículo se detallará qué métricas concretas se exponen y cómo pueden ser filtradas.

En caso de que el sistema del que se quieren explotar los datos sea **Windows**, en lugar de **Node-Exporter** se deberá utilizar [**Windows-Exporter**][windows-exporter-home]. En este apartado se refiere únicamente el proceso de instalación para sistemas **Ubuntu** o similares.

#### Promtail

El ejecutable de **Promtail** se puede descargar desde la [siguiente dirección][promtail-dowload] y dispone de diferentes versiones dependiendo de la arquitectura en la que se vaya a instalar. Para asegurar total compatibilidad, se deberá escoger la misma versión que la escogida para el contenedor **Docker** de **Loki** (Mirar la definición del servicio de **Docker-Compose** en sección **Docker-Compose Service**). En el ejemplo correspondo a la versión `1.4.1`.

A diferencia de **Node-Exporter** el componente **Promtail** es quien inicia el envío de datos del sistema objeto del monitorizado hacia **Loki**. Su funcionamiento se basa en realizar el seguimiento de los ficheros de *log* indicados en la configuración, guardando la última posición de que ya se ha tratado. Si detecta que se han añadido nuevas trazas, las extrae de dichos ficheros, les aplicará unas transformaciones establecidas y las enviará al *endpoint* de **Loki** configurado. Todo esto se plasmará en un fichero de configuración en formato **yaml** llamado `promtail-config.yml` que se ubicará en el directorio `promtail/conf`. A continuación se muestra una configuración de ejemplo donde se puede ver como se especifica todo esto. En un posterior artículo se analizará con mayor detalle, sobretodo en lo que concierne a las fases de extracción y transformación:

{% raw  %}
```yaml
# Se indica el fichero donde se guardarán los punteros al contenido de los ficheros de log que ya han sido tratados. 
# Estos punteros se irán actualizado conforme se vayan procesando los ficheros para evitar enviar contenidos duplicados.
positions:
  filename: /usr/local/grafana/tmp/positions.yaml

# Se configura el endpoint de Loki a donde se enviará la información de las trazas extraidas
client:
  url: http://localhost:3100/loki/api/v1/push

# Configuración de la extracción 
scrape_configs:
# Se podrán definir multiples jobs para diferentes tipologias de log a los que se le aplica un nombre elegido por el usuario para diferenciarlos
- job_name: application_logs
  # El proceso de extracción y transformación consta de diferentes fases antes del envío
  pipeline_stages:
  - match:
      selector: '{host="localhost"}'
      stages:
      - regex:
          expression: '^(?P<timestamp>\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}\.\d{2,3})\s\[(?P<thread>.+)\]\s(?P<level>INFO|WARN|DEBUG|ERROR)\s(?P<logger>[a-zA-Z0-9\.]+)\s(?P<message>.*)$'
      - labels:
          level: 
          thread: 
          logger:
      - timestamp:    
          # 01=MM; 02=DD; 03=HH; 15=HH24; 04=MI; 05=SS; 2006=YYYY
          format: '2006-01-02 15:04:05.000'
          source: timestamp
      - template:
          source: message
          template: '{{ Replace .Value "\u2028" "\r\n" -1 }}'
  # Configuración de los ficheros a monitorizar y las etiquetas adicionales que se añadirán a los datos extraídos
  static_configs:
  - targets:
    - localhost
    labels:
	  # Ruta de los ficheros a monitorizar
      __path__: /logs/application/*.log
      job: application_logs
      host: localhost
```
{% endraw %}

Una vez descargado el binario y descomprimido en el directorio `promtail/bin`, se creará la configuración del servicio encargado de ejecutarlo. Se deberá crear el fichero `/etc/systemd/system/promtail.service` con la configuración expuesta a continuación. Para este ejemplo, se presupone en el sistema el usuario `grafana` con permisos de acceso a los directorios correspondientes de la instalación de **Promtail**. Será posible modificar este valor con otro usuario según sea el caso.

```
[Unit]
Description=Promtail (Promtail Service)
After=syslog.target
After=network.target

[Service]
Type=simple
User=grafana
Group=grafana
WorkingDirectory=/usr/local/grafana
ExecStart=/usr/local/grafana/promtail/bin/promtail-linux-amd64 -config.file=/usr/local/grafana/promtail/conf/promtail-config.yml
Environment=USER=grafana HOME=/usr/local/grafana

[Install]
WantedBy=multi-user.target
```

Para habilitar y arrancar el servicio, se deberán ejecutar los siguientes comandos:

```sh
sudo systemctl enable promtail
sudo systemctl start promtail
```

#### Prometheus

Dado que **Prometheus** utiliza un modelo **Pull** para la recogida de métricas, es necesario especificar los *host* y frecuencia con las que se conectará a ellos para extraer datos. Toda esta información se recogerá un el fichero en formato **yaml** llamado `prometheus.yml`. Se ubicará en el directorio `prometheus/conf` que posteriormente se montará en forma de volumen al correspondiente contenedor de **Docker**. A continuación se muestra una posible configuración de este fichero a modo de ejemplo de la conexión al sistema *host* donde se ejecuta el contenedor **Docker** de **Prometheus** para extraer las métricas recogidas por la instancia de **Node-Exporter** local. En un posterior artículo se analizará con mayor detalle:

```yaml
# Configuración global de prometheus. Contiene variables globales para las diferentes configuraciones de scrap
global:
  scrape_interval:     15s # Por defecto, el proceso de scrap se ejecuta cada 15 segundos

# Configuració de scrap
scrape_configs:
  # Nombre del job que se añade como etiqueta `job=<job_name>` a cualquier timeseries recolectada a partir de esta configuración
  - job_name: 'prometheus'

	# Es posible sobreescribir propiedades definidas de forma global para adaptarlas a cada poceso local
    scrape_interval: 5s

    # IP configurada en /etc/docker/daemon.json (parametro bip). 
	# Se utiliza para hacer referencia al host desde un contenedor de docker. Por defecto 172.17.0.1
	# En este ejemplo el puerto corresponde con el que se ha configurado para Node-Exporter anteriormente (9100)
    static_configs:      
      - targets: [ '172.17.0.1:9100' ]
```

#### Loki

Como en el caso anterior, se creará el directorio `loki/conf` donde se ubicará la configuración que se especificará al contenedor de **Docker** correspondiente a **Loki**. El fichero nombrarse como `loki-config.yaml`. Al tratarse de un componente que recibe la información de forma pasiva, por ahora bastará con hacer referencia a los parámetros por defecto recogidos en los [ejemplos de la documentación oficial][loki-default-config] de **Loki**. En un posterior artículo se analizarán con mayor detalle las posibilidades de configuración.

#### Docker-Compose Service

Una vez realizadas las configuraciones expuestas en los apartados anteriores, se definirá la configuración de servicios de **Docker compose** para el conjunto de contenedores del *stack* **Prometheus** / **Loki** / **Grafana** en el fichero `docker-compose.yml`. Esto se deberá hacer únicamente en el `host` donde se quiera centralizar la información. Siguiendo la pauta de directorios expuesta en el resto de apartados, este fichero se ubicará en el directorio `/usr/local/grafana`. El contenido del fichero será el siguiente:

```yaml
version: "3"

networks:
  grafana:

services:
  loki:
    image: grafana/loki:1.4.1
    container_name: loki_1
    ports:
      - "3100:3100"
    volumes: 
      - /usr/local/grafana/loki/conf:/etc/loki
    command: -config.file=/etc/loki/loki-config.yaml
    networks:
      - grafana
    restart: always

  prometheus:
    image: prom/prometheus:v2.17.2
    container_name: prometheus_1
    ports:
      - "9090:9090"
    volumes:
      - /usr/local/grafana/prometheus/conf:/etc/prometheus
    networks:
      - grafana
    restart: always

  grafana:
    image: grafana/grafana:master
    container_name: grafana_1
    ports:
      - "3000:3000"
    networks:
      - grafana
    restart: always
```

Los puntos clave de esta definición son:

- Se define en la sección `networks` una red interna con el nombre `grafana` que permitirá la comunicación interna entre los diferentes contenedores definidos en la sección `services`.
- Se definen en la sección `services` la configuración de los contenedores para **Loki**, **Prometheus** y **Grafana**. Para cada uno de ellos se define la imagen proveniente de **docker hub** que se utilizará como base del contenedor y un `container_name`. Una vez sea creado, servirá como referencia para identificarlo en la lista de contenedores gestionados por **Docker** en el sistema.
- En la definición del *service* `loki`:
	- Se mapea el puerto `3100` del contenedor al puerto `3100` del sistema *host* para hacer accesibles los *endpoints* de **Loki** fuera del contenedor. De otra manera los componentes **Promtail** instalados no serán capaces de registrar información de las trazas extraídas.
	- Se mapea el directorio `/usr/local/grafana/loki/conf` del sistema *host* a la ruta `/etc/loki` del contenedor para hacer accesible la configuración externa a la instancia de **Loki** que se ejecuta dentro del contenedor.
- El la definición del *service* `prometheus`: 
	- Aunque la visualización de los datos gestionados por **Prometheus** se puede hacer integramente desde **Grafana**, **Prometheus** provee de un frontal web desde el que se pueden realizar consultas directamente. Para habilitarlo se mapea el puerto `9090` del contenedor al puerto `9090` del sistema *host*. Este frontal será accesible desde la url `http://localhost:9090/graph`
	- Como en el caso del *service* de **Loki** se mapea el directorio del sistema *host* que contiene la configuración externa para la instancia (`/usr/local/grafana/prometheus/conf`) a la correspondiente ruta del contenedor (`/etc/prometheus`).
- El la definición del *service* `grafana`:
	- Se mapea el puerto `3000` del contenedor al puerto `3000` del sistema *host* para hacer accesible la interfaz web de **Grafana** fuera del contenedor.
	- A diferencia de los otros 2 contenedores, **Grafana** no require la especificación de configuraciones externas, por lo que no es necesario el mapeo de directorios al contenedor.
- A todos los servicios se les especifica que usen la red interna `grafana` (apartado `networks`) y que deben aplicar la política de reinicio `always` que permite reiniciar la ejecución de los contenedores al iniciar el sistema.

Una vez finalizada la edición del fichero `docker-componse.yml`, se procederá a la ejecución del siguiente comando para crear los contenedores y iniciar su ejecución:

```sh
sudo docker-compose up -d
```

Dado que se ha especificado una política de reinicio `always` en cada uno de los servicios, no será necesario volver a ejecutar este comando a menos que se paren los servicios manualmente.

Se podrá acceder a la interfaz web de **Grafana** a través de la url `http://localhost:3000` en un navegador. El nombre de usuario y contraseña iniciales son `admin` / `admin`. Después de la primera identificación estos podrán ser cambiados a otros valores más adecuados.
 
## Referencias

- [Grafana][grafana-home]
- [Prometheus][prometheus-home]
- [Loki][loki-home]


[//]: # (Links)
[grafana-home]:https://grafana.com/
[prometheus-home]:https://prometheus.io
[loki-home]:https://grafana.com/oss/loki/
[loki-default-config]:https://grafana.com/docs/loki/latest/configuration/examples/#complete-local-config
[promtail-download]:https://github.com/grafana/loki/releases
[node-exporter-dowload]:https://github.com/prometheus/node_exporter/releases
[windows-exporter-home]:https://github.com/prometheus-community/windows_exporter