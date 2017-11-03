# Installation Linux
Download the latest version of debian on this link: [https://www.debian.org/distrib/netinst](https://www.debian.org/distrib/netinst)

---
## Création de la machine virtuelle avec VMWare Workstation Pro 12.5.0
>1.1.   File -> New Virtual Machine...</br>
>1.2.   Custom -> Next</br>
>1.3.   Workstation 12.0 -> Next</br>
>1.4.   I will install the operating system later -> Next</br>
>1.5.   Linux -> Debian 8.x 64-bit -> Next</br>
>1.6.   Set a Virtual machine name and a location -> Next</br>
>1.7.   1 processor, 1 core -> Next</br>
>1.8.   1024 MB RAM -> Next</br>
>1.9.   Use network address translation (NAT) -> Next</br>
>1.10.  LSI Logic -> Next</br>
>1.11.  SCSI     > Next</br>
>1.12.  Create a new virtual disk -> Next</br>
>1.13.  Size disk 20 GB, Store virtual disk as a single file -> Next</br>
>1.14.  Set a disk name -> Next</br>

---
## Installation de Debian
>1.1.   Edit virtual machine settings -> CD/DVD -> Use ISO image file -> Select ISO -> OK</br>
>1.2.   Power on this virtual machine</br>
>1.3.   Select ''Install''</br>
>1.4.   Select English </br>
>1.5.   Select other -> Europe -> Switzerland</br>
>1.6.   Select United States</br>
>1.7.   Select Swiss French</br>
>1.8.   Set a hostname</br>
>1.9.   No domain name</br>
>1.10.  Set a password</br>
>1.11.  Confirm password</br>
>1.12.  Set a full name </br>
>1.13.  Set a username</br>
>1.14.  Set a password</br>
>1.15.  Confirm Password</br>
>1.16.  Select use entire disk</br>
>1.17.  Select the disk</br>
>1.18.  All files in one partition</br>
>1.19.  Finish</br>
>1.20.  Yes</br>
>1.21.  No</br>
>1.22.  Switzerland</br>
>1.23.  ftp.ch.debian.org</br>
>1.24.  Continue</br>
>1.25.  No</br>
>1.26.  Unselect Debian desktop environement, print server</br>
>1.27.  Yes</br>
>1.28.  /dev/sda</br>
>1.29.  Continue</br>
>1.30.  Shutdown the virtual machine and remove the CD/DVD, printer</br>

---

# Install SSH
1. `su` and write the root password's.
2. ```apt-get install openssh-server```
3. ```exit```

---

# Install SUDO
1. `su` and write the root password's.
2. ```apt-get install sudo```
2. `nano /etc/sudoers` and add your local user like root.
3. ```exit```

---

# Install Nginx
1. ```sudo apt-get update```
2. ```sudo apt-get install nginx```
3. ```sudo systemctl status nginx``` and controll if is running.

---

# Install PHP
1. ```sudo apt-get install php-fpm```
2. ```cd /etc/nginx/sites-available/```
3. ```sudo nano default```
4. Remove the comments like : 

```bash
#pass PHP scripts to FastCGI server;
#
        location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        #
                # With php-fpm (or other unix sockets):
                fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
        #       # With php-cgi (or other tcp sockets):
        #       fastcgi_pass 127.0.0.1:9000;
       }
```

5. ```sudo systemctl restart nginx```

---

# Install MariaDB
1.  ```sudo apt-get install mariadb-server```
2.  ```sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf```
3.  Edit ```character-set-server = utf8``` and comment the line ```collation-server```
4.  ```sudo systemctl restart mariadb```
5.  ```su root``` (enter password)
6.  ```mysql_secure_installation```
7.  "Change the root password?" Y
8.  "Remove anonymous users?" y
9.  "Disallow root login remotely?" y
10. "Remove test database and access to it?" y
11. "Reload privilege tables now?" y
12. ```mysql -u root -p```

---

# User directories isolation
1.  ```sudo adduser username and after write password```
2.  ```sudo mkdir /srv/data-user/"user"```
3.  ```sudo ln -s /srv/data-user/"user" /home/"user"/www```
4.  ```sudo chown -vR "user" /srv/data-user/"user"```
5.  ```sudo chgrp -R www-data /srv/data-user/"user"```
6.  ```sudo chmod 770 /srv/data-user/"user"```
7.  ```sudo chmod 770 /home/"user"```
8.  Connect to mariaDB and create the new user with root.
9.  ```sudo mysql -u root -p```
10. ```CREATE USER 'user' IDENTIFIED BY 'PASSWORD'; ```
11. ```CREATE DATABASE nameofthenewdb;```
12. ```GRANT ALL PRIVILEGES ON databasename.* TO 'user'@'%'WITH GRANT OPTION;```
13. Disconnect from the mariaDB and reconnect with the new user.
14. ```mysql -u "user" -p ```
15. Create a file in /etc/nginx/sites-available. witn "user".conf as name

```nginx
server {
        listen 80;
        root /srv/data-user/"user";
        index index.php index.html index.htm;
        server_name www."user".ch;
        location / {
                try_files $uri $uri/ /index.html;
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
16. Create a symboling link from sites-available to sites-enabled.
17. ```cd /etc/nginx/sites-enabled/```
17. ```sudo ln -s /etc/nginx/sites-available/"user".conf "user".conf```
18. ```cd /etc/php/7.0/fpm/pool.d```
19. ```sudo nano "user".conf```
20. Write this on your file.
```
["user"]
    user = "user"
    group = "user"
    listen = /var/run/php7.0-fpm-"user".sock
    listen.owner = www-data
    listen.group = www-data
    pm = dynamic
    pm.max_children = 5
    pm.start_servers = 2
    pm.min_spare_servers = 1
    pm.max_spare_servers = 3
    chdir = /
```
21. Restart the services.
22. ```sudo systemctl restart nginx.service``` 
23. ```sudo systemctl restart php7.0-fpm.service```
24. ```sudo systemctl restart mysql.service```
