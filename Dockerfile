FROM node:12 AS build

WORKDIR /app

COPY . .

RUN npm i \
	&& npm run build

FROM n8maninger/vue-router:beta

COPY --from=build /app/dist /www