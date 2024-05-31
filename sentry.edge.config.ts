import * as Sentry from '@sentry/nextjs'
import { APP_RELEASE } from './src/types/constants'

Sentry.init({
  enabled: process.env.NODE_ENV === 'production',
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  release: APP_RELEASE,
  tracesSampleRate: 1,
  debug: false
})
