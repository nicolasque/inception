#!/bin/sh

# Directorio de datos de MariaDB
DATADIR="/var/lib/mysql"

# Comprueba si la base de datos ya está inicializada
if [ ! -d "$DATADIR/mysql" ]; then
    echo "Directorio de datos no encontrado. Inicializando MariaDB..."

    # Inicializa la estructura de la base de datos
    # 'mysql_install_db' es el comando estándar para esto
    mariadb-install-db --user=mysql --datadir=$DATADIR

    # Inicia el servidor MariaDB en segundo plano temporalmente
    mysqld_safe --datadir=$DATADIR &

    # Espera a que el servidor esté listo
    while ! mariadb-admin ping --silent; do
        sleep 1
    done

    # --- Configuración de Seguridad ---
    # Aquí es donde usas tus variables de entorno [cite: 116]
    # (Estas variables las definirás en tu .env y docker-compose.yml)

    # 1. Cambia la contraseña de root
    mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASS';"

    # 2. Crea tu base de datos de WordPress [cite: 89]
    mariadb -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

    # 3. Crea tu usuario de WordPress (¡no 'admin'!) [cite: 107]
    mariadb -e "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';"

    # 4. Da permisos a ese usuario sobre esa base de datos
    mariadb -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';"

    # 5. Aplica los cambios
    mariadb -e "FLUSH PRIVILEGES;"

    # Detiene el servidor temporal
    mariadb-admin shutdown

    echo "Inicialización de MariaDB completada."
else
    echo "MariaDB ya está inicializado. Omitiendo configuración."
fi

# --- Lanzamiento del Servidor ---
# Este es el comando final.
# 'exec' reemplaza este script con el proceso 'mysqld_safe',
# cediéndole el PID 1. Esto cumple la regla de no usar 'hacks'[cite: 103].
echo "Lanzando MariaDB..."
exec mysqld_safe --datadir=$DATADIR
