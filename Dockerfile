# Etapa 1: Compilar aplicación Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY . .

RUN flutter create . --platforms=web --project-name=casvium \
    && flutter pub get \
    && flutter build web --release

# Etapa 2: Servidor Node.js que sirve Flutter Web y sincroniza con PostgreSQL de Railway
FROM node:20-alpine

WORKDIR /srv
RUN npm init -y && npm install pg

COPY --from=build /app/build/web ./web_build
COPY server.js ./server.js
COPY sql ./sql

ENV PORT=8080
EXPOSE 8080

CMD ["node", "server.js"]
