#!/bin/sh

# Rutas de los certificados
CERT_DIR="/etc/nginx/ssl"
KEY_FILE="$CERT_DIR/${DOMAIN_NAME}.key"
CERT_FILE="$CERT_DIR/${DOMAIN_NAME}.crt"

# 1. Generar certificados SSL si no existen
if [ ! -f "$KEY_FILE" ] || [ ! -f "$CERT_FILE" ]; then
    echo "Generando certificados SSL autofirmados..."
    
    # Crea el directorio
    mkdir -p $CERT_DIR
    
    # Genera el certificado y la clave
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$KEY_FILE" \
        -out "$CERT_FILE" \
        -subj "/C=ES/ST=Urduliz/L=Urduliz/O=42/CN=${DOMAIN_NAME}"
    
    echo "Certificados generados."
else
    echo "Los certificados SSL ya existen."
fi

# 2. Sustituir variables de entorno en la plantilla de NGINX
# 'envsubst' reemplaza ${DOMAIN_NAME} con el valor del .env
envsubst '${DOMAIN_NAME}' < /etc/nginx/nginx.template.conf > /etc/nginx/nginx.conf

echo "Configuración de NGINX creada."

# 3. Lanzar NGINX
# 'exec' cede el PID 1
# '-g "daemon off;"' mantiene NGINX en primer plano
echo "Lanzando NGINX..."
exec nginx -g "daemon off;"