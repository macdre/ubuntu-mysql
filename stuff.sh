docker build -t macdre/umdg:latest .
docker run -it --name mysql -d -p 3306:3306 -p 8080:8080 -p 3000:3000 -p 8888:8888 -e MYSQL_ROOT_PWD=123 -e MYSQL_USER=dev -e MYSQL_USER_PWD=dev -e MYSQL_USER_DB=directus --entrypoint /bin/bash macdre/umdg
docker attach mysql

docker build -t macdre/umdg:latest .
docker run --name mysql -d -p 3306:3306 -p 8080:8080 -p 3000:3000 -p 8888:8888 -e MYSQL_ROOT_PWD=123 -e MYSQL_USER=dev -e MYSQL_USER_PWD=dev -e MYSQL_USER_DB=directus macdre/umdg
winpty docker attach mysql

docker build -t macdre/umdg:latest .
docker run -itd --name mysql -p 3306:3306 -p 8080:8080 -p 3000:3000 -p 8888:8888 -e MYSQL_ROOT_PWD=123 -e MYSQL_USER=dev -e MYSQL_USER_PWD=dev -e MYSQL_USER_DB=directus macdre/umdg
winpty docker exec -it mysql //bin/bash