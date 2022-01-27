FROM node:16.13.2-alpine3.15

WORKDIR /app

RUN addgroup -S result && adduser -S result -G result

RUN npm install -g nodemon

COPY package*.json ./

RUN npm install \
 && npm cache clean --force \
 && mv /app/node_modules /node_modules

COPY server.js .
COPY views/ .

EXPOSE 80

USER result:result

CMD ["node", "server.js"]
