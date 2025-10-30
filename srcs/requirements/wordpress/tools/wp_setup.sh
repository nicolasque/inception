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

    # Descarga los archivos de WordPress
    wp core download --allow-root

    # Bucle de espera para la base de datos.
    # wp-cli es más fiable que 'mariadb-admin ping'
    until wp db check --allow-root --path=/var/www/html \
        --dbhost=mariadb \
        --dbname=$DB_NAME \
        --dbuser=$DB_USER \
        --dbpass=$DB_PASS
    do
        echo "Esperando a que la base de datos esté lista..."
        sleep 2
    done

    # Crea el archivo wp-config.php
    wp config create --allow-root \
        --dbhost=mariadb \
        --dbname=$DB_NAME \
        --dbuser=$DB_USER \
        --dbpass=$DB_PASS

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