#Descargar la imagen requerida a traves de docker hub
FROM debian:buster

#Descarga e instalacion de configuraciones y servicios
RUN apt-get -y update &&  apt-get -y upgrade && \
apt -y install nginx \
mariadb-server mariadb-client \
php php-fpm php-mysql \
php-cli php-common php-mbstring php-intl php-xml \
zip unzip \
openssl

RUN apt-get update

#Preparando el directorio por defecto para acceder a la web
RUN	rm -rf /var/www/html/index.* && rm -rf /etc/nginx/sites-available/default
COPY /srcs/default /etc/nginx/sites-available
COPY /srcs/index.* /var/www/html

#Configurar SSL
RUN mkdir /etc/nginx/ssl \
&& chmod 750 /etc/nginx/ssl \
&& openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
-out /etc/nginx/ssl/example.crt \
-keyout /etc/nginx/ssl/example.key -subj "/C=ES/ST=Madrid/L=Madrid/O=42 School/OU=msantos/CN=localhost"

#Instalar y configurar wordpress
COPY /srcs/wordpress-5.3.2.zip /
RUN	unzip wordpress-5.3.2 -d /var/www/html \
&& chown -R www-data:www-data /var/www/html/wordpress \
&& chmod -R 755 /var/www/html/wordpress
COPY /srcs/wp-config.php /var/www/html/wordpress
RUN ln -s /usr/share/phpmyadmin /usr/share/nginx/html/wordpress

#Activar mysql crear BBDD y asignar al usuario de wordpress privilegios
COPY /srcs/init.sql /var/www/html
RUN service mysql start && mysql < /var/www/html/init.sql

#Instalar y configurar phpmyadmin
COPY /srcs/phpMyAdmin-5.0.1-all-languages.zip /
RUN	unzip phpMyAdmin-5.0.1-all-languages.zip -d / \
&& mv phpMyAdmin-* /var/www/html && mv /var/www/html/phpMyAdmin-5.0.1-all-languages /var/www/html/phpmyadmin \
&& chown -R www-data:www-data /var/www/html/phpmyadmin \
&& chmod -R 755 /var/www/html/phpmyadmin
COPY /srcs/config.inc.php /var/www/html/phpmyadmin
#&& ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled \

RUN apt-get update

#Iniciar servicios
CMD service mysql start \
&& /etc/init.d/php7.3-fpm start \
&& service nginx start && bash

#Alertar al contenedor de los puertos que se van a utilizar
EXPOSE 80 443