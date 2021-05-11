# build
FROM node:12 AS build

WORKDIR /app

COPY package*.json ./
COPY .npmrc ./

RUN npm install

COPY . .

RUN npm run build

# production
FROM n8maninger/vue-router:beta

COPY --from=build /app/dist /www