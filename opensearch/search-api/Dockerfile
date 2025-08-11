FROM node:18-alpine

WORKDIR /usr/src/app

# copy package first to leverage layer caching
COPY package.json package-lock.json* ./

RUN npm install --omit=dev

COPY . .

EXPOSE 3000

CMD ["node", "index.js"]
