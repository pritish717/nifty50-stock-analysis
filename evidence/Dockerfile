FROM node:18-slim

WORKDIR /app

COPY ./package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

ENTRYPOINT ["sh", "-c", "npm run sources && npm run dev -- --host 0.0.0.0"]
