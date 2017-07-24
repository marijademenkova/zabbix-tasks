#!/bin/bash

echo Installing Zabbix Server
yum -y install mariadb mariadb-server
/usr/bin/mysql_install_db --user=mysql
systemctl start mariadb
mysql -uroot -e "create database zabbix character set utf8 collate utf8_bin;"
mysql -uroot -e "grant all privileges on zabbix.* to zabbix@localhost identified by 'password';"
yum -y install http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
yum -y install zabbix-server-mysql zabbix-web-mysql
zcat /usr/share/doc/zabbix-server-mysql-*/create.sql.gz | mysql -uzabbix -ppassword zabbix
sed -i '/# DBPassword=/a DBPassword=password' /etc/zabbix/zabbix_server.conf
sed -i 's@# php_value date.timezone Europe/Riga@php_value date.timezone Europe/Minsk@g' /etc/httpd/conf.d/zabbix.conf
cat > /etc/zabbix/web/zabbix.conf.php << 'EOL'
<?php
global $DB;
$DB['TYPE']     = 'MYSQL';
$DB['SERVER']   = 'localhost';
$DB['PORT']     = '3306';
$DB['DATABASE'] = 'zabbix';
$DB['USER']     = 'zabbix';
$DB['PASSWORD'] = 'password';
$DB['SCHEMA'] = '';
$ZBX_SERVER      = 'localhost';
$ZBX_SERVER_PORT = '10051';
$ZBX_SERVER_NAME = 'Zabbix Server';
$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
EOL
systemctl start zabbix-server
systemctl start httpd

