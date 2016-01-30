FROM linuxserver/baseimage

MAINTAINER Sparklyballs <sparklyballs@linuxserver.io>

ENV BASE_APTLIST="vnc4server x11-xserver-utils openbox xfonts-base \
xfonts-100dpi xfonts-75dpi openjdk-7-jre libossp-uuid-dev libpng12-dev \
xrdp libfreerdp-dev libcairo2-dev tomcat7 libfuse2" \

guac_version="0.9.9"

# install runtime packages
RUN add-apt-repository ppa:no1wantdthisname/openjdk-fontfix && \
add-apt-repository ppa:fkrull/deadsnakes-python2.7 && \
apt-get update -q && \
apt-get install --force-yes --no-install-recommends $BASE_APTLIST -qy && \

# make required folders
mkdir -p /var/lib/tomcat7/webapps /var/cache/tomcat7 /var/lib/guacamole/classpath \
/usr/share/tomcat7/.guacamole /usr/share/tomcat7-root/.guacamole /root/.guacamole && \

# fetch guacamole packages
curl -o /tmp/noauth.tar.gz -L http://sourceforge.net/projects/guacamole/files/current/extensions/guacamole-auth-noauth-${guac_version}.tar.gz/download && \
mkdir -p /tmp/nouathwar && \
tar xf /tmp/noauth.tar.gz -C /tmp/nouathwar  --strip-components=1 && \
cp /tmp/nouathwar/guacamole*.jar /var/lib/guacamole/classpath/guacamole-auth-noauth.jar && \
curl -o /var/lib/tomcat7/webapps/guacamole.war -L http://sourceforge.net/projects/guacamole/files/current/binary/guacamole-${guac_version}.war/download && \ 
curl -o /tmp/guacamole.deb -L https://files.linuxserver.io/Guacamole-Debs/guacamole-server_${guac_version}_amd64.deb && \
dpkg -i /tmp/guacamole.deb && \
ldconfig && \

# configuration
ln -s /etc/guacamole/guacamole.properties /usr/share/tomcat7/.guacamole/ && \
ln -s /etc/guacamole/guacamole.properties /usr/share/tomcat7-root/.guacamole/ && \
ln -s /etc/guacamole/guacamole.properties /root/.guacamole/ && \
rm -Rf /var/lib/tomcat7/webapps/ROOT && \ 
ln -s /var/lib/tomcat7/webapps/guacamole.war /var/lib/tomcat7/webapps/ROOT.war && \
ln -s /usr/local/lib/freerdp/guacsnd.so /usr/lib/x86_64-linux-gnu/freerdp/ && \ 
ln -s /usr/local/lib/freerdp/guacdr.so /usr/lib/x86_64-linux-gnu/freerdp/ && \

# configure abc user for baseimage
usermod -s /bin/bash abc && \
usermod -a -G adm,sudo abc && \
echo "abc:PASSWD" | chpasswd && \

# cleanup
apt-get clean -y && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Adding Custom files
ADD defaults/ /defaults/
ADD init/ /etc/my_init.d/
ADD services/ /etc/service/
RUN chmod -v +x /etc/service/*/run && chmod -v +x /etc/my_init.d/*.sh


