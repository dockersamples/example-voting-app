FROM node:8.9-alpine

RUN mkdir -p /app
WORKDIR /app

RUN npm config set unsafe-perm true
RUN npm config set registry https://registry.npmjs.org
RUN npm install -g nodemon

COPY package.json /app/package.json
RUN npm install \
 && npm ls \
 && npm cache clean --force \
 && mv /app/node_modules /node_modules
COPY . /app

ENV PORT 80
EXPOSE 80

CMD ["node", "server.js"]
