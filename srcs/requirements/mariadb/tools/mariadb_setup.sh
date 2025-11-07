#!/bin/sh

# Directorio de datos de MariaDB
DATADIR="/var/lib/mysql"

# Comprueba si la base de datos ya está inicializada
if [ ! -d "$DATADIR/mysql" ]; then
    echo "Directorio de datos no encontrado. Inicializando MariaDB..."

    # Inicializa la estructura de la base de datos
    mariadb-install-db --user=mysql --datadir=$DATADIR

    # Inicia el servidor MariaDB en segundo plano temporalmente
    # Usamos el .cnf para ser consistentes
    mysqld_safe --defaults-file=/etc/mysql/my.cnf --datadir=$DATADIR &

    # Espera a que el servidor esté listo
    while ! mariadb-admin ping --silent; do
        sleep 1
    done

    echo "Servidor temporal iniciado. Aplicando configuración de seguridad..."

    # --- INICIO DE LA LÓGICA DE SEGURIDAD CORREGIDA ---
    # Todos los comandos de limpieza se ejecutan con 'unix_socket' (sin -u -p)
    # ANTES de establecer la contraseña de root.

    # 1. Eliminar usuarios anónimos (LA CAUSA DE TU PROBLEMA)
    # Esto elimina ''@'localhost' que permite el login sin contraseña.
    mariadb -e "DELETE FROM mysql.user WHERE User='';"

    # 2. Eliminar la base de datos 'test'
    mariadb -e "DROP DATABASE IF EXISTS test;"
    mariadb -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"

    # 3. Eliminar otros 'root' (Buena práctica)
    # Dejamos solo root@localhost, que aseguraremos en el paso 4
    mariadb -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"

    # 4. Establecer la contraseña de root
    # Cambiamos el plugin de 'unix_socket' a 'mysql_native_password'
    mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('$DB_ROOT_PASS');"

    # 5. Crear la base de datos de WordPress
    # A PARTIR DE AQUÍ, usamos -uroot -p"$DB_ROOT_PASS"
    mariadb -uroot -p"$DB_ROOT_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

    # 6. Crear el usuario de WordPress para '%' (host externo)
    mariadb -uroot -p"$DB_ROOT_PASS" -e "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED VIA mysql_native_password USING PASSWORD('$DB_PASS');"
    
    # 7. Dar permisos a ese usuario
    mariadb -uroot -p"$DB_ROOT_PASS" -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';"

    # 8. Aplicar todos los cambios
    mariadb -uroot -p"$DB_ROOT_PASS" -e "FLUSH PRIVILEGES;"

    # Detiene el servidor temporal (ahora con la contraseña de root)
    mariadb-admin shutdown -p"$DB_ROOT_PASS"

    echo "Inicialización de MariaDB completada."
else
    echo "MariaDB ya está inicializado."
fi

# --- Lanzamiento del Servidor ---
echo "Lanzando MariaDB..."
exec mysqld_safe --defaults-file=/etc/mysql/my.cnf --datadir=$DATADIR