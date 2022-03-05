#!/bin/bash
sudo su
yum update -y
yum -y install httpd
echo "<p><h1>My Instance! <h1></p>" >> /var/www/html/index.html
sudo systemctl enable httpd
sudo systemctl start httpd