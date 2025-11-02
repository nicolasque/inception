FROM alpine:3.19

# Instalamos php-fpm y las extensiones que WordPress necesita.
# 'mariadb-client' es necesario para que 'wp-cli' pueda conectarse a la BBDD.
# 'curl' lo usaremos para descargar wp-cli.
# 'netcat-openbsd' para verificar disponibilidad de puertos
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

# Descargamos wp-cli
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
# Le damos permisos de ejecución
RUN chmod +x /usr/local/bin/wp

# Copiamos el archivo de configuración de php-fpm
# (Lo crearemos en el paso 2)
COPY conf/www.conf /etc/php82/php-fpm.d/www.conf

# Copiamos nuestro script de entrada
# (Lo crearemos en el paso 3)
COPY tools/wp_setup.sh /usr/local/bin/wp_setup.sh
RUN chmod +x /usr/local/bin/wp_setup.sh

# Creamos el directorio de WordPress.
# El volumen se montará aquí.
RUN mkdir -p /var/www/html
WORKDIR /var/www/html

# Exponemos el puerto 9000.
# NGINX se conectará a este puerto. No se publica al host.
EXPOSE 9000

# Script que configura y lanza php-fpm
CMD ["wp_setup.sh"]
