---
name: full-api-testing
description: Test APIs with contract testing, load testing, and security testing. Use when designing API test strategies, implementing contract tests, or load testing.
---

# Full API Testing

## When to Use

- Designing API test strategies
- Implementing contract testing
- Load testing APIs
- Security testing endpoints

## Input

- API specifications
- Test requirements
- Performance targets

## Output

- Test suites
- Contract tests
- Load test scripts
- Security test results

## Checklist

1. **Contract Testing**
   - Define API contracts
   - Implement Pact tests
   - Verify provider contracts
   - Version contracts

2. **Integration Testing**
   - Test endpoint flows
   - Test error handling
   - Test authentication
   - Test authorization

3. **Load Testing**
   - Define load scenarios
   - Implement k6/Artillery scripts
   - Set performance targets
   - Analyze results

4. **Security Testing**
   - Test authentication
   - Test authorization
   - Test input validation
   - Check for vulnerabilities

## Best Practices

- Test contracts first
- Use realistic test data
- Test error scenarios
- Automate in CI/CD
- Monitor performance trends
- Test security regularly

## Anti-Patterns

❌ Only testing happy path
❌ Not testing contracts
❌ Ignoring security tests
❌ No load testing
❌ Manual testing only

## Validation

- Contract tests pass
- Integration tests pass
- Load tests meet targets
- Security tests pass

## Examples

### Example 1: Contract Testing with Pact
```typescript
// tests/contract/consumer.pact.ts
import { Pact } from '@pact-foundation/pact';
import { createUser, getUser } from '../../src/api/users';

const provider = new Pact({
  consumer: 'UserApp',
  provider: 'UserAPI',
  port: 1234,
});

describe('User API', () => {
  beforeAll(() => provider.setup());
  afterAll(() => provider.finalize());

  describe('get user', () => {
    beforeEach(() => {
      return provider.addInteraction({
        state: 'user 123 exists',
        uponReceiving: 'a request for user 123',
        withRequest: {
          method: 'GET',
          path: '/api/users/123',
        },
        willRespondWith: {
          status: 200,
          headers: { 'Content-Type': 'application/json' },
          body: {
            id: '123',
            name: 'John Doe',
            email: 'john@example.com',
          },
        },
      });
    });

    it('returns user', async () => {
      const user = await getUser('123');
      expect(user.name).toBe('John Doe');
    });
  });
});
```

### Example 2: Load Testing with k6
```javascript
// tests/load/api.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '1m', target: 100 },
    { duration: '3m', target: 100 },
    { duration: '1m', target: 200 },
    { duration: '3m', target: 200 },
    { duration: '1m', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'],
    http_req_failed: ['rate<0.01'],
    http_reqs: ['rate>100'],
  },
};

export default function () {
  const baseUrl = 'http://localhost:3000/api';
  
  // Get users
  const usersRes = http.get(`${baseUrl}/users`);
  check(usersRes, {
    'users status is 200': (r) => r.status === 200,
    'users response time < 500ms': (r) => r.timings.duration < 500,
  });
  
  // Create user
  const createRes = http.post(`${baseUrl}/users`, JSON.stringify({
    name: `User ${Date.now()}`,
    email: `user${Date.now()}@example.com`,
  }), {
    headers: { 'Content-Type': 'application/json' },
  });
  
  check(createRes, {
    'create status is 201': (r) => r.status === 201,
    'create response time < 1000ms': (r) => r.timings.duration < 1000,
  });
  
  sleep(1);
}
```

### Example 3: Integration Test Suite
```typescript
// tests/integration/users.test.ts
import request from 'supertest';
import { app } from '../../src/app';
import { prisma } from '../../src/lib/db';

describe('Users API', () => {
  beforeEach(async () => {
    await prisma.user.deleteMany();
  });

  describe('POST /api/users', () => {
    it('creates a user', async () => {
      const response = await request(app)
        .post('/api/users')
        .send({
          name: 'John Doe',
          email: 'john@example.com',
        })
        .expect(201);

      expect(response.body.data).toMatchObject({
        name: 'John Doe',
        email: 'john@example.com',
      });
    });

    it('returns 422 for invalid email', async () => {
      await request(app)
        .post('/api/users')
        .send({
          name: 'John Doe',
          email: 'invalid',
        })
        .expect(422);
    });

    it('returns 409 for duplicate email', async () => {
      await prisma.user.create({
        data: { name: 'John', email: 'john@example.com' },
      });

      await request(app)
        .post('/api/users')
        .send({
          name: 'John Doe',
          email: 'john@example.com',
        })
        .expect(409);
    });
  });

  describe('GET /api/users/:id', () => {
    it('returns user by id', async () => {
      const user = await prisma.user.create({
        data: { name: 'John', email: 'john@example.com' },
      });

      const response = await request(app)
        .get(`/api/users/${user.id}`)
        .expect(200);

      expect(response.body.data.name).toBe('John');
    });

    it('returns 404 for non-existent user', async () => {
      await request(app)
        .get('/api/users/non-existent')
        .expect(404);
    });
  });
});
```

### Example 4: Security Testing
```typescript
// tests/security/auth.test.ts
import request from 'supertest';
import { app } from '../../src/app';

describe('Security Tests', () => {
  describe('Authentication', () => {
    it('rejects requests without token', async () => {
      await request(app)
        .get('/api/users')
        .expect(401);
    });

    it('rejects requests with invalid token', async () => {
      await request(app)
        .get('/api/users')
        .set('Authorization', 'Bearer invalid-token')
        .expect(401);
    });
  });

  describe('Authorization', () => {
    it('prevents accessing other users data', async () => {
      const userToken = await getTokenForUser('user-1');
      
      await request(app)
        .get('/api/users/user-2')
        .set('Authorization', `Bearer ${userToken}`)
        .expect(403);
    });
  });

  describe('Input Validation', () => {
    it('prevents SQL injection', async () => {
      await request(app)
        .get('/api/users?id=1; DROP TABLE users;--')
        .expect(400);
    });

    it('prevents XSS', async () => {
      const response = await request(app)
        .post('/api/users')
        .send({
          name: '<script>alert("xss")</script>',
          email: 'test@example.com',
        })
        .expect(201);

      expect(response.body.data.name).not.toContain('<script>');
    });
  });
});
```

## Testing Tools

| Tool | Type | Language |
|------|------|----------|
| Jest | Unit/Integration | JavaScript |
| Mocha | Unit/Integration | JavaScript |
| k6 | Load | JavaScript |
| Artillery | Load | YAML/JavaScript |
| Pact | Contract | Multiple |
| OWASP ZAP | Security | Java |

## Output Structure

```
├── tests/
│   ├── contract/
│   │   ├── consumer.pact.ts
│   │   └── provider.pact.ts
│   ├── integration/
│   │   ├── users.test.ts
│   │   └── orders.test.ts
│   ├── load/
│   │   ├── api.js
│   │   └── scenarios.yaml
│   └── security/
│       └── auth.test.ts
├── .github/
│   └── workflows/
│       └── api-tests.yml
└── docs/
    └── testing-strategy.md
```
