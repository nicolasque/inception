#!/bin/sh

sleep 5

echo "--- Probando conexión a internet ---"
ping -c 3 google.com
echo "--- Fin del test de conexión ---"

cd /var/www/html

if [ ! -f "wp-config.php" ]; then
    echo "WordPress no encontrado. Instalando..."

    wp core download --allow-root --force

    echo "Esperando a que MariaDB esté disponible..."
    until nc -z mariadb 3306; do
        echo "MariaDB aún no responde en el puerto 3306..."
        sleep 3
    done
    echo "MariaDB está disponible!"

    sleep 3

    wp config create --allow-root \
        --dbhost=mariadb \
        --dbname=$DB_NAME \
        --dbuser=$DB_USER \
        --dbpass=$DB_PASS \
        --skip-check

    until wp db check --allow-root
    do
        echo "Esperando a que la base de datos esté completamente lista..."
        sleep 2
    done

    wp core install --allow-root \
        --url=$DOMAIN_NAME \
        --title="Inception" \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASS \
        --admin_email=$WP_ADMIN_EMAIL

    wp user create --allow-root \
        $WP_USER \
        $WP_EMAIL \
        --role=author \
        --user_pass=$WP_PASS

    echo "WordPress instalado correctamente."
else
    echo "WordPress ya está instalado."
fi

chown -R nobody:nobody /var/www/html

# 'exec' reemplaza este script con el proceso de php-fpm.
# '-F' (foreground) es para que sea el PID 1
# y el contenedor no muera.
echo "Lanzando php-fpm..."
exec php-fpm82 -F