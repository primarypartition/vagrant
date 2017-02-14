  # Install the necessary prerequisites
sudo apt-get -y install apache2 php php-mbstring php-zip php-unit unzip 
# Set the admin user and password for MySQL database prior to installation
sudo debconf-set-selections <<< 'mysq-server mysql-server/root_password password admin'
sudo debconf-set-selections <<< 'mysq-server mysql-server/root_password_again password admin'
# Install MySQL server
sudo apt-get -y install mysql-server
# Create a database, a user for your application and assign a password for the user
mysql -u root -padmin < createUser.sql
# Install composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"  
php -r "if (hash_file('SHA384', 'composer-setup.php') === '55d6ead61b29c7bdee5cccfb50076874187bd9f21f65d8991d46ec5cc90518f447387fb9f76ebae1fbbacf329e583e30') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" 
php composer-setup.php && php -r "unlink('composer-setup.php');"
 # Add composer to the user's path to be handy anywhere
sudo ln -s /home/vagrant/composer.phar /usr/bin/composer
# Configure your PATH so that you can use the laravel command anywhere
export PATH=$PATH:~/.config/composer/vendor/bin/ 
# Use composer to install Laravel 5.1
 composer require laravel/installer
# Change the ownership of /var/www to be owned by vagrant to be able to work on it using the shared folder
sudo chown vagrant:vagrant /var/www
# Use laravel command to create a new project
 laravel new /var/www/myProject 
# Change the permissions of theh storage directory under the project to be 777 (Laravel requirement)
chmod -R 777 /var/www/myProject/storage 
#Change Apache configuration to point to Laravel web directory
sudo sed -i 's/DocumentRoot.*/DocumentRoot \/var\/www\/myProject\/public/' /etc/apache2/sites-available/000-default.conf
#Restart the web server to apply the changes
apachectl restart 
# Modify the application database settings file to point to the database  
sed -i '/mysql/{n;n;n;n;s/'\''DB_DATABASE'\'', '\''.*'\''/'\''DB_DATABASE'\'', '\''myproject'\''/g}' /var/www/myProject/config/database.php 
sed -i '/mysql/{n;n;n;n;n;s/'\''DB_USERNAME'\'', '\''.*'\''/'\''DB_USERNAME'\'', '\''myproject'\''/g}' /var/www/myProject/config/database.php
sed -i '/mysql/{n;n;n;n;n;n;s/'\''DB_PASSWORD'\'', '\''.*'\''/'\''DB_PASSWORD'\'', '\''mypassword'\''/g}' /var/www/myProject/config/database.php