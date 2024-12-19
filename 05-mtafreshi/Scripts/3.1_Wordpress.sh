#!/bin/bash

path=/etc/apache2/sites-available/wordpress.conf
config=/srv/www/wordpress/wp-config.php
file=./host_config
hosts=/etc/hosts

check_root ()
{
    if [ `whoami` == "root" ]; then
        echo "you are login with Root User"
    else
        echo "Please Login "root" User and Run Script Agein." 
        exit 1
    fi
}

hosts ()
{
    echo "`cat ${file}`" >> ${hosts}
}

install_wordpress ()
{
    apt update
    apt install apache2 ghostscript libapache2-mod-php php php-bcmath php-curl php-imagick php-intl php-json php-mbstring php-mysql php-xml php-zip -y
    mkdir -p /srv/www
    chown www-data: /srv/www
    curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www
    touch ${path}
    echo "<VirtualHost *:80>" >> ${path}
    echo "    DocumentRoot /srv/www/wordpress" >> ${path}
    echo "    <Directory /srv/www/wordpress>" >> ${path}
    echo "        Options FollowSymLinks" >> ${path}
    echo "        AllowOverride Limit Options FileInfo" >> ${path}
    echo "        DirectoryIndex index.php" >> ${path}
    echo "        Require all granted" >> ${path}
    echo "    </Directory>" >> ${path}
    echo "    <Directory /srv/www/wordpress/wp-content>" >> ${path}
    echo "        Options FollowSymLinks" >> ${path}
    echo "        Require all granted" >> ${path}
    echo "    </Directory>" >> ${path}
    echo "</VirtualHost>" >> ${path}
    sudo a2ensite wordpress
    sudo a2enmod rewrite
    sudo a2dissite 000-default
    sudo service apache2 reload
    # SELECT wp_users.user_login, wp_users.user_email, firstmeta.meta_value as first_name, lastmeta.meta_value as last_name FROM wp_users left join wp_usermeta as firstmeta on wp_users.ID = firstmeta.user_id and firstmeta.meta_key = 'first_name' left join wp_usermeta as lastmeta on wp_users.ID = lastmeta.user_id and lastmeta.meta_key = 'last_name';
    sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php
    sudo -u www-data sed -i 's/database_name_here/wordpress/' ${config}
    sudo -u www-data sed -i 's/username_here/wordpress/' ${config}
    sudo -u www-data sed -i 's/password_here/'123456'/' ${config}
    tail -n 1 ${hosts} | awk '{print $2}' > db
    sudo -u www-data sed -i "s/localhost/'\''`cat db`'\''/" ${config}
    # https://api.wordpress.org/secret-key/1.1/salt/ (Secure Vulnerability input to /srv/www/wordpress/wp-config.php)
    logout
}

main ()
{
    check_root
    hosts
    install_wordpress
}