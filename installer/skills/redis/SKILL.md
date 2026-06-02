---
name: redis
description: Use Redis for caching, session management, and real-time features. Use when implementing caching strategies, rate limiting, pub/sub, or distributed locks.
---

# Redis

## When to Use

- Implementing caching layer
- Session storage
- Rate limiting
- Pub/Sub messaging
- Distributed locks
- Leaderboards and counters

## Input

- Caching requirements
- Data access patterns
- TTL requirements

## Output

- Redis configuration
- Caching strategies
- Session management
- Rate limiting implementation

## Checklist

1. **Setup**
   - Install Redis client (ioredis)
   - Configure connection
   - Set up connection pooling
   - Handle reconnection

2. **Caching Strategy**
   - Define cache keys (namespaced)
   - Set appropriate TTLs
   - Implement cache invalidation
   - Use cache-aside pattern

3. **Session Management**
   - Configure session store
   - Set session TTL
   - Handle session serialization
   - Implement session cleanup

4. **Rate Limiting**
   - Define rate limits
   - Use sliding window
   - Handle rate limit exceeded
   - Return proper headers

## Best Practices

- Namespace all keys
- Set TTL on all keys
- Use connection pooling
- Implement cache invalidation
- Use pipelines for batch operations
- Monitor memory usage
- Use Redis Cluster for scaling

## Anti-Patterns

❌ Keys without namespace
❌ No TTL on keys
❌ Cache without invalidation strategy
❌ Storing large objects
❌ No connection pooling
❌ Not handling connection errors

## Validation

- Cache returns correct data
- TTLs expire correctly
- Rate limiting works
- Sessions persist across requests
- Connection errors handled gracefully

## Examples

### Example 1: Caching with TTL
```typescript
// lib/cache.ts
import Redis from 'ioredis';

const redis = new Redis(process.env.REDIS_URL);

export async function getCache<T>(key: string): Promise<T | null> {
  const data = await redis.get(key);
  return data ? JSON.parse(data) : null;
}

export async function setCache<T>(
  key: string,
  value: T,
  ttlSeconds: number = 3600
): Promise<void> {
  await redis.set(key, JSON.stringify(value), 'EX', ttlSeconds);
}

export async function deleteCache(key: string): Promise<void> {
  await redis.del(key);
}

export async function invalidatePattern(pattern: string): Promise<void> {
  const keys = await redis.keys(pattern);
  if (keys.length > 0) {
    await redis.del(...keys);
  }
}

// Namespaced keys
export const cacheKeys = {
  user: (id: string) => `user:${id}`,
  users: (page: number) => `users:page:${page}`,
  session: (id: string) => `session:${id}`,
};
```

### Example 2: Rate Limiting
```typescript
// middleware/rateLimit.ts
import Redis from 'ioredis';

const redis = new Redis(process.env.REDIS_URL);

export function rateLimit(options: {
  windowMs: number;
  max: number;
}) {
  return async (req: Request, res: Response, next: NextFunction) => {
    const key = `rate:${req.ip}:${req.path}`;
    
    const current = await redis.incr(key);
    
    if (current === 1) {
      await redis.expire(key, options.windowMs / 1000);
    }
    
    const ttl = await redis.ttl(key);
    
    res.set({
      'X-RateLimit-Limit': options.max,
      'X-RateLimit-Remaining': Math.max(0, options.max - current),
      'X-RateLimit-Reset': ttl,
    });
    
    if (current > options.max) {
      return res.status(429).json({
        error: 'Too many requests',
        retryAfter: ttl,
      });
    }
    
    next();
  };
}
```

### Example 3: Session Store
```typescript
// lib/session.ts
import session from 'express-session';
import RedisStore from 'connect-redis';
import Redis from 'ioredis';

const redis = new Redis(process.env.REDIS_URL);

export const sessionMiddleware = session({
  store: new RedisStore({ client: redis }),
  secret: process.env.SESSION_SECRET!,
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: process.env.NODE_ENV === 'production',
    httpOnly: true,
    maxAge: 24 * 60 * 60 * 1000, // 1 day
    sameSite: 'lax',
  },
});
```

### Example 4: Pub/Sub
```typescript
// lib/pubsub.ts
import Redis from 'ioredis';

const pub = new Redis(process.env.REDIS_URL);
const sub = new Redis(process.env.REDIS_URL);

export function publish(channel: string, message: any) {
  pub.publish(channel, JSON.stringify(message));
}

export function subscribe(channel: string, callback: (message: any) => void) {
  sub.subscribe(channel);
  sub.on('message', (ch, message) => {
    if (ch === channel) {
      callback(JSON.parse(message));
    }
  });
}

export function unsubscribe(channel: string) {
  sub.unsubscribe(channel);
}
```

### Example 5: Distributed Lock
```typescript
// lib/lock.ts
import Redis from 'ioredis';

const redis = new Redis(process.env.REDIS_URL);

export async function acquireLock(
  key: string,
  ttlMs: number = 30000
): Promise<string | null> {
  const lockKey = `lock:${key}`;
  const lockValue = `${Date.now()}-${Math.random()}`;
  
  const acquired = await redis.set(
    lockKey,
    lockValue,
    'PX',
    ttlMs,
    'NX'
  );
  
  return acquired ? lockValue : null;
}

export async function releaseLock(
  key: string,
  lockValue: string
): Promise<boolean> {
  const lockKey = `lock:${key}`;
  
  const script = `
    if redis.call("get", KEYS[1]) == ARGV[1] then
      return redis.call("del", KEYS[1])
    else
      return 0
    end
  `;
  
  const result = await redis.eval(script, 1, lockKey, lockValue);
  return result === 1;
}
```

## Cache Invalidation Checklist

- [ ] Define invalidation strategy (TTL, event-based, manual)
- [ ] Invalidate on write operations
- [ ] Use cache tags for related data
- [ ] Monitor cache hit/miss ratio
- [ ] Set appropriate TTLs per data type
- [ ] Handle cache stampede

## Output Structure

```
├── lib/
│   ├── cache.ts           # Cache utilities
│   ├── session.ts         # Session store
│   ├── pubsub.ts          # Pub/Sub
│   ├── lock.ts            # Distributed locks
│   └── rateLimit.ts       # Rate limiting
├── middleware/
│   └── rateLimit.ts       # Rate limit middleware
└── config/
    └── redis.ts           # Redis configuration
```
