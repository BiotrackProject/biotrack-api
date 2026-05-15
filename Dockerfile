# ─── Stage 1: Build ──────────────────────────────────────────────────────────
FROM node:24-alpine AS builder
WORKDIR /app

# Instalar dependencias primero (aprovecha caché de Docker si package.json no cambia)
COPY package*.json ./
RUN npm ci

# Copiar fuentes y compilar
COPY tsconfig.json ./
COPY prisma ./prisma
COPY src ./src

# Generar cliente Prisma + compilar TypeScript
RUN npx prisma generate && npm run build

# Eliminar devDependencies (la imagen final solo lleva producción)
RUN npm prune --omit=dev

# ─── Stage 2: Runner de producción ───────────────────────────────────────────
FROM node:24-alpine AS runner
LABEL org.opencontainers.image.title="BIOTRACK API"
LABEL org.opencontainers.image.description="API REST — Gestión de minería ilegal de arena · INTEC IDS355"
LABEL org.opencontainers.image.source="https://github.com/Albert2707/biotrack-api"

ENV NODE_ENV=production
WORKDIR /app

# Usuario sin privilegios (principio de mínimo privilegio)
RUN addgroup -g 1001 -S biotrack && adduser -u 1001 -S biotrack -G biotrack

# Copiar artefactos desde el builder
COPY --from=builder --chown=biotrack:biotrack /app/node_modules ./node_modules
COPY --from=builder --chown=biotrack:biotrack /app/dist        ./dist
COPY --from=builder --chown=biotrack:biotrack /app/prisma      ./prisma
COPY --from=builder --chown=biotrack:biotrack /app/package.json ./package.json

# Directorio de uploads con permisos correctos
RUN mkdir -p uploads && chown biotrack:biotrack uploads

USER biotrack

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "dist/server.js"]
