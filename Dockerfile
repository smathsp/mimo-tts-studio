FROM node:22-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:22-alpine AS runtime
WORKDIR /app
COPY --from=builder /app/build/server/index.cjs ./server.cjs
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json /app/package-lock.json ./
RUN npm ci --omit=dev

ENV MIMO_STATIC_DIR=/app/dist
ENV MIMO_DATA_DIR=/app/data
ENV PORT=3001

VOLUME /app/data
EXPOSE 3001

CMD ["node", "server.cjs"]
