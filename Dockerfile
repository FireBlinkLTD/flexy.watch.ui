FROM node:10.16.3 as build

WORKDIR /app

COPY package.json yarn.lock ./

RUN yarn install

COPY src ./src
COPY angular.json ./
COPY tsconfig.json ./
COPY tsconfig.app.json ./

RUN yarn build:production

FROM nginx:alpine

EXPOSE 80

COPY --from=build /app/dist /usr/share/nginx/html
COPY docker/start.sh /etc/nginx/start.sh

CMD ["sh", "/etc/nginx/start.sh"]
