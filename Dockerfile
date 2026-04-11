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
ENV RESEND_API_KEY=re_fWjzK4Q1_AtoGav1wudCCgUvLiTyr3kDY
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
ENV SENDER_EMAIL=info@jdlab.us
ENV ENCRYPTION_KEY=build_placeholder_min_32_chars_long_1234567890
# Override NODE_OPTIONS from .env — --inspect must not run in production/build
ENV NODE_OPTIONS=""

ARG NEXT_PUBLIC_APP_NAME="Prostore"
ARG NEXT_PUBLIC_APP_DESCRIPTION="A modern ecommerce store built with Next.js"
ARG NEXT_PUBLIC_SERVER_URL="http://localhost:3000"
ARG NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=""
ARG PORTAL_JWT_SECRET

ENV NEXT_PUBLIC_APP_NAME=$NEXT_PUBLIC_APP_NAME
ENV NEXT_PUBLIC_APP_DESCRIPTION=$NEXT_PUBLIC_APP_DESCRIPTION
ENV NEXT_PUBLIC_SERVER_URL=$NEXT_PUBLIC_SERVER_URL
ENV NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=$NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY
ENV PORTAL_JWT_SECRET=$PORTAL_JWT_SECRET

RUN npm run build

FROM node:20-alpine AS runner
RUN apk add --no-cache openssl
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME=0.0.0.0
ENV NODE_OPTIONS=""

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Next.js standalone output + static assets
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Prisma: generated client (for runtime queries)
COPY --from=builder --chown=nextjs:nodejs /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder --chown=nextjs:nodejs /app/node_modules/@prisma ./node_modules/@prisma

USER nextjs

EXPOSE 3000

CMD ["node", "server.js"]
