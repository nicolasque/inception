#!/bin/sh

# Pequeña espera para asegurar que MariaDB esté listo.
# El 'healthcheck' de Docker Compose maneja esto, pero una
# pequeña espera aquí no hace daño.
sleep 5

echo "--- Probando conexión a internet ---"
ping -c 3 google.com
echo "--- Fin del test de conexión ---"

# Nos movemos al directorio de WordPress
cd /var/www/html

# Comprueba si WordPress ya está instalado
if [ ! -f "wp-config.php" ]; then
    echo "WordPress no encontrado. Instalando..."

    # Descarga los archivos de WordPress (--force por si hay archivos parciales)
    wp core download --allow-root --force

    # Espera a que MariaDB esté disponible en el puerto 3306
    echo "Esperando a que MariaDB esté disponible..."
    until nc -z mariadb 3306; do
        echo "MariaDB aún no responde en el puerto 3306..."
        sleep 3
    done
    echo "MariaDB está disponible!"

    # Pequeña espera adicional para asegurar que MariaDB está completamente inicializado
    sleep 3

    # Crea el archivo wp-config.php
    wp config create --allow-root \
        --dbhost=mariadb \
        --dbname=$DB_NAME \
        --dbuser=$DB_USER \
        --dbpass=$DB_PASS \
        --skip-check

    # Ahora verifica que la base de datos funciona
    until wp db check --allow-root
    do
        echo "Esperando a que la base de datos esté completamente lista..."
        sleep 2
    done

    # Instala WordPress
    # ¡Importante! [cite_start]El admin user NO PUEDE ser 'admin' [cite: 699]
    wp core install --allow-root \
        --url=$DOMAIN_NAME \
        --title="Inception" \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASS \
        --admin_email=$WP_ADMIN_EMAIL

    # [cite_start]Crea el segundo usuario requerido por el subject [cite: 698]
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

# --- Lanzamiento del Servicio ---
# 'exec' reemplaza este script con el proceso de php-fpm.
# '-F' (foreground) es OBLIGATORIO para que sea el PID 1
# y el contenedor no muera.
echo "Lanzando php-fpm..."
exec php-fpm82 -F