#!/bin/bash

REPO_URL=""
USER=
PASS=

if [ -z "$1" ];then
  echo "Please set Argument."
  echo ""
  echo "Usage:"
  echo "       ./deploy.sh APP_NAME"
  echo ""
  exit 1
else
  APP_USER=$1
  echo ${APP_USER}
  #exit 0
fi
# Initial Setting.
sudo useradd ${APP_USER}
chmod 755 /home/${APP_USER}
sudo -u ${APP_USER} mkdir /home/${APP_USER}/{src,conf,log,www}
sudo -u ${APP_USER} mkdir -p /home/${APP_USER}/src/releases/${APP_USER}/etc
# Check out contents from Subversion Repo.
su -c "svn co --username ${USER} --password ${PASS} ${REPO_URL}/${APP_USER} /home/${APP_USER}/src/releases/${APP_USER}/web" ${APP_USER}
# Generate httpd.conf
sudo -u ${APP_USER} cat << CONF >> /home/${APP_USER}/src/releases/${APP_USER}/etc/httpd.conf
<VirtualHost *:80>
        ServerName    ${APP_USER}
        ServerAlias   www.${APP_USER}
        DocumentRoot  /home/${APP_USER}/www/htdocs
        DirectoryIndex index.php index.html
        #
        ErrorLog "|/usr/sbin/cronolog /home/${APP_USER}/log/apache/${APP_USER}_%Y%m%d.err.log"
        CustomLog "|/usr/sbin/cronolog /home/${APP_USER}/log/apache/${APP_USER}_%Y%m%d.log" combined
        #
        AddDefaultCharset UTF-8
        Options MultiViews FollowSymLinks
</VirtualHost>
CONF
#
sudo -u ${APP_USER} ln -nfs /home/${APP_USER}/src/releases/${APP_USER} /home/${APP_USER}/src/CURRENT
sudo -u ${APP_USER} ln -nfs /home/${APP_USER}/src/CURRENT/web /home/${APP_USER}/www/htdocs
sudo -u ${APP_USER} ln -nfs /home/${APP_USER}/src/CURRENT/etc/httpd.conf /home/${APP_USER}/conf/httpd.conf
#
cd /etc/httpd/conf.d
ln -nfs /home/${APP_USER}/conf/httpd.conf httpd-vhosts-${APP_USER}.conf
sudo /etc/init.d/httpd configtest
if [ -d /home/${APP_USER}/www/htdocs -a $? = "0" ];then
  echo "Please execute Restart Apache..."
  #sudo /etc/init.d/httpd restart
else
  echo "Apache Config Syntax or Other Problem."
  echo "Please confirm /home/${APP_USER}/conf/httpd.conf and DocumentRoot Directory!!"
  exit 1
fi
