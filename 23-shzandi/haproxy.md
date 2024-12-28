## haproxy ##

### haproxy server ###

step 1:

install haproxy :

```bash
apt install haproxy -y
```
step 2:

in this path change some configure:

```bash
vim /etc/haproxy/haproxy.cfg

frontend servers
    mode http
    bind *:80
    default_backend servers

backend servers
    balance roundrobin
    option httpchk GET /
    server server1 192.168.234.100:5000 check
    server server2 192.168.234.25:80 check
```
**In the front end section, you show the path by pointing to the servers.**

step 3 

```bash
 systemctl restart haproxy
 systemctl status haproxy
 ```

If you want to try connecting use this :

```bash
curl <ip_haproxy_server>
```

## backend servers ##

Change the default ports on both servers :

```bash
vim /etc/nginx/sites-available/default
```

Change the default text on both servers :

```bash
vim /var/www/html/index.nginx-debian.html
```

After making these changes, by searching the IP address of the first server and adding the configured ports to the IP, you will see the textual changes made on the backend servers.
