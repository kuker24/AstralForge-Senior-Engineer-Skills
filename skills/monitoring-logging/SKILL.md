---
name: monitoring-logging
description: Implement monitoring, logging, and observability. Use when setting up structured logging, metrics, tracing, or alerting systems.
---

# Monitoring & Logging

## When to Use

- Setting up structured logging
- Implementing metrics collection
- Adding distributed tracing
- Configuring alerting
- Debugging production issues

## Input

- Application architecture
- Monitoring requirements
- Alert thresholds

## Output

- Structured logging configuration
- Metrics collection
- Distributed tracing
- Alert rules
- Dashboards

## Checklist

1. **Structured Logging**
   - Use JSON format
   - Add correlation IDs
   - Include context (user, request, etc.)
   - Set appropriate log levels

2. **Metrics**
   - Define key metrics (latency, errors, throughput)
   - Use Prometheus client
   - Create custom metrics
   - Set up dashboards

3. **Tracing**
   - Implement OpenTelemetry
   - Add span context
   - Trace across services
   - Sample appropriately

4. **Alerting**
   - Define alert thresholds
   - Set up notification channels
   - Create runbooks
   - Test alerts

## Best Practices

- Use structured JSON logs
- Add correlation IDs everywhere
- Don't log sensitive data
- Use appropriate log levels
- Implement health checks
- Monitor error rates
- Create actionable alerts

## Anti-Patterns

❌ Logging PII/secrets
❌ Unstructured logs
❌ No correlation IDs
❌ Too many alerts (alert fatigue)
❌ No health checks
❌ Ignoring log levels

## Validation

- Logs are structured JSON
- Correlation IDs propagate
- Metrics are collected
- Traces show request flow
- Alerts fire correctly

## Examples

### Example 1: Structured Logging
```typescript
// lib/logger.ts
import pino from 'pino';

export const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  formatters: {
    level: (label) => ({ level: label }),
  },
  timestamp: pino.stdTimeFunctions.isoTime,
  serializers: {
    err: pino.stdSerializers.err,
    req: pino.stdSerializers.req,
    res: pino.stdSerializers.res,
  },
});

// Middleware for request logging
export function requestLogger() {
  return async (req: Request, res: Response, next: NextFunction) => {
    const start = Date.now();
    const correlationId = req.headers['x-correlation-id'] || crypto.randomUUID();
    
    // Add correlation ID to request
    req.correlationId = correlationId;
    res.setHeader('x-correlation-id', correlationId);
    
    // Log request
    logger.info({
      type: 'request',
      method: req.method,
      url: req.url,
      correlationId,
      userAgent: req.headers['user-agent'],
    });
    
    // Log response
    res.on('finish', () => {
      const duration = Date.now() - start;
      
      logger.info({
        type: 'response',
        method: req.method,
        url: req.url,
        statusCode: res.statusCode,
        duration,
        correlationId,
      });
    });
    
    next();
  };
}
```

### Example 2: Metrics with Prometheus
```typescript
// lib/metrics.ts
import { Registry, Counter, Histogram, Gauge } from 'prom-client';

export const registry = new Registry();

// Request counter
export const httpRequestCounter = new Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'path', 'status'],
  registers: [registry],
});

// Request duration histogram
export const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'path'],
  buckets: [0.01, 0.05, 0.1, 0.5, 1, 5],
  registers: [registry],
});

// Active connections gauge
export const activeConnections = new Gauge({
  name: 'active_connections',
  help: 'Number of active connections',
  registers: [registry],
});

// Business metrics
export const ordersCounter = new Counter({
  name: 'orders_total',
  help: 'Total number of orders',
  labelNames: ['status'],
  registers: [registry],
});

// Middleware to collect metrics
export function metricsMiddleware() {
  return async (req: Request, res: Response, next: NextFunction) => {
    const start = Date.now();
    
    activeConnections.inc();
    
    res.on('finish', () => {
      const duration = (Date.now() - start) / 1000;
      
      httpRequestCounter.inc({
        method: req.method,
        path: req.route?.path || req.url,
        status: res.statusCode,
      });
      
      httpRequestDuration.observe(
        { method: req.method, path: req.route?.path || req.url },
        duration
      );
      
      activeConnections.dec();
    });
    
    next();
  };
}
```

