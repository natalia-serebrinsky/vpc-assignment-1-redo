#!/usr/bin/env bash

sudo apt-get -y update
sudo apt-get -y install nginx
sudo service nginx start
echo "Welcome to Grandpa's Whiskey" | sudo tee /var/www/html/index.html
echo "Welcome to Grandpa's Whiskey" | sudo tee /usr/share/nginx/html/index.html