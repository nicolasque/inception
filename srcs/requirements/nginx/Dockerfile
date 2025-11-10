FROM alpine:3.19


RUN apk add --no-cache nginx openssl gettext netcat-openbsd


COPY conf/nginx.template.conf /etc/nginx/nginx.template.conf

COPY tools/setup_nginx.sh /usr/local/bin/setup_nginx.sh
RUN chmod +x /usr/local/bin/setup_nginx.sh

EXPOSE 443

CMD ["setup_nginx.sh"]