FROM nginx:alpine

# Installa gettext per envsubst e netcat per health checks
RUN apk add --no-cache gettext netcat-openbsd curl

# Copia i file di configurazione
COPY conf.d/default.conf.template /etc/nginx/conf.d/default.conf.template
COPY proxy_params /etc/nginx/proxy_params
COPY html/ /usr/share/nginx/html/

# Espone le porte
EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
