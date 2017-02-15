# Refresh your repositories
sudo apt-get update
# Install the necessary prerequisites
sudo apt-get install -y apache2 php php-mbstring php-zip phpunit unzip libapache2-mod-php
# Set the admin user and password for MySQL database prior to installation
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password admin'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password admin'
# Install MySQL server
sudo apt-get -y install mysql-server
# Start the DB server
sudo service mysql start
# Create a database, a user for your application and assign a password for the user
mysql -u root -padmin < /vagrant/createUser.sql
# Install composer
curl -Ss https://getcomposer.org/installer | php
mv composer.phar /usr/bin/composer
# Change the ownership of /var/www to be owned by vagrant to be able to work on it using the shared folder
sudo chown -R vagrant:vagrant /var/www
# Use composer to install Laravel 5.1
/usr/bin/composer global require laravel/installer
# Use laravel command to create a new project
cd /var/www/
#/home/vagrant/.config/composer/vendor/bin/laravel -vvv new myProject
composer create-project --prefer-dist laravel/laravel myProject
# Change the permissions of theh storage directory under the project to be 777 (Laravel requirement)
chmod -R 777 /var/www/myProject/storage

#Change Apache configuration to point to Laravel web directory
sudo sed -i 's/DocumentRoot.*/DocumentRoot \/var\/www\/myProject\/public/' /etc/apache2/sites-available/000-default.conf
#Restart the web server to apply the changes
sudo apachectl start
#Modify the application database settings file to point to the database  
sed -i '/mysql/{n;n;n;n;s/'\''DB_DATABASE'\'', '\''.*'\''/'\''DB_DATABASE'\'', '\''myproject'\''/g}' /var/www/myProject/config/database.php 
sed -i '/mysql/{n;n;n;n;n;s/'\''DB_USERNAME'\'', '\''.*'\''/'\''DB_USERNAME'\'', '\''myproject'\''/g}' /var/www/myProject/config/database.php
sed -i '/mysql/{n;n;n;n;n;n;s/'\''DB_PASSWORD'\'', '\''.*'\''/'\''DB_PASSWORD'\'', '\''mypassword'\''/g}' /var/www/myProject/config/database.php
