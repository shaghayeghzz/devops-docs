#!/bin/bash

check_root ()
{
    if [ `whoami` == "root" ]; then
        echo "you are login with Root User"
    else
        echo "Please Login "root" User and Run Script Agein." 
        exit 1
    fi
}

nginx_reverse ()
{
    sudo apt update
    sudo apt install nginx iptables-persistent -y
    systemctl start nginx
    systemctl enable nginx
    systemctl status nginx
    send q
}

config_proxy ()
{
    path=/etc/nginx/sites-available/reverse-proxy
    unlink /etc/nginx/sites-enabled/default
    echo "server {" > ${path}
    echo "    listen 80;" >> ${path}
    echo "    server_name 192.168.10.4;" >> ${path}
    echo "" >> ${path}
    echo "    location / {" >> ${path}
    echo "        proxy_pass http://192.168.10.3:80;" >> ${path}
    echo "    }" >> ${path}
    echo "}" >> ${path}
    cat ${path}
    sleep 5
    ln -s /etc/nginx/sites-available/reverse-proxy /etc/nginx/sites-enabled/
    nginx -t
    systemctl restart nginx
    echo "Configuration Completed. "
}

check_nginx ()
{
    systemctl restart nginx
    if [ `$?` == 0 ]; then
        echo "Nginx Server is Already Installed. "
        read -p "Do you want to configure Server to Reverse_Proxy? (y/n) " answer
        if [ ${answer} == y ]; then
            config_proxy
        else
            echo "Good Lock!~ ."
        fi
    else
        nginx_reverse
        config_proxy
    fi
}

main ()
{
    check_root
    check_nginx
}
main