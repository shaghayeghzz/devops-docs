## nginx-wordpress-mariadb ##

### server 1 nginx ###


step 1 :

create file with .conf

```bash
vim /etc/site_available/reverse.conf
```
Write these changes

```bash
server {
        listen 80;
        server_name 192.168.234.28;
        access_log /var/log/nginx/reverse-access.log;
        error_log /var/log/nginx/reverse-error.log;

        location / {
                proxy_pass http://backend_server;
         }
}
upstream backend_server {
    server 192.168.234.33:80;
}
```

step 2 :

To display the specific file without linking to the default file, make this adjustment.

```bash
unlink /etc/nginx/sites-enabled/default
```
```bash
ln -s /etc/nginx/sites-available/reverse.conf  /etc/nginx/sites-enabled/reverse
```
Use this command to view the linked files.

```bash
ls -l /etc/nginx/sites-enabled/
```

Now you need to check the Nginx configurations. Use this command:

```bash
nginx -t
nginx -s reload
```



### server 2 wordpress ##


step 1 :

Install the programs you need.

```bash
apt install nginx
apt install php-fpm php-mysql php-cli php-curl php-json php-gd php-mbstring php-xml php-zip -y
```

step 2 :

Download WordPress in this directory and grant it access.

`cd /var/www/html/
`
```bash
wget https://wordpress.org/latest.tar.gz
```
```bash
chown -R www-data:www-data /var/www/html/wordpress
chmod -R 755 /var/www/html/wordpress
```

step 3:

In this directory, create a configuration file for WordPress and write this configuration inside it.

`vim /etc/nginx/sites-available/wordpress`

```bash
    listen 80;
    server_name 192.168.234.33;

    root /var/www/html/wordpress;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
```
**Pay attention to the IP address, port, and PHP version**


Establish the connection configuration file with the directory and enable it

step4 :

Unlink the default file before linking the WordPress file

```bash
ln -s /etc/nginx/sites-available/wordpress  /etc/nginx sites-enabled/
```
```bash
systemctl restart nginx
```
Perform the settings for connecting this server to the database from this path.

`cd /var/www/html/wordpress/`
```bash
vim wp-config-sample.php
```
```bash
define('DB_NAME', 'wordpress_db');
define('DB_USER', 'wp_user');
define('DB_PASSWORD', 'secure_password');
define('DB_HOST', 'database_server_ip');
```
step 5:

Set up the IP table to allow database access only from this IP

```bash
iptables -I OUTPUT -d 192.168.234.29 -s 192.168.234.33 -p tcp --dport 3306 -j ACCEPT
iptables -I INPUT -s 192.168.234.29 -d 192.168.234.33 -p tcp --sport 3306 -j ACCEPT
```

Save the rules you have written.

for delete rules :

`iptables -D INPUT/OUTPUT 1`

```bash
sudo apt-get install iptables-persistent
iptables-save > /etc/iptables/rules.v4
```


for test :

```bash
mysql -u shaghayegh -p -h 192.168.234.29 wordpress_db
```



### server 3 mariadb ###

step 1 :

```bash
apt install mariadb-server
```
Now that we've installed the database,
 we need to create an LVM and ensure that the database stores its data on the second disk

We create a directory in the mount path so that we can transfer the database files to it.

```bash
mount /mnt/sql-lvm/mysql
```
We check where the database file path is located.

```bash
mysql -u root -p

show variables like 'datadir';
```
To transfer the database files, we need to stop the service first.

```bash
sudo systemctl stop mariadb
sudo systemctl status mariadb
```
We transfer the file.

```bash
sudo rsync -av /var/lib/mysql /mnt/sql-lvm
sudo mv /var/lib/mysql /var/lib/mysql.bak
```
We specify the path in the configuration files.

`sudo vim /etc/mysql/my.cnf`

```bash
[client]
port=3306
socket=/mnt/your-dir/mysql/mysql.sock
```

`vim /etc/mysql/mariadb.conf.d/50-server.cnf`
```bash
datadir=/mnt/your-dir/mysql
```
Now, apply the changes and make sure to check the updated path in the database.
```bash
sudo systemctl start mariadb
sudo systemctl status mariadb

mysql -u root -p
see change location
```

