FROM node:6.11.0
RUN npm install -g phantomjs
ADD . /app
WORKDIR /app
CMD ["/app/tests.sh"]
