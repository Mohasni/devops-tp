FROM node:18
WORKDIR /app
COPY package.json ./
COPY server.js ./
COPY src ./src
COPY tests ./tests
RUN npm install
EXPOSE 3000
CMD ["npm", "start"]