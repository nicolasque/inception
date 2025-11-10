#!/bin/sh

DATADIR="/var/lib/mysql"

if [ ! -d "$DATADIR/mysql" ]; then
    echo "=== Inicializando MariaDB desde cero ==="

    mariadb-install-db --user=mysql --datadir=$DATADIR

    echo "Iniciando servidor temporal..."
    mysqld_safe --defaults-file=/etc/mysql/my.cnf --datadir=$DATADIR &

    echo "Esperando a que MariaDB esté listo..."
    until mariadb-admin ping --silent 2>/dev/null; do
        sleep 1
    done
    echo "MariaDB respondiendo!"

    echo "=== Limpieza de seguridad ==="
    
    mariadb -e "DELETE FROM mysql.user WHERE User='';" 2>/dev/null
    
    mariadb -e "DROP DATABASE IF EXISTS test;" 2>/dev/null
    mariadb -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';" 2>/dev/null
    
    mariadb -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');" 2>/dev/null
    
    mariadb -e "FLUSH PRIVILEGES;" 2>/dev/null
    
    echo "=== Configurando usuario root ==="

    mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASS';"
    mariadb -e "FLUSH PRIVILEGES;"

    echo "=== Creando base de datos y usuario de WordPress ==="

    mariadb -uroot -p"$DB_ROOT_PASS" <<-EOSQL
        CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;
        
        -- Crear usuario con autenticación nativa
        CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';
        
        -- Otorgar permisos
        GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';
        
        -- Aplicar cambios
        FLUSH PRIVILEGES;
EOSQL

    echo "=== Verificando usuario creado ==="
    mariadb -uroot -p"$DB_ROOT_PASS" -e "SELECT User, Host, plugin FROM mysql.user WHERE User='$DB_USER';"

    echo "Deteniendo servidor temporal..."
    mariadb-admin shutdown -uroot -p"$DB_ROOT_PASS"

    echo "=== Inicialización completada ==="
else
    echo "=== MariaDB ya inicializado ==="
fi

echo "=== Lanzando MariaDB ==="
exec mysqld_safe --defaults-file=/etc/mysql/my.cnf --datadir=$DATADIR