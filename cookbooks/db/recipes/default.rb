execute "sudo apt-get update"
execute  "sudo echo 'mysql-server mysql-server/root_password password admin' | debconf-set-selections"
execute  "sudo echo 'mysql-server mysql-server/root_password_again password admin' | debconf-set-selections"
package "mysql-server"
execute "sed -i 's/bind-address\\s*=.*/bind-address=172.28.128.100/' /etc/mysql/mysql.conf.d/mysqld.cnf"
service 'mysql' do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :restart ]
end
execute "mysql -u root -padmin < /vagrant/createUser.sql"