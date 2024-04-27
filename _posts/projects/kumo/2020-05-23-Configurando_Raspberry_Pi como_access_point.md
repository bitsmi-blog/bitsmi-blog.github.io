---
author: Antonio Archilla
title: Configurando Raspberry Pi como access Point
date: 2020-05-23
categories: [ "project", "kumo" ]
tags: [ "Raspberry Pi" ]
layout: post
excerpt_separator: <!--more-->
---

En este articulo se expondrán los pasos necesarios para la configuración de la placa **Raspberry Pi 3B** funcionando con **Ubuntu Server** a modo de punto de acceso Wifi.
Con ello se creará una red inalámbrica independiente que se podrá interconectar con la interfaz *ethernet* que también incluye la placa y así permitir el intercambio de tráfico
de una a otra. Dentro de los posibles usos de esta configuración se encuentran la construcción de una red Wifi para invitados o una red secundaria de servicio para la gestión 
de dispositivos IOT. Las posibilidades que brinda el sistema operativo para la gestión de la red creada por el punto de acceso permitiría, por ejemplo, el uso del
*firewall* del sistema para limitar o filtrar el tráfico o establecer políticas de acceso de una red a otra.

<!--more-->

## Preparación

Para el funcionamiento del sistema como punto de acceso (**AP**) será necesario que la interfaz de red Wifi sobre la que se va a configurar este pueda operar en **modo AP**. 
El adaptador de red inalámbrica que lleva incorporado **Raspberry Pi 3B** o posteriores es compatible con este modo, pero si se quiere trabajar con un adaptador externo 
de tipo *dongle* se tendrá que asegurar que sea compatible. Para comprobarlo, se puede utilizar el comando `iw list` que reportará en su salida los modos compatibles para
cada interfaz inalámbrica. En caso de ser compatible incluirá el literal `AP`:

```sh
$ iw list

Wiphy phy0
...
	Supported interface modes:
                 * IBSS
                 * managed
                 * AP
                 * P2P-client
                 * P2P-GO
                 * P2P-device
...

```

Una vez comprobada la compatibilidad del adaptador de red, será necesario instalar `hostapd` (*Host access point daemon*) mediante el gestor de paquetes. 
Este *software* es necesario para convertir el adaptador de red en un servidor de punto de acceso y autenticación:

```sh
sudo apt-get install hostapd
```

También será necesario instalar el paquete `dnsmasq` que proporcionará capacidades de servidor de DNS local a la nueva red.

```sh
sudo apt-get install dnsmasq
```

Una vez instalados todos los componentes necesarios, se pasará a su configuración para la creación de la nueva red inalámbrica.


## Configuración de red

La primera configuración necesaria será la asignación de una IP estática al adaptador inalámbrico. **Ubuntu** utiliza la utilidad `netplan` para la configuración
de las interfaces de red basada en definiciones hechas en ficheros `yaml` situados en el directorio `/etc/netplan`. Por defecto la configuración de red está definida
en el fichero `/etc/netplan/50-cloud-init.yaml`. Para añadir la configuración de la interfaz de red inalámbrica, `wlan0` en el caso de este artículo, se deberá editar 
este fichero y añadir las siguientes lineas. 

```yaml
    wlan0:
      dhcp4: false
      addresses:
        - 10.0.0.1/24
```

En este ejemplo se establece `10.0.0.1` como dirección IP del punto de acceso en la red inalámbrica. Es importante remarcar que el formato `yaml` del archivo no permite 
la utilización de tabuladores. Todas las sangrías necesarias para marcar las secciones de la configuración deben estar hechas a base de espacios en blanco.

La configuración completa de este archivo tendrá un aspecto similar al mostrado a continuación. En el se puede observar también la configuración de la interfaz *ethernet* `eth0`:

```yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 192.168.0.100/24
      gateway4: 192.168.0.1
      nameservers:
        addresses: [1.0.0.1, 1.1.1.1]
    wlan0:
      dhcp4: false
      addresses:
        - 10.0.0.1/24
```

Para aplicar los cambios se deberá ejecutar el comando `sudo netplan apply` para verificar que estos son correctos y poder modificarlos en caso de haber errores. 
Si el sistema se reinicia con una configuración incorrecta, no se dispondrá de red alguna. Hay que tener esto en cuenta si se accede al sistema remotamente mediante SSH.


