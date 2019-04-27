FROM ubuntu:latest
MAINTAINER macdre "ross.e.macd@gmail.com"


RUN echo "deb http://cn.archive.ubuntu.com/ubuntu/ bionic main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections
RUN echo "deb https://packages.grafana.com/oss/deb stable main > /etc/apt/sources.list.d/grafana.list"


ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
	apt-get -y install curl gnupg && \
	curl https://packages.grafana.com/gpg.key | apt-key add - && \
	apt-get -y install mysql-server-5.7 && \
	apt-get -y install git apache2 zip unzip composer && \
	apt-get -y install php php-curl php-mysql php-mbstring php-gd php-dom && \
	apt-get -y install libfontconfig grafana && \
	mkdir -p /var/lib/mysql && \
	mkdir -p /var/run/mysqld && \
	mkdir -p /var/log/mysql && \
	chown -R mysql:mysql /var/lib/mysql && \
	chown -R mysql:mysql /var/run/mysqld && \
	chown -R mysql:mysql /var/log/mysql && \
	chgrp -R mysql /var/lib/mysql && \
	usermod -d /var/lib/mysql/ mysql


# Enable mod_rewrite in apache
RUN cd /var/www/html && \
	git clone https://github.com/directus/directus.git && \
	chown www-data -R /var/www/html/directus


RUN cd /var/www/html/directus && \
	composer install


# UTF-8 and bind-address
RUN sed -i -e "$ a [client]\n\n[mysql]\n\n[mysqld]"  /etc/mysql/my.cnf && \
	sed -i -e "s/\(\[client\]\)/\1\ndefault-character-set = utf8/g" /etc/mysql/my.cnf && \
	sed -i -e "s/\(\[mysql\]\)/\1\ndefault-character-set = utf8/g" /etc/mysql/my.cnf && \
	sed -i -e "s/\(\[mysqld\]\)/\1\ninit_connect='SET NAMES utf8'\ncharacter-set-server = utf8\ncollation-server=utf8_unicode_ci\nbind-address = 0.0.0.0/g" /etc/mysql/my.cnf


VOLUME /var/lib/mysql


COPY ./startup.sh /root/startup.sh
RUN chmod +x /root/startup.sh


COPY ./directus.conf /etc/apache2/sites-available/directus.conf
RUN echo Listen 8080 >> /etc/apache2/ports.conf


EXPOSE 3306
EXPOSE 8080
EXPOSE 3000


ENTRYPOINT ["/root/startup.sh"]
CMD ["/usr/bin/mysqld_safe"]
