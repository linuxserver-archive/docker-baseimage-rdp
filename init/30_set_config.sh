#!/bin/bash

mkdir -p /config/{.config/openbox,.cache}

APPNAME=${APP_NAME:-"GUI_APPLICATION"}
sed -i -e "s#GUI_APPLICATION#$APPNAME#" /etc/xrdp/xrdp.ini
sed -i -e "s#GUI_APPLICATION#$APPNAME#" /etc/guacamole/noauth-config.xml

[[ -e /defaults/startapp.sh ]] && chmod +x /defaults/startapp.sh
chown abc:abc -R  /config /defaults

