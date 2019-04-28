#! /bin/bash
set -e

MYSQL_ROOT_PWD=${MYSQL_ROOT_PWD:-"mysql"}
MYSQL_USER=${MYSQL_USER:-""}
MYSQL_USER_PWD=${MYSQL_USER_PWD:-""}
MYSQL_USER_DB=${MYSQL_USER_DB:-""}

echo "[i] Setting up new power user credentials."
service mysql start $ sleep 10

echo "[i] Setting root new password."
mysql --user=root --password=root -e "UPDATE mysql.user set authentication_string=password('$MYSQL_ROOT_PWD') where user='root'; FLUSH PRIVILEGES;"

echo "[i] Setting root remote password."
mysql --user=root --password=$MYSQL_ROOT_PWD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PWD' WITH GRANT OPTION; FLUSH PRIVILEGES;"

if [ -n "$MYSQL_USER_DB" ]; then
	echo "[i] Creating datebase: $MYSQL_USER_DB"
	mysql --user=root --password=$MYSQL_ROOT_PWD -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_USER_DB\` CHARACTER SET utf8 COLLATE utf8_general_ci; FLUSH PRIVILEGES;"

	if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_USER_PWD" ]; then
		echo "[i] Create new User: $MYSQL_USER with password $MYSQL_USER_PWD for new database $MYSQL_USER_DB."
		mysql --user=root --password=$MYSQL_ROOT_PWD -e "GRANT ALL PRIVILEGES ON \`$MYSQL_USER_DB\`.* TO '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_USER_PWD' WITH GRANT OPTION; FLUSH PRIVILEGES;"
	else
		echo "[i] Don\`t need to create new User."
	fi
else
	if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_USER_PWD" ]; then
		echo "[i] Create new User: $MYSQL_USER with password $MYSQL_USER_PWD for all database."
		mysql --user=root --password=$MYSQL_ROOT_PWD -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_USER_PWD' WITH GRANT OPTION; FLUSH PRIVILEGES;"
	else
		echo "[i] Don\`t need to create new User."
	fi
fi

/var/www/html/directus/bin/directus install:config -n $MYSQL_USER_DB -u $MYSQL_USER -p $MYSQL_USER_PWD
/var/www/html/directus/bin/directus install:database
/var/www/html/directus/bin/directus install:install -e admin@macdre.ca -p $MYSQL_USER_PWD

a2enmod rewrite
a2ensite directus
service apache2 start $ sleep 10
service apache2 reload $ sleep 10
service grafana-server start $ sleep 10
killall mysqld $ sleep 10
conda init $ sleep 10
sleep 5
echo "[i] Setting end,have fun."

exec "$@"
