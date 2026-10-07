# --- Etapa 1: Compilación ---
FROM node:24 AS construccion

WORKDIR /usr/app

COPY package.json ./
RUN npm install

COPY nest-cli.json tsconfig*.json ./
COPY src ./src

RUN npm run build

# --- Etapa 2: Dependencias de Producción ---
FROM node:24 AS dependencias-produccion

WORKDIR /usr/app

COPY package.json ./
RUN npm install --only=production

# --- Etapa 3: Imagen Final (Runner) ---
FROM node:24-alpine AS runner

WORKDIR /usr/app

ENV NODE_ENV=produccion

COPY --from=construccion /usr/app/package.json ./
COPY --from=construccion /usr/app/dist ./dist
COPY --from=dependencias-produccion /usr/app/node_modules ./node_modules

EXPOSE 3000

CMD ["node", "dist/main.js"]
