docker build -t macdre/umdg:latest .
docker run --name mysql -d -p 3306:3306 -p 8080:8080 -p 3000:3000 -it -e MYSQL_ROOT_PWD=123 -e MYSQL_USER=dev -e MYSQL_USER_PWD=dev -e MYSQL_USER_DB=directus --entrypoint /bin/bash macdre/umdg
docker attach mysql
