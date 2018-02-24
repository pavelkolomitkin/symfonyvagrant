#!/usr/bin/env bash

# Update repositories
sudo apt-get update

# Install Apache2
sudo apt-get install apache2 -y

# Install Apache modules
sudo a2enmod rewrite
sudo a2enmod asis

# Install mysql server with user and password
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password 1234'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password 1234'
sudo apt-get -y install mysql-server

# Install php7.0 and needed modules
sudo apt-add-repository ppa:ondrej/php -y
sudo apt-get update
sudo apt-get install php7.0 php7.0-mysql php7.0-intl php7.0-xml -y

# Install php x-debug
sudo apt-get install php-xdebug
echo "xdebug.remote_enable=true
xdebug.remote_connect_back=true
xdebug.idekey=PHPSTORM" >> /etc/php/7.0/mods-available/xdebug.ini


# Install composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"

sudo mv composer.phar /usr/local/bin/composer
composer self-update

# Install symfony installer
sudo curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony
sudo chmod a+x /usr/local/bin/symfony

# Create symlink working directory to /var/www
sudo rm -fR /var/www/html/
sudo ln -fs /vagrant /var/www

# Sync apache vhost file to /etc/apache/sites-available and create symlink to /etc/apache/sites-enabled
sudo rm -f /etc/apache2/sites-available/000-default.conf
sudo ln -fs /vagrant/dev-vhost.conf /etc/apache2/sites-available/000-default.conf
sudo ln -fs /vagrant/dev-vhost.conf /etc/apache2/sites-enabled/000-default.conf

sudo echo "ServerName localhost" >> /etc/apache2/conf-available/server-name.conf
sudo ln -s /etc/apache2/conf-available/server-name.conf /etc/apache2/conf-enabled/server-name.conf

# Fix permissions of files
sed -i 's/APACHE_RUN_USER=www-data/APACHE_RUN_USER=vagrant/' /etc/apache2/envvars
sed -i 's/APACHE_RUN_GROUP=www-data/APACHE_RUN_GROUP=vagrant/' /etc/apache2/envvars


# Restart apache
sudo service apache2 restart
