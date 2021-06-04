/* create database with the name wordpress */
CREATE DATABASE wordpress;
/*grant user 'root' access to the database */
GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost';
/* asign user */
/*UPDATE mysql.user SET Password=PASSWORD('1234') WHERE User='root';*/
update mysql.user set plugin = 'mysql_native_password' where user='root';
/*save changes */
FLUSH PRIVILEGES;
