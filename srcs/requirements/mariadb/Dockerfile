FROM alpine:3.22

RUN apk add --no-cache mariadb mariadb-client

COPY tools/mariadb_setup.sh /usr/local/bin/mariadb_setup.sh

RUN chmod +x /usr/local/bin/mariadb_setup.sh

EXPOSE 3000

CMD ["mariadb_setup.sh"]
