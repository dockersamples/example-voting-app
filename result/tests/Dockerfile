FROM node:6.11
RUN npm install -g phantomjs
COPY . /app
WORKDIR /app
CMD ["/app/tests.sh"]
