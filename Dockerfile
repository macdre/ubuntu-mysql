FROM ubuntu:latest
MAINTAINER macdre "ross.e.macd@gmail.com"


RUN echo "deb http://cn.archive.ubuntu.com/ubuntu/ bionic main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections


ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
	apt-get -y install apt-utils curl gnupg libfontconfig && \
	curl https://packages.grafana.com/gpg.key | apt-key add -


RUN echo "deb https://packages.grafana.com/oss/deb stable main" >> /etc/apt/sources.list
RUN	apt-get update && \
	apt-get -y install grafana


RUN apt-get -y install mysql-server-5.7 && \
	apt-get -y install git apache2 zip unzip composer && \
	apt-get -y install php php-curl php-mysql php-mbstring php-gd php-dom && \
	mkdir -p /var/lib/mysql && \
	mkdir -p /var/run/mysqld && \
	mkdir -p /var/log/mysql && \
	chown -R mysql:mysql /var/lib/mysql && \
	chown -R mysql:mysql /var/run/mysqld && \
	chown -R mysql:mysql /var/log/mysql && \
	chgrp -R mysql /var/lib/mysql && \
	usermod -d /var/lib/mysql/ mysql


# Install and configure directus
RUN cd /var/www/html && \
	git clone https://github.com/directus/directus.git && \
	chown www-data -R /var/www/html/directus && \
	cd /var/www/html/directus && \
	composer install
ENV PATH /var/www/html/directus/bin:$PATH


# Install and configure anaconda distribution
RUN	apt-get update
RUN apt-get -y install wget libxrender1 unixodbc unixodbc-dev
RUN wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 0 https://repo.anaconda.com/archive/Anaconda3-2019.03-Linux-x86_64.sh -O ~/anaconda.sh
RUN bash ~/anaconda.sh -b -p $HOME/anaconda
RUN rm ~/anaconda.sh
ENV PATH /root/anaconda/bin:$PATH
RUN conda update conda
RUN conda update anaconda


RUN conda create -n r_env r-essentials r-base
ENV PATH /root/anaconda/envs/r_env/bin:$PATH
RUN	echo "source activate r_env" > ~/.bashrc
RUN conda install -n r_env -y r-repr r-irdisplay r-irkernel r-caret r-dplyr r-rodbc r-keras keras
RUN R -e "IRkernel::installspec()" && \
	mkdir -p /root/notebooks
COPY ./jupyter_notebook_config.py /root/.jupyter/jupyter_notebook_config.py
COPY ./climateNotebook.ipynb /root/notebooks/climateNotebook.ipynb
COPY ./createTables.sql /root/createTables.sql


# UTF-8 and bind-address
RUN sed -i -e "$ a [client]\n\n[mysql]\n\n[mysqld]"  /etc/mysql/my.cnf && \
	sed -i -e "s/\(\[client\]\)/\1\ndefault-character-set = utf8/g" /etc/mysql/my.cnf && \
	sed -i -e "s/\(\[mysql\]\)/\1\ndefault-character-set = utf8/g" /etc/mysql/my.cnf && \
	sed -i -e "s/\(\[mysqld\]\)/\1\ninit_connect='SET NAMES utf8'\ncharacter-set-server = utf8\ncollation-server=utf8_unicode_ci\nbind-address = 0.0.0.0/g" /etc/mysql/my.cnf


COPY ./startup.sh /root/startup.sh
RUN chmod +x /root/startup.sh


COPY ./directus.conf /etc/apache2/sites-available/directus.conf
RUN echo Listen 8080 >> /etc/apache2/ports.conf

RUN wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 0 https://dev.mysql.com/get/Downloads/Connector-ODBC/8.0/mysql-connector-odbc-8.0.16-linux-ubuntu18.04-x86-64bit.tar.gz -O ~/mysqlConnector.tar.gz
RUN cd /root && \ 
	tar xvf mysqlConnector.tar.gz && \
	cd mysql-connector-odbc-8.0.16-linux-ubuntu18.04-x86-64bit && \
	cp ./bin/* /usr/local/bin && \
	cp ./lib/* /usr/local/lib

COPY ./odbc.ini /etc/odbc.ini

EXPOSE 3306
EXPOSE 8080
EXPOSE 3000
EXPOSE 8888


ENTRYPOINT ["/root/startup.sh"]
CMD ["/usr/bin/mysqld_safe"]