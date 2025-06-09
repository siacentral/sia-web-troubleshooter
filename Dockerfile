FROM caddy:2

WORKDIR /web

COPY ./build/web /web

EXPOSE 80

ENTRYPOINT ["caddy", "file-server", "--root", "/web" ]