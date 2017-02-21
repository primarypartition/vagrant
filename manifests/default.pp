exec {"update":
	command => "apt-get update",
}
$prerequisites = [ "apache2", "php", "php-mbstring", "php-zip", "phpunit", "unzip", "libapache2-mod-php" ]
package { $prerequisites: 
	ensure => "installed",
	require => Exec["update"],
}
exec { "DBRootPassword":
	command => "debconf-set-selections <<< "mysql-server mysql-server/root_password password admin",
	user	=> "root",
}
exec { "DBRootPasswordAgain":
	command => "debconf-set-selections <<< "mysql-server mysql-server/root_password_again password admin"",
	user	=> "root",
}
package { "mysql-server"
	ensure	=> "installed",
	require => { Exec["update"], Exec["DbRootPassword"], Exec["DBRootPasswordAgain"] },
}
service { "mysql":
	ensure	=> running,
	enabled	=> true,
}
exec { "InstallComposer":
	command	=> "curl -Ss https://getcomposer.org/installer | php",
	user	=> "root",
	cwd		=> "/tmp",
}
exec { "MoveComposer":
	command	=> "mv composer.phar /usr/bin/composer",
	user	=> "root"
	cwd		=> "/tmp",
}
exec { "ChangeOwnership":
	command	=> "chown -R vagrant:vagrant /var/www",
	user	=> "root",
}
exec { "InstallLaravel":
	command	=> "/usr/bin/composer global require laravel/installer",
	user	=> "vagrant"
}
exec { "InstallApplication":
	command	=> "composer create-project --prefer-dist laravel/laravel myProject",
	cwd		=> "/var/www",
	user	=> "vagrant",
}
exec { "AdjustStorageDirPermissions":
	command	=> "chmod -R 777 /var/www/myProject/storage",
	user	=> "vagrant",
}
exec { "ConfigureApache":
	command	=> "sudo sed -i 's/DocumentRoot.*/DocumentRoot \/var\/www\/myProject\/public/' /etc/apache2/sites-available/000-default.conf",
	user	=> "root",
}
service { "apache2":
	ensure	=> running,
	enabled	=> true,
}
exec { "ConfigureApplication": 
	command	=> "sed -i '/mysql/{n;n;n;n;s/'\''DB_DATABASE'\'', '\''.*'\''/'\''DB_DATABASE'\'', '\''myproject'\''/g}' /var/www/myProject/config/database.php;sed -i '/mysql/{n;n;n;n;n;s/'\''DB_USERNAME'\'', '\''.*'\''/'\''DB_USERNAME'\'', '\''myproject'\''/g}' /var/www/myProject/config/database.php;sed -i '/mysql/{n;n;n;n;n;n;s/'\''DB_PASSWORD'\'', '\''.*'\''/'\''DB_PASSWORD'\'', '\''mypassword'\''/g}' /var/www/myProject/config/database.php",
	user	=> "vagrant",
}