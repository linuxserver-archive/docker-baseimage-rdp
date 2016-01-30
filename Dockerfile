FROM linuxserver/baseimage

MAINTAINER Sparklyballs <sparklyballs@linuxserver.io>

ENV BASE_APTLIST="libcairo-script-interpreter2 libfreerdp-plugins-standard libfreerdp1 libxkbfile1 \
libfuse2 libossp-uuid16  openbox openjdk-7-jre tomcat7 unzip vnc4server \
wget x11-xserver-utils xfonts-100dpi xfonts-75dpi xfonts-base xrdp libwebp-dev" \

BUILDLIST="build-essential libcairo2-dev libfreerdp-dev libjpeg-turbo8-dev libpango1.0-dev libwebp-dev libpng12-dev libssh2-1-dev libvncserver-dev libossp-uuid-dev" \

guac_version="0.9.9"

# configure abc user for baseimage
RUN usermod -s /bin/bash abc && \
usermod -a -G adm,sudo abc && \
echo "abc:PASSWD" | chpasswd

# install build packages
RUN add-apt-repository ppa:no1wantdthisname/openjdk-fontfix && \
apt-get update -q && \
apt-get install $BUILDLIST -qy && \

# make required folders
mkdir -p /var/lib/tomcat7/webapps && \
mkdir -p /var/cache/tomcat7 && \
mkdir -p /var/lib/guacamole/classpath && \
mkdir -p /usr/share/tomcat7/.guacamole && \
mkdir -p /usr/share/tomcat7-root/.guacamole && \
mkdir -p /root/.guacamole && \

# compile guacamole server
curl -o /tmp/guac_source.tar.gz -L http://sourceforge.net/projects/guacamole/files/current/source/guacamole-server-${guac_version}.tar.gz/download && \
mkdir -p /tmp/guacamole && \
tar xf /tmp/guac_source.tar.gz -C /tmp/guacamole --strip-components=1 && \
cd /tmp/guacamole && \
./configure && \
make && \
make install && \

# fetch remaining packages
curl -o /tmp/noauth.tar.gz -L http://sourceforge.net/projects/guacamole/files/current/extensions/guacamole-auth-noauth-${guac_version}.tar.gz/download && \
mkdir -p /tmp/nouathwar && \
tar xf /tmp/noauth.tar.gz -C /tmp/nouathwar  --strip-components=1 && \
cp /tmp/nouathwar/guacamole*.jar /var/lib/guacamole/classpath/guacamole-auth-noauth.jar && \
curl -o /var/lib/tomcat7/webapps/guacamole.war -L http://sourceforge.net/projects/guacamole/files/current/binary/guacamole-${guac_version}.war/download && \

# cleanup
apt-get --purge autoremove $BUILDLIST -qy && \
apt-get autoremove -qy && \
apt-get clean -y && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install runtime packages
RUN apt-get update -q && \
apt-get install --no-install-recommends $BASE_APTLIST -qy && \

# cleanup
apt-get clean -y && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Adding Custom files
ADD defaults/ /defaults/
ADD init/ /etc/my_init.d/
ADD services/ /etc/service/
RUN chmod -v +x /etc/service/*/run && chmod -v +x /etc/my_init.d/*.sh && \

# configuration
ln -s /etc/guacamole/guacamole.properties /usr/share/tomcat7/.guacamole/ && \
ln -s /etc/guacamole/guacamole.properties /usr/share/tomcat7-root/.guacamole/ && \
ln -s /etc/guacamole/guacamole.properties /root/.guacamole/ && \
rm -Rf /var/lib/tomcat7/webapps/ROOT && \ 
ln -s /var/lib/tomcat7/webapps/guacamole.war /var/lib/tomcat7/webapps/ROOT.war && \
ln -s /usr/local/lib/freerdp/guacsnd.so /usr/lib/x86_64-linux-gnu/freerdp/ && \ 
ln -s /usr/local/lib/freerdp/guacdr.so /usr/lib/x86_64-linux-gnu/freerdp/
