#!/bin/sh

CERT_DIR="/etc/nginx/ssl"
KEY_FILE="$CERT_DIR/${DOMAIN_NAME}.key"
CERT_FILE="$CERT_DIR/${DOMAIN_NAME}.crt"

if [ ! -f "$KEY_FILE" ] || [ ! -f "$CERT_FILE" ]; then
    echo "Generando certificados SSL autofirmados..."
    
    mkdir -p $CERT_DIR
    
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$KEY_FILE" \
        -out "$CERT_FILE" \
        -subj "/C=ES/ST=Urduliz/L=Urduliz/O=42/CN=${DOMAIN_NAME}"
    
    echo "Certificados generados."
else
    echo "Los certificados SSL ya existen."
fi

envsubst '${DOMAIN_NAME}' < /etc/nginx/nginx.template.conf > /etc/nginx/nginx.conf

echo "Configuración de NGINX creada."

# 'exec' cede el PID 1
# '-g "daemon off;"' mantiene NGINX en primer plano
echo "Lanzando NGINX..."
exec nginx -g "daemon off;"