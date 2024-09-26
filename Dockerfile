FROM node:7
ADD app.js /app.js
ENTRYPOINT ["node", "app.js"]
