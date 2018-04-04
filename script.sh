
#!/bin/bash

# Update the package list
apt-get update

# Install nginx
apt-get install nginx

# apt-get -y install php-fpm 
apt-get -y install php-fpm 

# Stop PHP service and nginx
systemctl stop php7.0-fpm
systemctl stop nginx

# Replace content
echo " 
        server {
            listen 80 default_server;
            listen [::]:80 default_server;

            root /mnt/www/html;

            index index.php;

            server_name _;

            location = /favicon.ico {
                    log_not_found off;
                    access_log off;
            }

            location = /robots.txt {
                    allow all;
                    log_not_found off;
                    access_log off;
            }

            location / {
                    # following https://codex.wordpress.org/Nginx
                    try_files $uri $uri/ /index.php?$args;
            }

            # pass the PHP scripts to the local FastCGI server
            location ~ \.php$ {
                    include snippets/fastcgi-php.conf;
                    fastcgi_pass unix:/run/php/php7.0-fpm.sock;
            }

            location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
                    expires max;
                    log_not_found off;
            }

            # deny access to .htaccess files, if Apache's document root
            # concurs with nginx's one
            location ~ /\.ht {
                    deny all;
            }
        }
    " > /etc/nginx/sites-available/default

    # Create a www amd html folder inside the /mnt using
    cd /mnt
    mkdir www
    mkdir www/html

    # Create an index.php file to add some php code to display the app name.
    cd /mnt/www/html
    touch index.php
    echo ' <?php $hostname = "App1"; echo $hostname; ?> ' > index.php

    # Start back PHP service and nginx
    systemctl start php7.0-fpm
    systemctl start nginx
