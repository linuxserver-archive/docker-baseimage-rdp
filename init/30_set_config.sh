#!/bin/bash

mkdir -p /config/{.config/openbox,.cache} /etc/guacamole

[[ -e /defaults/startapp.sh ]] && chmod +x /defaults/startapp.sh
[[ ! -f /etc/guacamole/guacamole.properties ]] && cp /defaults/guacamole.properties /etc/guacamole/guacamole.properties
[[ ! -f /etc/xrdp/sesman.ini ]] && cp /defaults/sesman.ini /etc/xrdp/sesman.ini
[[ ! -f /etc/xrdp/xrdp.ini ]] && cp /defaults/xrdp.ini /etc/xrdp/xrdp.ini
[[ ! -f /etc/guacamole/noauth-config.xml ]] && cp /defaults/noauth-config.xml /etc/guacamole/noauth-config.xml
[[ ! -f /config/.config/openbox/autostart ]] && cp /defaults/autostart /config/.config/openbox/autostart

APPNAME=${APP_NAME:-"GUI_APPLICATION"}
sed -i -e "s#GUI_APPLICATION#$APPNAME#" /etc/xrdp/xrdp.ini
sed -i -e "s#GUI_APPLICATION#$APPNAME#" /etc/guacamole/noauth-config.xml

chown abc:abc -R  /config /defaults

