#!/bin/bash

apache_config_file="/etc/apache2/apache2.conf"
mysql_config_file="/etc/mysql/my.cnf"

# Update the server
apt-get update
apt-get -y upgrade

if [[ -e /var/lock/vagrant-provision ]]; then
    exit;
fi

# Install Zend Server
chmod 777 /etc/apt/sources.list
sudo echo "deb http://repos.zend.com/zend-server/8.5/deb_apache2.4 server non-free" >> /etc/apt/sources.list
chmod 644 /etc/apt/sources.list
sudo wget http://repos.zend.com/zend.key -O- | sudo apt-key add -
apt-get update

# Install Zend Server
apt-get install -y zend-server-php-5.6
echo 'export PATH=$PATH:/usr/local/zend/bin' >> /etc/profile.d/zend-server.sh
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/zend/lib' >> /etc/profile.d/zend-server.sh
source /etc/profile.d/zend-server.sh

################################################################################
# Everything below this line should only need to be done once
# To re-run full provisioning, delete /var/lock/vagrant-provision and run
#
#    $ vagrant provision
#
# From the host machine
################################################################################

IPADDR=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://')
sed -i "s/^${IPADDR}.*//" /etc/hosts
echo $IPADDR ubuntu.localhost >> /etc/hosts			# Just to quiet down some error messages

# Install basic tools
apt-get -y install git

# Configure Apache mod-rewrite
sed -i "s/AllowOverride None/AllowOverride All/g" ${apache_config_file}

# Install MySQL
echo "mysql-server mysql-server/root_password password root" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password root" | sudo debconf-set-selections
apt-get -y install mysql-client mysql-server

sed -i "s/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" ${mysql_config_file}

# Allow root access from any host
echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION" | mysql -u root --password=root
echo "GRANT PROXY ON ''@'' TO 'root'@'%' WITH GRANT OPTION" | mysql -u root --password=root

# Cleanup the default HTML file created by Apache
#rm -r /var/www/html

# Create a symbolic link to htdocs folder host
#ln -s /vagrant/public /var/www/html


# Restart Services
service mysql restart
service zend-server restart

# Lock provision
touch /var/lock/vagrant-provision
