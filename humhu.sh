# Script de instalação Humhub Ubuntu 20.04
# bash install_humhub.sh link_da_versao url_da_intranet
# exemplo: install_humhub.sh https://www.humhub.com/download/package/humhub-1.9.0.tar.gz intranet6.rgainfo.com.br SenhaDB


# Instalação de requerimentos
sudo apt install software-properties-common gcc make autoconf libc-dev pkg-config  libmagickwand-dev -y
sudo apt install nano wget mycli certbot python3-certbot-apache network-manager-openvpn  openvpn openvpn-systemd-resolved -y
sudo apt install apache2  mariadb-server mariadb-client -y
sudo apt install php libapache2-mod-php php-common php-gmp php-curl php-intl php-mbstring php-xmlrpc php-mysql php-gd php-xml php-cli php-zip php-sqlite3 php-ldap  php-pdo  php-apcu php-gmagick  -y

sudo systemctl enable --now apache2.service
sudo systemctl enable --now mariadb.service

# Configurando bancod de dados
mysql -e "CREATE DATABASE humhub"
mysql -e "CREATE USER 'admin029'@'localhost' IDENTIFIED BY '$3';"
mysql -e "GRANT ALL ON humhub.* TO 'admin029'@'localhost' WITH GRANT OPTION;"
mysql -e " FLUSH PRIVILEGES;"

## Configurando php.ini
sed -i 's/s*=*.*memory_limit\s*=.*/memory_limit \= 1024M/g' /etc/php/7.4/apache2/php.ini 
sed -i 's/s*=*.*upload_max_filesize \s*=*.*/upload_max_filesize = 500M/g' /etc/php/7.4/apache2/php.ini
sed -i 's/s*=*.*max_execution_time \s*=*.*/max_execution_time = 600/g' /etc/php/7.4/apache2/php.ini
sed -i 's/s*=*.*max_input_vars = \s*=*.*/max_input_vars = 1500/g' /etc/php/7.4/apache2/php.ini
sed -i 's/s*=*.*date.timezone \s*=*.*/date.timezone \= America\/Sao_Paulo/g' /etc/php/7.4/apache2/php.ini
sed -i 's/s*=*.*short_open_tag \s*=*.*/short_open_tag \= On/g' /etc/php/7.4/apache2/php.ini
sed -i 's/s*=*.*allow_url_fopen \s*=*.*/allow_url_fopen \= On/g' /etc/php/7.4/apache2/php.ini
sed -i 's/s*=*.*file_uploads \s*=*.*/file_uploads \= On/g' /etc/php/7.4/apache2/php.ini


## Configurado o OpenVPN
sed -i 's/s*=*.AUTOSTART\="all"/AUTOSTART\="all"/g'  /etc/default/openvpn
sed -i 's/LimitNPROC\=100/\#LimitNPROC\=100/g'  /lib/systemd/system/openvpn@.service


## Baixando e extraindo o humhub
wget $1 -O - | tar -xz -C /tmp/


mv /tmp/humhub-*/*  /var/www/html/
sudo chown -R www-data:www-data  /var/www/html/
sudo chmod -R 755  /var/www/html/
rm /var/www/html/index.html

## Configurando o Virtualhost
cat <<EOF> /etc/apache2/sites-available/hunhub.conf
<VirtualHost *:80>
     ServerAdmin admin@$2
     DocumentRoot /var/www/html/
     ServerName $2
     ServerAlias $2

     <Directory /var/www/html/>
        Options +FollowSymlinks
        AllowOverride All
        Require all granted
     </Directory>

     ErrorLog ${APACHE_LOG_DIR}/error.log
     CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF


sudo a2ensite humhub.conf
sudo a2enmod rewrite
sudo systemctl restart apache2.service
rm /var/www/html/index.html

## Habilitando Certificado SSL para a intranet
certbot --apache -d $2




