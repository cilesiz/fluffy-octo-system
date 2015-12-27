#!/bin/bash
# 
# Dirs for Photos & Videos and some others post vol mount 

sudo -u apache mkdir /var/www/mte/adv/videos
sudo -u apache mkdir /var/www/mte/adv/photogallery
sudo -u apache mkdir /var/www/mte/gulflive/photogallery
sudo -u apache mkdir /var/www/mte/lvlive/photogallery
sudo -u apache mkdir /var/www/mte/TOPICS
sudo -u apache mkdir /var/www/mte/FEEDS
sudo -u apache mkdir /var/www/mte/STATIC
sudo -u apache mkdir /var/www/mte/CONNECT

# Affiliate dirs CONNECT, TOPICS, FEEDS ,STATIC
for aff in adv bama cleve gulflive lvlive mass mlive njo nola ohiohss olive penn silive syr
do
	echo
	echo "making dirs for aff=$aff"
 	sudo -u apache mkdir /var/www/mte/CONNECT/$aff
	sudo -u apache cp /var/www/cgi-bin/robots.txt /var/www/mte/CONNECT/$aff
	echo "/var/www/mte/CONNECT/$aff"
 	sudo -u apache mkdir /var/www/mte/TOPICS/$aff
	sudo -u apache cp /var/www/cgi-bin/robots.txt /var/www/mte/TOPICS/$aff
	echo "/var/www/mte/TOPICS/$aff"
 	sudo -u apache mkdir /var/www/mte/FEEDS/$aff
	sudo -u apache cp /var/www/cgi-bin/robots.txt /var/www/mte/FEEDS/$aff
	echo "/var/www/mte/FEEDS/$aff"
    sudo -u apache mkdir /var/www/mte/STATIC/$aff
	sudo -u apache cp /var/www/cgi-bin/robots.txt /var/www/mte/STATIC/$aff
    echo "/var/www/mte/STATIC/$aff"
	echo
done


