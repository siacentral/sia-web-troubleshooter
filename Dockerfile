FROM --platform=$BUILDPLATFORM rust:slim AS wasm

RUN apt-get update
RUN apt-get install -y curl
RUN apt-get clean

RUN rustup target add wasm32-unknown-unknown
RUN curl -sSf https://rustwasm.github.io/wasm-pack/installer/init.sh | sh

WORKDIR /wasm

COPY wasm /wasm

RUN wasm-pack build --release --target web --no-typescript --no-pack --out-dir /wasm/pkg --out-name troubleshooter_wasm

FROM debian:latest AS build

RUN apt-get update
RUN apt-get install -y curl git unzip xz-utils zip libglu1-mesa build-essential
RUN apt-get clean

RUN git clone -b stable --single-branch --depth=1 https://github.com/flutter/flutter.git /usr/local/flutter

ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter doctor -v
RUN flutter channel stable
RUN flutter upgrade
RUN flutter config --enable-web

WORKDIR /app

COPY . /app
COPY --from=wasm /wasm/pkg /app/web/wasm

RUN flutter pub get
RUN flutter build web --release

FROM caddy:2

WORKDIR /web

COPY --from=build /app/build/web /web

EXPOSE 80

ENTRYPOINT ["caddy", "file-server", "--root", "/web" ]