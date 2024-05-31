FROM node:21-alpine as base

# WORKDIR /app

# COPY . .

# RUN npm i

# FROM node:21-alpine

# WORKDIR /app
# COPY --from=build /app .

# RUN node ace
# RUN node ace migration:run; exit 0
# CMD ["yarn", "start"]

RUN apk --no-cache add dumb-init
RUN mkdir -p /app
WORKDIR /app
RUN mkdir tmp

FROM base AS dependencies

COPY ./package.json ./
RUN npm i 
COPY . .

FROM dependencies AS build

RUN node ace build

FROM build AS production

COPY ./package.json ./
# je sais que dans les dépendances il y a déjà ts-node mais les logs de mon container me montrent
#un type ts inconnu, donc j'essaie des trucs
RUN npm i --omit=dev && npm install typescript -g 
COPY --from=build /app/build .
CMD ["node", "ace", "migration:run", "--force", "&&", "dumb-init", "yarn","start"]
# CMD [ "dumb-init", "node", "server.js" ]