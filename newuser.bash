#!/bin/bash

###### CREATE USER

echo "-----------Script to create a website for an user---------------"

echo "Insert the user name"
read answer
userName=$answer
adduser $userName
mkdir -p /srv/data-user/$userName
ln -s /srv/data-user/$userName /home/$userName/www
chown -vR $userName /srv/data-user/$userName
chgrp -R www-data /srv/data-user/$userName
chmod 770 /srv/data-user/$userName
chmod 770 /home/$userName



###### CREATE USER DATABASE
echo "Name of the MariaDB's user: "$userName
echo "Insert a new password for your MariaDB's user"
read -s answer
userDBpassword=$answer


echo "Insert the admin password for MariaDB: "
read -s  answer
adminPassword=$answer

mysql --user root --password=$adminPassword <<EOF
CREATE USER '$userName' IDENTIFIED BY '$userDBpassword';
CREATE DATABASE $userName;
GRANT ALL PRIVILEGES ON $userName.* TO '$userName'@'%';
flush privileges;
quit
EOF

echo "The new  MariaDB '$userName' has been created."

touch /etc/nginx/sites-available/$userName.conf
echo "server {
        listen 80;
        root /srv/data-user/$userName;
        index index.php index.html index.htm;
        server_name www.$userName.ch;
        location / {
                try_files \$uri \$uri/ /index.html;
        }
        location ~ \.php$ {
                try_files \$uri =404;
                fastcgi_index index.php;
                fastcgi_pass unix:/var/run/php7.0-fpm-$userName.sock;
                fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
                include fastcgi_params;
        }
    }
" > /etc/nginx/sites-available/$userName.conf
echo "File /etc/nginx/sites-available/$userName.conf created."
###### LIEN SYMBOLIQUE (activer le site)
ln -s /etc/nginx/sites-available/$userName.conf /etc/nginx/sites-enabled/$userName.conf

###### POOL PHP
touch /etc/php/7.0/fpm/pool.d/$userName.conf
echo "[$userName]
    user = $userName
    group = $userName
    listen = /var/run/php7.0-fpm-$userName.sock
    listen.owner = www-data
    listen.group = www-data
    pm = dynamic
    pm.max_children = 5
    pm.start_servers = 2
    pm.min_spare_servers = 1
    pm.max_spare_servers = 3
    chdir = /
" > /etc/php/7.0/fpm/pool.d/$userName.conf
echo "File /etc/php/7.0/fpm/pool.d/$userName.conf created."
echo "Restarting service nginx/php7.0/mysql..."
###### RESTART SERVICES
systemctl restart nginx.service
systemctl restart php7.0-fpm.service
systemctl restart mysql.service

echo "Your new user is created."
