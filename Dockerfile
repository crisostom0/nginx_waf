# syntax=docker/dockerfile:1

# Versão do Alpine Linux
ARG OS_VER="3.19"

# Imagem base
FROM alpine:${OS_VER}

# Instalar NGINX OSS e módulo NGINX App Protect WAF v5
RUN apk add openssl curl ca-certificates \
    && printf "%s%s%s%s\n" \
        "http://nginx.org/packages/mainline/alpine/v" \
        `egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release` \
        "/main" \
        | tee -a /etc/apk/repositories \
    && wget -O /etc/apk/keys/nginx_signing.rsa.pub https://cs.nginx.com/static/keys/nginx_signing.rsa.pub \
    && printf "https://pkgs.nginx.com/app-protect-x-oss/alpine/v`egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release`/main\n" | \
        tee -a /etc/apk/repositories \
    && apk update \
    && apk add nginx app-protect-module-oss \
    && mkdir -p /etc/nginx/conf.d \
    && mkdir -p /usr/share/nginx/html \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && rm -rf /var/cache/apk/*

# Copiar arquivos de configuração
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf
COPY waf-policy.json /etc/nginx/waf-policy.json

# Expor porta
EXPOSE 80

# Definir sinal de parada
STOPSIGNAL SIGQUIT

# Comando padrão
CMD ["nginx", "-g", "daemon off;"]
