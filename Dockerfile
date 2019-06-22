FROM nginx:alpine

COPY ./docker-static.conf /etc/nginx/conf.d/default.conf
COPY ./dist /usr/share/nginx/html