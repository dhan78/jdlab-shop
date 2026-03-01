FROM node:20-alpine AS deps
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci --ignore-scripts

FROM node:20-alpine AS builder
RUN apk add --no-cache libc6-compat openssl
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npx prisma generate

# Provide dummy server-side secrets so Next.js page-data collection doesn't crash.
# Real values are injected at runtime via env_file / environment.
ENV RESEND_API_KEY=build_placeholder
ENV STRIPE_SECRET_KEY=build_placeholder
ENV STRIPE_WEBHOOK_SECRET=build_placeholder
ENV NEXTAUTH_SECRET=build_placeholder
ENV NEXTAUTH_URL=http://localhost:3000
ENV DATABASE_URL=postgresql://placeholder:placeholder@localhost:5432/placeholder
ENV PAYMENT_METHODS="PayPal, Stripe, CashOnDelivery"
ENV DEFAULT_PAYMENT_METHOD=PayPal
ENV PAYPAL_API_URL=https://api-m.sandbox.paypal.com
ENV PAYPAL_CLIENT_ID=build_placeholder
ENV PAYPAL_APP_SECRET=build_placeholder
ENV UPLOADTHING_TOKEN=build_placeholder
ENV UPLOADTHING_SECRET=build_placeholder
ENV UPLOADTHING_APPID=build_placeholder
ENV SENDER_EMAIL=noreply@example.com
ENV ENCRYPTION_KEY=build_placeholder_min_32_chars_long_1234567890
# Override NODE_OPTIONS from .env — --inspect must not run in production/build
ENV NODE_OPTIONS=""

ARG NEXT_PUBLIC_APP_NAME="Prostore"
ARG NEXT_PUBLIC_APP_DESCRIPTION="A modern ecommerce store built with Next.js"
ARG NEXT_PUBLIC_SERVER_URL="http://localhost:3000"
ARG NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=""

ENV NEXT_PUBLIC_APP_NAME=$NEXT_PUBLIC_APP_NAME
ENV NEXT_PUBLIC_APP_DESCRIPTION=$NEXT_PUBLIC_APP_DESCRIPTION
ENV NEXT_PUBLIC_SERVER_URL=$NEXT_PUBLIC_SERVER_URL
ENV NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=$NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY

RUN npm run build

FROM node:20-alpine AS runner
RUN apk add --no-cache libc6-compat openssl
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME=0.0.0.0
ENV RUN_MIGRATIONS=true
ENV NODE_OPTIONS=""

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Copy Prisma schema for migrations
COPY --from=builder /app/prisma ./prisma
# Copy generated Prisma Client (runtime query engine)
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /app/node_modules/@prisma ./node_modules/@prisma
# Install Prisma CLI with all transitive deps for migrate deploy
RUN npm install prisma@6.5.0 --no-save
# Give nextjs user ownership of everything it needs to write to
RUN chown -R nextjs:nodejs /app

USER nextjs

EXPOSE 3000

CMD ["sh", "-c", "if [ \"$RUN_MIGRATIONS\" = \"true\" ]; then npx prisma migrate deploy; fi && node server.js"]
