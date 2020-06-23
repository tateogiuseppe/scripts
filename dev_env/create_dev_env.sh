#!bin/bash

echo "download docker"
cd ~/Download; curl -O https://download.docker.com/mac/stable/Docker.dmg
MOUNTDIR=$(echo `hdiutil mount Docker.dmg | tail -1 \ | awk '{$1=$2=""; print $0}'` | xargs -0 echo) \ && sudo installer -pkg "${MOUNTDIR}/"*.pkg -target / 

echo "creating folders"
mkdir ~/develop
mkdir ~/develop/docker_configs
mkdir ~/develop/docker_configs/mysql
mkdir ~/develop/docker_configs/redis
mkdir ~/develop/mysql_data
mkdir ~/develop/logs
mkdir ~/develop/logs/apache
mkdir ~/develop/logs/php
mkdir ~/public_html

echo "copying redis conf"
cp redis.conf ~/develop/docker_configs/redis/redis.conf

echo "copying mysql conf"
cp mysql.conf ~/develop/docker_configs/mysql/my.cnf

echo "Disable the macOS version of Apache"
sudo apachectl stop
sudo launchctl unload -w /System/Library/LaunchDaemons/org.apache.httpd.plist 2>/dev/null

echo "Create a Docker Network"
docker network create dev-network

echo "Launch a Redis Server Container"
docker run --restart always --name redis-localhost --net dev-network -v ~/develop/docker_configs/redis/redis.conf:/usr/local/etc/redis/redis.conf -d redis:5.0.6

echo "Launch a MySQL 8.0 Server Container"
docker run --restart always --name mysql-localhost --net dev-network -v ~/develop/mysql_data/8.0:/var/lib/mysql -v ~/develop/docker_configs/mysql:/etc/mysql/conf.d -p 3306:3306 -d -e MYSQL_ROOT_PASSWORD=local_sql_admin mysql:8.0

echo "display docker container"
docker ps

echo "Launch an Apache/PHP 7.2 Server Container"
mkdir ~/develop/docker_dev_env
cd ~/scripts
cp -R docker ~/develop/docker_dev_env/

echo "Build the Development Environment Image"
cd ~/develop/docker_dev_env/docker
docker build -t dev-environment .

echo "Launch the Development Environment Image into a Container"
docker run --restart always --name www-localhost --net dev-network -v ~/public_html:/var/www/html -v ~/develop/logs:/usr/local/log -p 80:80 -d dev-environment


#echo "Launch composer"
#docker run --net dev-network -it --rm -v ~/public_html:/app composer install
# apt-get update && apt-get -y --no-install-recommends install git \
#    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
#    && rm -rf /var/lib/apt/lists/*

