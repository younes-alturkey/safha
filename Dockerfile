FROM node:18-alpine AS builder
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json yarn.lock ./ 
RUN yarn install --frozen-lockfile

COPY . .

ARG API_URL
ARG NEXTAUTH_URL=http://localhost:3000
ARG NEXTAUTH_SECRET
ARG BUCKET_URL
ARG USERS_ASSETS_BUCKET_NAME
ARG OPENAI_API_KEY
ARG OPENAI_ORG_ID
ARG OPENAI_SAFHAGPT_ASSISTANT_ID
ARG UNSPLASH_ACCESS_KEY
ARG MIXPANEL_PROJECT_TOKEN
ARG GOOGLE_ANALYTICS_MEASUREMENT_ID
ARG GOOGLE_ANALYTICS_STREAM_ID
ARG SENTRY_AUTH_TOKEN=
ARG NEXT_PUBLIC_SENTRY_DSN=
ARG SENTRY_ORG=safha
ARG SENTRY_PROJECT=
ARG GCP_CREDENTIALS_BASE64
ARG GCP_PROJECT_ID
ARG SENDGRID_API_KEY

ENV BUILD_STANDALONE=true 
ENV API_URL=$API_URL 
ENV NEXTAUTH_URL=$NEXTAUTH_URL 
ENV NEXTAUTH_SECRET=$NEXTAUTH_SECRET 
ENV BUCKET_URL=$BUCKET_URL 
ENV USERS_ASSETS_BUCKET_NAME=$USERS_ASSETS_BUCKET_NAME 
ENV OPENAI_API_KEY=$OPENAI_API_KEY 
ENV OPENAI_ORG_ID=$OPENAI_ORG_ID 
ENV OPENAI_SAFHAGPT_ASSISTANT_ID=$OPENAI_SAFHAGPT_ASSISTANT_ID 
ENV UNSPLASH_ACCESS_KEY=$UNSPLASH_ACCESS_KEY 
ENV MIXPANEL_PROJECT_TOKEN=$MIXPANEL_PROJECT_TOKEN 
ENV GOOGLE_ANALYTICS_MEASUREMENT_ID=$GOOGLE_ANALYTICS_MEASUREMENT_ID 
ENV GOOGLE_ANALYTICS_STREAM_ID=$GOOGLE_ANALYTICS_STREAM_ID
ENV SENTRY_AUTH_TOKEN=$SENTRY_AUTH_TOKEN
ENV NEXT_PUBLIC_SENTRY_DSN=$NEXT_PUBLIC_SENTRY_DSN 
ENV SENTRY_ORG=$SENTRY_ORG 
ENV SENTRY_PROJECT=$SENTRY_PROJECT
ENV GCP_CREDENTIALS_BASE64=$GCP_CREDENTIALS_BASE64 
ENV GCP_PROJECT_ID=$GCP_PROJECT_ID
ENV SENDGRID_API_KEY=$SENDGRID_API_KEY

RUN yarn build

FROM node:18-alpine AS runner
WORKDIR /app

ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/package.json ./package.json

COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000

CMD ["node", "server.js"]