## Configuración hostapd

Para establecer la configuración del punto de acceso, se deberá crear el fichero de configuración `/etc/hostapd/hostapd.conf` en el que se especificarán los datos de
la nueva red inalámbrica y del protocolo de cifrado utilizado:

```properties
interface=wlan0
driver=nl80211
ssid=My_Wifi
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=change_me
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
```

Los campos del fichero a tener en cuenta son los siguientes:

* **interface**: Interfaz de red inalámbrica sobre la que se configura el punto de acceso. En el ejemplo `wlan0`
* **ssid**: SSID asociada a la nueva red. Se puede especificar el nombre que se desee.
* **hw_mode**: Configuración de la banda de la red Wifi. Los posibles valores son los siguientes:
	* **a**: 802.11a (5 GHz)
	* **b**: 802.11b (2.4 GHz)
	* **g**: 802.11g (2.4 GHz)
	* **ad**: 802.11ad (60 GHz) 
* **channel**: Canal de la banda Wifi escogida. Para la frecuencia 2.4GHz se puede especificar valores del 1 al 14 para evitar interferencias con otros dispositivos.
* **wmm_enabled**: Especifica el soporte para gestionar el QoS de la conexión (0=desactivado; 1=activado)
* **macaddr_acl**: Especifica el soporte para soporte para el filtrado de MAC al establecer conexión con el AP. (0=desactivado; 1=activado)
* **auth_algs**: Algoritmo de cifrado de la conexión (1=wpa, 2=wep, 3=ambos)
* **ignore_broadcast_ssid**: Habilita la ocultación de la SSID de la red. (0=desactivado; 1=activado)

Los campos `wpa`, `wpa_key_mgmt`, `wpa_pairwise` y `rsn_pairwise` especificados en el ejemplo configuran el cifrado de la red mediante `WPA2-PSK TIKP`. 
Es importante modificar la contraseña especificada en el campo `wpa_passphrase`.

Para activar los cambios se deberá editar la configuración del servicio `/etc/default/hostapd` descomentado el campo `DAEMON_CONF` y especificado la ruta al fichero anterior:

```properties
DAEMON_CONF="/etc/hostapd/hostapd.conf"
```

Seguidamente se deberá iniciar el servicio, activándolo en caso de no estarlo:

```sh
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl start hostapd
```


## Configuración DNSmasq

Para establecer la configuración del servidor DHCP de la nueva red, se deberá editar el fichero `/etc/dnsmasq.conf` para especificar el rango de direcciones IP
que se asignarán a los dispositivos que se conecten a la red, la máscara de red de dichas direcciones y su periodo de validez:

```properties
interface=wlan0
dhcp-range=192.168.0.2,192.168.0.20,255.255.255.0,24h
```

En el ejemplo, para la interfaz `wlan0` se establece que el servidor DHCP asignará IPs en el rango `192.168.0.2` a `192.168.0.20` con la máscara de red `255.255.255.0`
y que estas direcciones tendrán una validez de 24H.

Una vez hecha esta modificación, se deberá recargar el servicio mediante el comando:

```sh
sudo systemctl reload dnsmasq
```

Es posible que durante el inicio del sistema ocurra que el servicio `dhcpmasq` intente iniciarse antes de que la interfaz de red esté disponible y esto provoque un error.
Para evitar esto, se debe editar la definición del servicio contenida en el fichero `/lib/systemd/system/dnsmasq.service` modificando las clausulas `After` y `Wants`.
Se debe substituir la cadena `Wants=nss-lookup.target` por `Wants=nss-lookup.target network-online.target` y `After=network.target` por `After=network-online.target`. 
El resultado final deberá ser parecido al siguiente:

```properties
[Unit]
Description=dnsmasq - A lightweight DHCP and caching DNS server
Requires=network.target
Wants=nss-lookup.target network-online.target
Before=nss-lookup.target
After=network-online.target

...

```

Al indicar los valores `network-online.target` en ambas clausulas se asegura que los servicios de red estén disponibles antes de que `dnsmasq` intente arrancar.


