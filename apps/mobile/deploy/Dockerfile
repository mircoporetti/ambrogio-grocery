FROM nginxinc/nginx-unprivileged:1.31.7-alpine
COPY deploy/default.conf.template /etc/nginx/templates/default.conf.template
COPY build/web /usr/share/nginx/html
ENV API_ORIGIN=https://api-ambrogio.mircoporetti.me \
    PHOTOS_ORIGIN=https://*.r2.cloudflarestorage.com
EXPOSE 8080
