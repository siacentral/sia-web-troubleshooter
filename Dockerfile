FROM node:16 AS build

WORKDIR /app

COPY . .

RUN npm i && npm run build

FROM n8maninger/vue-router

COPY --from=build /app/dist /www