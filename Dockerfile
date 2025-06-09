FROM debian:bookworm

RUN apt-get update -y && apt-get upgrade -y && apt-get install -y build-essential curl git unzip xz-utils zip libglu1-mesa

RUN mkdir -p /development
RUN curl https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.32.2-stable.tar.xz -O
RUN tar -xf flutter_linux_3.32.2-stable.tar.xz -C /development/
RUN git config --global --add safe.directory /development/flutter

ENV PATH="/development/flutter/bin:${PATH}"

WORKDIR /app

COPY . .

RUN flutter clean
RUN flutter build web --release --wasm

FROM caddy:2

COPY --from=0 /app/build/web /web

EXPOSE 80

ENTRYPOINT ["caddy", "file-server", "--root", "/web" ]