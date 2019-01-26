SITE_NAME='auto8'

sudo mkdir /var/www/"$SITE_NAME"

sudo cp /vagrant/provision/nginx/sites-enabled-example.conf /etc/nginx/sites-available/"$SITE_NAME".conf

sed -i "s|{server_name}|${SITE_NAME}|" /etc/nginx/sites-available/"$SITE_NAME".conf

sudo ln -s /etc/nginx/sites-available/"$SITE_NAME".conf /etc/nginx/sites-enabled/

mysql -u root -ppassword -e "CREATE DATABASE $DATABASENAME" 