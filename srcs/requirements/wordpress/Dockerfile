FROM alpine:3.19

RUN apk add --no-cache \
	php82 \
	php82-fpm \
	php82-mysqli \
	php82-json \
	php82-curl \
	php82-gd \
	php82-phar \
	php82-mbstring \
	mariadb-client \
	curl \
	netcat-openbsd

RUN sed -i 's/memory_limit = 128M/memory_limit = 512M/' /etc/php82/php.ini

RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x /usr/local/bin/wp


COPY conf/www.conf /etc/php82/php-fpm.d/www.conf


COPY tools/wp_setup.sh /usr/local/bin/wp_setup.sh
RUN chmod +x /usr/local/bin/wp_setup.sh


RUN mkdir -p /var/www/html
WORKDIR /var/www/html

EXPOSE 9000

CMD ["wp_setup.sh"]