### Example 3: Distributed Tracing with OpenTelemetry
```typescript
// tracing.ts
import { NodeSDK } from '@opentelemetry/sdk-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
import { OTLPMetricExporter } from '@opentelemetry/exporter-metrics-otlp-http';
import { PeriodicExportingMetricReader } from '@opentelemetry/sdk-metrics';
import { HttpInstrumentation } from '@opentelemetry/instrumentation-http';
import { ExpressInstrumentation } from '@opentelemetry/instrumentation-express';
import { PrismaInstrumentation } from '@prisma/instrumentation';

const sdk = new NodeSDK({
  serviceName: 'my-service',
  traceExporter: new OTLPTraceExporter({
    url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT,
  }),
  metricReader: new PeriodicExportingMetricReader({
    exporter: new OTLPMetricExporter({
      url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT,
    }),
  }),
  instrumentations: [
    new HttpInstrumentation(),
    new ExpressInstrumentation(),
    new PrismaInstrumentation(),
  ],
});

sdk.start();
```

### Example 4: Health Check
```typescript
// routes/health.ts
import { Router } from 'express';
import { prisma } from '../lib/db';
import { redis } from '../lib/cache';

const router = Router();

router.get('/health', async (req, res) => {
  const checks = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    services: {
      database: await checkDatabase(),
      redis: await checkRedis(),
    },
  };

  const isHealthy = Object.values(checks.services).every(
    (service) => service.status === 'healthy'
  );

  res.status(isHealthy ? 200 : 503).json(checks);
});

async function checkDatabase() {
  try {
    await prisma.$queryRaw`SELECT 1`;
    return { status: 'healthy', latency: Date.now() };
  } catch (error) {
    return { status: 'unhealthy', error: error.message };
  }
}

async function checkRedis() {
  try {
    const start = Date.now();
    await redis.ping();
    return { status: 'healthy', latency: Date.now() - start };
  } catch (error) {
    return { status: 'unhealthy', error: error.message };
  }
}

export default router;
```

### Example 5: Error Tracking with Sentry
```typescript
// lib/sentry.ts
import * as Sentry from '@sentry/node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 0.1,
  integrations: [
    new Sentry.Integrations.Http({ tracing: true }),
    new Sentry.Integrations.Express(),
  ],
});

// Error handler middleware
export function errorHandler() {
  return (err: Error, req: Request, res: Response, next: NextFunction) => {
    Sentry.withScope((scope) => {
      scope.setTag('url', req.url);
      scope.setTag('method', req.method);
      scope.setUser({ id: req.user?.id });
      Sentry.captureException(err);
    });
    
    logger.error({ err, req: pino.stdSerializers.req(req) });
    
    res.status(500).json({
      error: 'Internal server error',
      requestId: req.correlationId,
    });
  };
}
```

## Log Structure

```json
{
  "level": "info",
  "time": "2026-05-24T10:30:00.000Z",
  "type": "response",
  "method": "GET",
  "url": "/api/users",
  "statusCode": 200,
  "duration": 45,
  "correlationId": "abc-123",
  "service": "user-service",
  "environment": "production"
}
```

## Alert Thresholds

| Metric | Warning | Critical |
|--------|---------|----------|
| Error Rate | > 1% | > 5% |
| Latency P95 | > 500ms | > 2s |
| CPU Usage | > 70% | > 90% |
| Memory Usage | > 80% | > 95% |
| Disk Usage | > 70% | > 90% |

## Output Structure

```
├── lib/
│   ├── logger.ts          # Structured logging
│   ├── metrics.ts         # Prometheus metrics
│   ├── sentry.ts          # Error tracking
│   └── tracing.ts         # OpenTelemetry
├── middleware/
│   ├── requestLogger.ts   # Request logging
│   └── metricsMiddleware.ts
├── routes/
│   └── health.ts          # Health checks
├── dashboards/
│   └── grafana.json       # Grafana dashboard
└── alerts/
    └── rules.yml          # Alert rules
```
