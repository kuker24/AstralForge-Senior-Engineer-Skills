---
name: microservices
description: Design and implement microservices architecture. Use when decomposing monoliths, designing service boundaries, or implementing distributed systems.
---

# Microservices Architecture

## When to Use

- Decomposing monolithic applications
- Designing service boundaries
- Implementing distributed systems
- Planning inter-service communication

## Input

- Business requirements
- Domain models
- Scalability needs

## Output

- Service architecture
- API contracts
- Communication patterns
- Deployment strategy

## Checklist

1. **Service Design**
   - Define service boundaries (DDD)
   - Design API contracts
   - Plan data ownership
   - Identify shared services

2. **Communication**
   - Synchronous: REST, gRPC
   - Asynchronous: Message queues
   - Event-driven: Event bus
   - API Gateway

3. **Data Management**
   - Database per service
   - Saga pattern for transactions
   - Event sourcing
   - CQRS

4. **Resilience**
   - Circuit breaker
   - Retry with backoff
   - Bulkhead pattern
   - Timeout handling

## Best Practices

- Single responsibility per service
- API-first design
- Database per service
- Implement circuit breakers
- Use message queues for async
- Centralized logging
- Health checks for all services

## Anti-Patterns

❌ Distributed monolith
❌ Shared database
❌ Synchronous chains
❌ No circuit breakers
❌ Tightly coupled services
❌ No service discovery

## Validation

- Services are independently deployable
- API contracts are clear
- Communication is resilient
- Monitoring covers all services
- Failures are isolated

## Examples

### Example 1: Service Structure
```
microservices/
├── api-gateway/
│   ├── src/
│   │   ├── routes/
│   │   ├── middleware/
│   │   └── index.ts
│   └── package.json
├── user-service/
│   ├── src/
│   │   ├── controllers/
│   │   ├── services/
│   │   ├── models/
│   │   └── index.ts
│   └── package.json
├── order-service/
│   ├── src/
│   │   ├── controllers/
│   │   ├── services/
│   │   ├── models/
│   │   └── index.ts
│   └── package.json
├── notification-service/
│   ├── src/
│   │   ├── handlers/
│   │   ├── templates/
│   │   └── index.ts
│   └── package.json
└── docker-compose.yml
```

### Example 2: API Gateway
```typescript
// api-gateway/src/index.ts
import express from 'express';
import { createProxyMiddleware } from 'http-proxy-middleware';
import { rateLimit } from 'express-rate-limit';
import { authMiddleware } from './middleware/auth';

const app = express();

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
});

app.use(limiter);

// Authentication
app.use(authMiddleware);

// Service routes
app.use('/api/users', createProxyMiddleware({
  target: process.env.USER_SERVICE_URL,
  changeOrigin: true,
  pathRewrite: { '^/api/users': '/users' },
}));

app.use('/api/orders', createProxyMiddleware({
  target: process.env.ORDER_SERVICE_URL,
  changeOrigin: true,
  pathRewrite: { '^/api/orders': '/orders' },
}));

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.listen(3000);
```

### Example 3: Circuit Breaker
```typescript
// lib/circuitBreaker.ts
export class CircuitBreaker {
  private failures = 0;
  private lastFailure = 0;
  private state: 'closed' | 'open' | 'half-open' = 'closed';
  
  constructor(
    private threshold: number = 5,
    private timeout: number = 60000
  ) {}

  async execute<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === 'open') {
      if (Date.now() - this.lastFailure > this.timeout) {
        this.state = 'half-open';
      } else {
        throw new Error('Circuit breaker is open');
      }
    }

    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  private onSuccess() {
    this.failures = 0;
    this.state = 'closed';
  }

  private onFailure() {
    this.failures++;
    this.lastFailure = Date.now();
    
    if (this.failures >= this.threshold) {
      this.state = 'open';
    }
  }
}

// Usage
const breaker = new CircuitBreaker(5, 60000);

const result = await breaker.execute(async () => {
  return await fetch('http://user-service/users/123');
});
```

### Example 4: Event-Driven Communication
```typescript
// lib/eventBus.ts
import { EventEmitter } from 'events';
import Redis from 'ioredis';

const pub = new Redis(process.env.REDIS_URL);
const sub = new Redis(process.env.REDIS_URL);

class EventBus extends EventEmitter {
  async publish(event: string, data: any) {
    const message = JSON.stringify({ event, data, timestamp: Date.now() });
    await pub.publish('events', message);
    this.emit(event, data);
  }

  subscribe(event: string, handler: (data: any) => void) {
    sub.subscribe('events');
    sub.on('message', (channel, message) => {
      const parsed = JSON.parse(message);
      if (parsed.event === event) {
        handler(parsed.data);
      }
    });
    this.on(event, handler);
  }
}

export const eventBus = new EventBus();

// Usage - Order Service
eventBus.subscribe('order.created', async (order) => {
  await sendOrderConfirmation(order);
  await updateInventory(order.items);
});

// Usage - Notification Service
eventBus.subscribe('order.created', async (order) => {
  await sendEmail(order.userEmail, 'Order Confirmed', order);
});
```

### Example 5: Saga Pattern
```typescript
// lib/saga.ts
export class Saga {
  private steps: Array<{
    execute: () => Promise<void>;
    compensate: () => Promise<void>;
  }> = [];
  
  addStep(
    execute: () => Promise<void>,
    compensate: () => Promise<void>
  ) {
    this.steps.push({ execute, compensate });
    return this;
  }

  async run() {
    const completed: number[] = [];

    try {
      for (let i = 0; i < this.steps.length; i++) {
        await this.steps[i].execute();
        completed.push(i);
      }
    } catch (error) {
      // Compensate in reverse order
      for (let i = completed.length - 1; i >= 0; i--) {
        await this.steps[i].compensate();
      }
      throw error;
    }
  }
}

// Usage
const saga = new Saga()
  .addStep(
    () => createOrder(orderData),
    () => cancelOrder(orderId)
  )
  .addStep(
    () => reserveInventory(items),
    () => releaseInventory(items)
  )
  .addStep(
    () => processPayment(payment),
    () => refundPayment(paymentId)
  );

await saga.run();
```

## Communication Patterns

| Pattern | Use Case | Example |
|---------|----------|---------|
| REST | Synchronous queries | GET /users/123 |
| gRPC | High-performance RPC | Internal service calls |
| Message Queue | Async tasks | Email sending |
| Event Bus | Event-driven | Order created event |
| WebSocket | Real-time | Live updates |

## Output Structure

```
├── api-gateway/           # API Gateway service
├── services/
│   ├── user-service/      # User management
│   ├── order-service/     # Order processing
│   ├── payment-service/   # Payment handling
│   └── notification-service/ # Notifications
├── shared/
│   ├── events/            # Event definitions
│   ├── types/             # Shared types
│   └── utils/             # Shared utilities
├── infrastructure/
│   ├── docker-compose.yml
│   └── k8s/               # Kubernetes manifests
└── docs/
    └── architecture.md
```
