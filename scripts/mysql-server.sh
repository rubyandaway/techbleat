#!/bin/bash
sudo su
yum update -y
wget http://dev.mysql.com/get/mysql57-community-release-el7-7.noarch.rpm
yum -y install ./mysql57-community-release-el7-7.noarch.rpm
yum -y install mysql-community-server
systemctl start mysqld