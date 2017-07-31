FROM node:7.10
RUN npm install -g phantomjs
COPY . /app
WORKDIR /app
CMD ["/app/tests.sh"]
