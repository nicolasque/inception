FROM alpine:3.22

# Instalamos nginx, openssl (para los certificados) y gettext (para 'envsubst')
RUN apk add --no-cache nginx openssl gettext

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