## Habilitar *Routing* y enmascarado de IPs

**NOTA**: Este apartado puede ignorarse si no se desea crear el puente para que los equipos conectados a la red inalámbrica puedan acceder también a la red *ethernet*.

Mediante la configuración del *routing* puede habilitarse el intercambio de tráfico entre las interfaces de red, permitiendo a los dispositivos conectados a la
red inalámbrica acceder a recursos conectados a la red *ethernet*. Para ello, se deberá crear el fichero `/etc/sysctl.d/routed-ap.conf` con el siguiente contenido para habilitar
el reenviado de trafico:

```properties
# Enable IPv4 routing
net.ipv4.ip_forward=1
```

Adicionalmente, si la red *ethernet* dispone de acceso a internet a través de un *router* se podrá habilitar el enmascarado de IPs de la red inalámbrica de modo que
el punto de acceso actúe como **NAT** para dicha red, quitado así la necesidad de reconfigurar el *router* que da acceso a internet para habilitar a los dispositivos 
de la nueva red. Para ello se hará uso de una regla de *iptables*. En este caso se aplicará en enmascarado a todo el tráfico redirigido a la interfaz ethernet `eth0`:

```sh
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

Para que esta configuración no se pierda al reiniciar el sistema, se usará la utilidad `netfilter-persistent` para persistir las reglas definidas en `iptables` y restaurarlas
al inicio del sistema. Para ello será necesario tener instalado el paquete `netfilter-persistent` y su *plugin* `iptables-persistent`:

```sh
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y netfilter-persistent iptables-persistent
```

Y ejecutar el comando siguiente para persistir las reglas:

```sh
sudo netfilter-persistent save
```

Las reglas serán persistidas en `/etc/iptables`.

## Pasos finales

Una vez realizada toda la configuración, bastará con reiniciar el sistema para que la nueva red inalámbrica esté disponible. En caso de que no sea así,
se deberá revisar que la interfaz de red esté correctamente configurada, tenga dirección IP y que los servicios `hostapd` y `dnsmasq` estén habilitados y en funcionamiento.
Para ello se podrá hacer uso de los siguientes comandos:

```sh
# Comprobar el estado de la interfaz de red wlan0
ip addr show wlan0

# El resultado será parecido al siguiente
3: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether b8:27:eb:63:32:7c brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.1/24 brd 10.0.0.255 scope global wlan0
       valid_lft forever preferred_lft forever
    inet6 fe80::ba27:ebff:fe63:327c/64 scope link
       valid_lft forever preferred_lft forever

# Comprobar el estado del servicio hostapd
sudo systemctl status hostapd

# El resultado será parecido al siguiente, indicando el estado active (running)
● hostapd.service - Advanced IEEE 802.11 AP and IEEE 802.1X/WPA/WPA2/EAP Authenticator
   Loaded: loaded (/lib/systemd/system/hostapd.service; enabled; vendor preset: enabled)
   Active: active (running) since Sat 2020-05-23 15:51:30 UTC; 16min ago
  Process: 1343 ExecStart=/usr/sbin/hostapd -P /run/hostapd.pid -B $DAEMON_OPTS ${DAEMON_CONF} (code=exited, status=0/SUCCESS)
 Main PID: 1398 (hostapd)
. . . 

# Comprobar el estado del servicio dnsmasq
sudo systemctl status dnsmasq

# El resultado será parecido al siguiente, indicando el estado active (running)
● dnsmasq.service - dnsmasq - A lightweight DHCP and caching DNS server
   Loaded: loaded (/lib/systemd/system/dnsmasq.service; enabled; vendor preset: enabled)
   Active: active (running) since Sat 2020-05-23 15:51:35 UTC; 18min ago
  Process: 1439 ExecStartPost=/etc/init.d/dnsmasq systemd-start-resolvconf (code=exited, status=0/SUCCESS)
  Process: 1408 ExecStart=/etc/init.d/dnsmasq systemd-exec (code=exited, status=0/SUCCESS)
  Process: 1336 ExecStartPre=/usr/sbin/dnsmasq --test (code=exited, status=0/SUCCESS)
 Main PID: 1438 (dnsmasq)
. . . 
```
