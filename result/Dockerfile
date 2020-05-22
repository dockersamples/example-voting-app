FROM node:10-slim

WORKDIR /app

RUN npm install -g nodemon
ADD package*.json /app/

#RUN npm config set registry http://registry.npmjs.org
#RUN npm install && npm ls

RUN npm ci \
 && npm cache clean --force \
 && mv /app/node_modules /node_modules


ADD . /app

ENV PORT 80
EXPOSE 80

CMD ["node", "server.js"]

