---
name: message-queue
description: Implement message queues with RabbitMQ or Kafka for async processing. Use when building event-driven systems, background jobs, or microservice communication.
---

# Message Queue (RabbitMQ/Kafka)

## When to Use

- Background job processing
- Event-driven architecture
- Microservice communication
- Async task handling
- Decoupling services

## Input

- Message requirements
- Processing patterns
- Scaling needs

## Output

- Queue configuration
- Producer implementation
- Consumer implementation
- Error handling
- Monitoring setup

## Checklist

1. **Choose Technology**
   - RabbitMQ: traditional message broker, AMQP
   - Kafka: distributed streaming, high throughput
   - Consider: message ordering, persistence, replay

2. **Producer Setup**
   - Configure connection
   - Implement retry logic
   - Add message validation
   - Handle publish failures

3. **Consumer Setup**
   - Configure prefetch/concurrency
   - Implement idempotency
   - Handle poison messages
   - Set up dead letter queue

4. **Reliability**
   - Enable message acknowledgment
   - Implement dead letter queue
   - Add monitoring and alerting
   - Test failure scenarios

## Best Practices

- Make consumers idempotent
- Use dead letter queues
- Implement retry with backoff
- Monitor queue depth
- Use message validation
- Implement circuit breakers
- Log all message operations

## Anti-Patterns

❌ Non-idempotent consumers
❌ No dead letter queue
❌ Unbounded retries
❌ No message validation
❌ Ignoring message ordering
❌ No monitoring

## Validation

- Messages are published correctly
- Consumers process messages
- Dead letter queue captures failures
- Retry logic works
- Monitoring shows queue health

## Examples

### Example 1: RabbitMQ Producer
```typescript
// lib/queue/producer.ts
import amqplib from 'amqplib';

let channel: amqplib.Channel;

export async function connectQueue() {
  const connection = await amqplib.connect(process.env.RABBITMQ_URL!);
  channel = await connection.createChannel();
  
  // Assert queues
  await channel.assertQueue('tasks', { durable: true });
  await channel.assertQueue('tasks.deadletter', { durable: true });
  
  return channel;
}

export async function publishMessage<T>(
  queue: string,
  message: T,
  options: amqplib.Options.Publish = {}
) {
  const content = Buffer.from(JSON.stringify(message));
  
  channel.sendToQueue(queue, content, {
    persistent: true,
    timestamp: Date.now(),
    ...options,
  });
  
  console.log(`Published message to ${queue}`);
}

// Usage
await publishMessage('tasks', {
  type: 'SEND_EMAIL',
  payload: { to: 'user@example.com', subject: 'Welcome' },
});
```

### Example 2: RabbitMQ Consumer
```typescript
// lib/queue/consumer.ts
import amqplib from 'amqplib';

export async function consumeMessages(
  queue: string,
  handler: (message: any) => Promise<void>
) {
  const connection = await amqplib.connect(process.env.RABBITMQ_URL!);
  const channel = await connection.createChannel();
  
  await channel.assertQueue(queue, { durable: true });
  await channel.prefetch(1); // Process one message at a time
  
  console.log(`Waiting for messages in ${queue}`);
  
  channel.consume(queue, async (msg) => {
    if (!msg) return;
    
    try {
      const content = JSON.parse(msg.content.toString());
      console.log('Processing message:', content);
      
      await handler(content);
      
      // Acknowledge successful processing
      channel.ack(msg);
    } catch (error) {
      console.error('Error processing message:', error);
      
      // Reject and requeue (with limit)
      const retryCount = (msg.properties.headers?.['x-retry-count'] || 0) + 1;
      
      if (retryCount < 3) {
        // Requeue with retry count
        channel.nack(msg, false, false);
        await publishMessage(queue, JSON.parse(msg.content.toString()), {
          headers: { 'x-retry-count': retryCount },
        });
      } else {
        // Send to dead letter queue
        channel.ack(msg);
        await publishMessage('tasks.deadletter', {
          originalMessage: JSON.parse(msg.content.toString()),
          error: error.message,
          failedAt: new Date(),
        });
      }
    }
  });
}
```

### Example 3: Kafka Producer
```typescript
// lib/kafka/producer.ts
import { Kafka, Partitioners } from 'kafkajs';

const kafka = new Kafka({
  clientId: 'my-app',
  brokers: [process.env.KAFKA_BROKER!],
});

const producer = kafka.producer({
  createPartitioner: Partitioners.DefaultPartitioner,
});

export async function connectProducer() {
  await producer.connect();
}

export async function publishMessage<T>(
  topic: string,
  message: T,
  key?: string
) {
  await producer.send({
    topic,
    messages: [
      {
        key: key || null,
        value: JSON.stringify(message),
        timestamp: Date.now().toString(),
      },
    ],
  });
  
  console.log(`Published message to ${topic}`);
}
```

### Example 4: Kafka Consumer
```typescript
// lib/kafka/consumer.ts
import { Kafka } from 'kafkajs';

const kafka = new Kafka({
  clientId: 'my-app',
  brokers: [process.env.KAFKA_BROKER!],
});

export async function consumeMessages(
  topic: string,
  groupId: string,
  handler: (message: any) => Promise<void>
) {
  const consumer = kafka.consumer({ groupId });
  
  await consumer.connect();
  await consumer.subscribe({ topic, fromBeginning: false });
  
  await consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      try {
        const content = JSON.parse(message.value!.toString());
        console.log(`Processing message from ${topic}[${partition}]:`, content);
        
        await handler(content);
      } catch (error) {
        console.error('Error processing message:', error);
        // Handle error - send to DLQ or retry
      }
    },
  });
}
```

### Example 5: Idempotent Consumer
```typescript
// lib/queue/idempotent.ts
import Redis from 'ioredis';

const redis = new Redis(process.env.REDIS_URL!);

export async function isIdempotent(messageId: string): Promise<boolean> {
  const key = `msg:${messageId}`;
  const exists = await redis.exists(key);
  
  if (exists) {
    console.log(`Message ${messageId} already processed`);
    return false;
  }
  
  // Mark as processed (expire after 24 hours)
  await redis.set(key, '1', 'EX', 86400);
  return true;
}

// Usage in consumer
async function handleMessage(message: any) {
  if (!await isIdempotent(message.id)) {
    return; // Skip duplicate
  }
  
  // Process message
  await processMessage(message);
}
```

## RabbitMQ vs Kafka

| Aspect | RabbitMQ | Kafka |
|--------|----------|-------|
| Model | Message broker | Distributed log |
| Ordering | Per-queue | Per-partition |
| Replay | No | Yes |
| Throughput | Moderate | High |
| Use Case | Task queues | Event streaming |

## Output Structure

```
├── lib/
│   ├── queue/
│   │   ├── producer.ts      # Message producer
│   │   ├── consumer.ts      # Message consumer
│   │   ├── idempotent.ts    # Idempotency check
│   │   └── config.ts        # Queue configuration
│   └── kafka/
│       ├── producer.ts      # Kafka producer
│       └── consumer.ts      # Kafka consumer
├── handlers/
│   └── tasks.ts             # Task handlers
└── monitoring/
    └── queue-metrics.ts     # Queue monitoring
```
