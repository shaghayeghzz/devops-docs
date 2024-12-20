# Steps for implementing static IP address configuration in Rocky Linux
- First, go to the directory `/etc/NetworkManager/system-connections/.`
- Create a new `.nmconnection` file for your network interface.
```bash
cd /etc/NetworkManager/system-connections/
nano ens3.nmconnection

```
- In the editor, add the following content, replacing the placeholder values with your actual network configuration:
```bash
[connection]
id=MyStaticConnection
type=ethernet
interface-name=ens3
permissions=

[ipv4]
address=192.168.0.24/24
dns=8.8.8.8,8.8.4.4;
gateway=192.168.0.1
method=manual
```
-After updating the configuration file with the required IP information, we restart NetworkManager for the changes to take effect.
```bash
systemctl restart NetworkManager

```