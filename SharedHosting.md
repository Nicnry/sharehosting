## Installation Linux
1. Téléchargement de l'image iso de Linux Debian 9.1.0 à l'adresse suivante: https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-9.1.0-amd64-netinst.iso
2.  Création de la machine virtuelle avec VMWare Workstation Pro 12.5.0
2.1. File -> New Virtual Machine...
2.2.	Custom -> Next
2.3.	Workstation 12.0 -> Next
2.4. I will install the operating system later -> Next
2.5.	Linux -> Debian 8.x 64-bit -> Next
2.6. Set a Virtual machine name and a location -> Next
2.7. 1 processor, 1 core -> Next
2.8. 1024 MB RAM -> Next
2.9. Use network address translation (NAT) -> Next
2.10. LSI Logic -> Next
2.11. SCSI -> Next
2.12. Create a new virtual disk -> Next
2.13. Size disk 20 GB, Store virtual disk as a single file -> Next
2.14. Set a disk name -> Next
2.15. Finish
3. Installation de Debian
3.1. Edit virtual machine settings -> CD/DVD -> Use ISO image file -> Select ISO -> OK
3.2. Power on this virtual machine
3.3. Select ''Install''
3.4. Select English 
3.5. Select other -> Europe -> Switzerland
3.6. Select United States
3.7. Select Swiss French
3.8. Set a hostname
3.9. No domain name
3.10. Set a password
3.11. Confirm password
3.12. Set a full name 
3.13. Set a username
3.14. Set a password
3.15. Confirm Password
3.16. Select use entire disk
3.17.  Select the disk
3.18. All files in one partition
3.19. Finish
3.20. Yes
3.21. No
3.22. Switzerland
3.23. ftp.ch.debian.org
3.24. Continue
3.25. No
3.26. Unselect Debian desktop environement, print server
3.27. Yes
3.28. /dev/sda
3.29. Continue
3.30. Shutdown the virtual machine and remove the CD/DVD, printer

## Install SSH
1. su and write the root password's
2. apt-get install openssh
3. apt-get install openssh-server
4. exit

## Install SUDO
1. su and write the root password's
2. apt-get install sudo
2. nano /etc/sudoers and add your local user like root
3. exit

## Install Nginx
1. sudo apt-get update (update apt)
2. sudo apt-get install nginx
3.  systemctl status nginx (controll if active (running))

## Install PHP
1. sudo apt-get install php-fpm
2. cd /etc/nginx/sites-available/
3. sudo nano default
4. Remove the comments like : 

>   #pass PHP scripts to FastCGI server;
>       #
>        location ~ \.php$ {
>                include snippets/fastcgi-php.conf;
>        #
>                # With php-fpm (or other unix sockets):
>                fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
>        #       # With php-cgi (or other tcp sockets):
>        #       fastcgi_pass 127.0.0.1:9000;
>       }

5. sudo systemctl restart nginx

## Install MariaDB
1.  sudo apt-get install mariadb-server
2.  sudo nano 50-server.cnf
3. Edit character-set-server = utf8 and comment the line collation-server
4. sudo systemctl restart mariadb
5. su root (enter password)
6. mysql_secure_installation
7. "Change the root password?" Y
8. "Remove anonymous users?" y
9. "Disallow root login remotely?" y
10. "Remove test database and access to it?" y
11. "Reload privilege tables now?" y
12. mysql -u root -p

## User directories isolation
1. ```conf sudo adduser username and after write password```
2. ```conf sudo mkdir /srv/data-user/newuser```
3. ```conf sudo ln -s /srv/data-user/"user" /home/"user"/www```
4. ```conf sudo chown .vR "user" /srv/data-user/"user"```
5. ```conf sudo chgrp -R nginx /srv/data.user/user```
6. ```conf sudo chmod 770 /srv/data-user/"user"```
7. ```conf sudo chmod 770 /home/"user"```
8. Connect to mariaDB and creat the new user with root
9. ```conf sudo mysql -u root -p```
10. ```conf CREATE USER 'NEW_USER_NAME' IDENTIFIED BY 'PASSWORD'; ```
11. ```conf CREATE DATABASE nameofthenewdb;```
12. ```conf GRANT ALL PRIVILEGES ON nomdevotredb.* TO 'user'@'%'WITH GRANT OPTION;```
13. Disconnect from the mariaDB and reconnect with the new user
14. ```conf mysql -u NEW_USER_NAME -p ```
15. creat a file in /etc/nginx/sites-available

```conf
server {
        listen 80;
        root /srv/data-user/"user";
        index index.php index.html index.htm;
        server_name www."user".ch;
        access_log /home/"user"/log/access.log
        location / {
                try_files \$uri/ /index.php;
        }
        location ~ \.php$ {
                try_files $uri =404;
			    fastcgi_index index.php;
			    fastcgi_pass unix:/var/run/php7.0-fpm-"user".sock;
			    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
			    include fastcgi_params;
        }
    }
```
16. creat a symboling link from sites-available to sites-enabled
17. ```conf sudo ln -s tutu.conf /etc/nginx/sites-enabled/```
