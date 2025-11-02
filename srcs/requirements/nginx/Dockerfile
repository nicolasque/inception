FROM alpine:3.19

# Instalamos nginx, openssl (para los certificados), gettext (para 'envsubst')
# y netcat-openbsd (para el healthcheck)
RUN apk add --no-cache nginx openssl gettext netcat-openbsd

# Copiamos nuestra plantilla de configuración de NGINX
# La llamamos .template porque le vamos a sustituir variables
COPY conf/nginx.template.conf /etc/nginx/nginx.template.conf

# Copiamos nuestro script de entrada
COPY tools/setup_nginx.sh /usr/local/bin/setup_nginx.sh
RUN chmod +x /usr/local/bin/setup_nginx.sh

# Exponemos el puerto 443 (HTTPS)
EXPOSE 443

# El script se encarga de todo
CMD ["setup_nginx.sh"]