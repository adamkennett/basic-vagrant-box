# variables passed from Vagrantfile
URL=$1
PHPVERSION=$2
MYSQLVERSION=$3
DATABASENAME=$4
WORDPRESSINSTALL=$5
PHPEXTENSIONS=$6
SITETITLE='custombox'
ADMINUSER='admin'
ADMINPASSWORD='password'
ADMINEMAIL='admin@example.com'

#!/usr/bin/env bash
sudo apt-get -y install nginx
sudo service nginx start

# set up nginx server
sudo cp /vagrant/provision/nginx/nginx.conf /etc/nginx/sites-available/site.conf
sed -i "s|{php_version}|$2|" /etc/nginx/sites-available/site.conf
sed -i "s|{server_name}|$1|" /etc/nginx/sites-available/site.conf
sudo chmod 644 /etc/nginx/sites-available/site.conf
sudo ln -s /etc/nginx/sites-available/site.conf /etc/nginx/sites-enabled/site.conf
sudo service nginx restart

# clean /var/www
sudo rm -Rf /var/www

# symlink /var/www => /vagrant
ln -s /vagrant /var/www

# add repository to pull php from
sudo apt-add-repository -y ppa:ondrej/php

# update so the new repository is pulled in 
sudo apt-get -y update

# install the php-fpm package as nginx does not have php as default 
sudo apt-get -y install "$PHPVERSION-fpm"

# install php extensions 
sudo apt-get install "php$PHPVERSION-mysql" -y

if [[ "$PHPEXTENSIONS" == "true" ]] 
then
 sudo apt-get install "php$PHPVERSION-intl" -y
 sudo apt-get install "php$PHPVERSION-cli" -y
 sudo apt-get install "php$PHPVERSION-mcrypt" -y
 sudo apt-get install "php$PHPVERSION-curl" -y
 sudo apt-get install "php$PHPVERSION-gd" -y
 sudo apt-get install "php$PHPVERSION-mbstring" -y
 sudo apt-get install "php$PHPVERSION-mhash" -y
 sudo apt-get install "php$PHPVERSION-openssl" -y
 sudo apt-get install "php$PHPVERSION-simplexml" -y
 sudo apt-get install "php$PHPVERSION-soap" -y
 sudo apt-get install "php$PHPVERSION-xml" -y
 sudo apt-get install "php$PHPVERSION-xsl" -y
 sudo apt-get install "php$PHPVERSION-zip" -y
 sudo apt-get install "php$PHPVERSION-json" -y
 sudo apt-get install "php$PHPVERSION-iconv" -y
 sudo apt-get install "php$PHPVERSION-bcmath" -y
fi

# setting this to 1 is for apache so 0 as nginx is used here
sed -i "s|;cgi.fix_pathinfo=1|cgi.fix_pathinfo=0|" /etc/php/$PHPVERSION/fpm/php.ini
#Setup for file uploads
sed -i "s|post_max_size = 8|post_max_size = 50M|" /etc/php/$PHPVERSION/fpm/php.ini
sed -i "s|upload_max_filesize = 2M|upload_max_filesize = 50M|" /etc/php/$PHPVERSION/fpm/php.ini

# install composer
curl -Ss https://getcomposer.org/installer | php > /dev/null
sudo mv composer.phar /usr/bin/composer

# install mysql 
debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt-get update
sudo apt-get install -y mysql-server-$MYSQLVERSION

# set up a database and user
mysql -u root -proot -e "CREATE DATABASE $DATABASENAME" 
mysql -u root -proot -e "GRANT ALL ON $DATABASENAME.* TO root@localhost IDENTIFIED BY 'password'" 

# restart nginx and php 
sudo service nginx restart
sudo service php$PHPVERSION-fpm restart
sudo service mysql restart

# go to server root
cd /var/www/
mkdir html
cd html

sudo usermod -g www-data vagrant

# move auth credentials containing repo usernames and passwords
# this ensures composer can pull the repo 
# remember to rename auth-example.json to auth.json beforehand
# cp /var/www/provision/auth.json ~/.config/composer

sudo chown -R vagrant:vagrant ~vagrant
sudo chown -R vagrant:vagrant /vagrant

#sudo mv wp-cli.phar /usr/local/bin/wp

cd /var/www/html

if [[ "$WORDPRESSINSTALL" == "true" ]] 
then

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
#mv wp-cli.phar /usr/local/bin/wp

php wp-cli.phar core download --allow-root
php wp-cli.phar config create --dbname=wordpress --dbuser=root --dbpass=password --allow-root
php wp-cli.phar core install --url=$URL --title=$SITETITLE --admin_user=$ADMINUSER --admin_password=$ADMINPASSWORD --admin_email=$ADMINEMAIL --allow-root

fi

sudo apt-get install htop -y

# add scripts
sudo cp /vagrant/provision/nginx/addsite.sh /home/vagrant




