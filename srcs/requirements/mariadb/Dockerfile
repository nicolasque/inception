FROM alpine:3.19

RUN apk add --no-cache mariadb mariadb-client

COPY conf/my.cnf /etc/mysql/my.cnf

COPY tools/mariadb_setup.sh /usr/local/bin/mariadb_setup.sh

RUN chmod +x /usr/local/bin/mariadb_setup.sh

EXPOSE 3306

CMD ["mariadb_setup.sh"]
