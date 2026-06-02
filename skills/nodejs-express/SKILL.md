---
name: nodejs-express
description: Build REST APIs and web servers with Node.js and Express. Use when creating backend services, REST APIs, middleware, or server-side applications.
---

# Node.js & Express

## When to Use

- Building REST APIs with Express.js
- Creating web servers and backend services
- Implementing middleware, routing, error handling
- Setting up validation, security headers, environment config

## Input

- API requirements or endpoint specifications
- Database schema or data models
- Authentication requirements

## Output

- Express application with proper structure
- REST API endpoints with validation
- Middleware configuration
- Error handling implementation
- Tests (unit/integration)

## Checklist

1. **Project Setup**
   - Initialize with TypeScript: `npm init -y && tsc --init`
   - Install dependencies: `express`, `cors`, `helmet`, `dotenv`, `zod`
   - Configure tsconfig with strict mode

2. **Folder Structure**
   ```
   src/
   ├── controllers/    # Request handlers
   ├── services/       # Business logic
   ├── middleware/      # Custom middleware
   ├── routes/         # Route definitions
   ├── models/         # Data models
   ├── utils/          # Utility functions
   ├── config/         # Configuration
   └── index.ts        # Entry point
   ```

3. **Implementation**
   - Define routes in separate files
   - Implement request validation with Zod
   - Add error handling middleware
   - Configure CORS, Helmet, rate limiting
   - Set up environment variables

4. **Testing**
   - Unit tests for services
   - Integration tests for endpoints
   - Use Jest + Supertest

## Best Practices

- Use async/await, avoid callbacks
- Validate all inputs with Zod/Joi
- Use TypeScript strict mode
- Implement proper error classes
- Use environment variables for config
- Add request logging with correlation IDs
- Implement health check endpoint

## Anti-Patterns

❌ Callback hell
❌ Global mutable state
❌ Inconsistent error handling
❌ Hardcoded configuration
❌ Missing input validation
❌ Exposing stack traces in production

## Validation

- All endpoints return consistent response format
- Errors follow RFC 7807 Problem Details
- Input validation catches invalid data
- Health check endpoint responds

## Examples

### Example 1: Create User API
```
Request: POST /api/users
Body: { "name": "John", "email": "john@example.com" }

Response: 201 Created
{
  "success": true,
  "data": { "id": "123", "name": "John", "email": "john@example.com" }
}
```

### Example 2: Get User with Error
```
Request: GET /api/users/999

Response: 404 Not Found
{
  "success": false,
  "error": { "code": "USER_NOT_FOUND", "message": "User not found" }
}
```

## Output Structure

```
{
  "success": boolean,
  "data": T | null,
  "error": {
    "code": string,
    "message": string,
    "details": object | null
  } | null,
  "meta": {
    "page": number,
    "limit": number,
    "total": number
  } | null
}
```
