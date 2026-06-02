---
name: full-api-design
description: Design RESTful APIs with proper structure, versioning, pagination, and error handling. Use when planning API architecture or reviewing API contracts.
---

# Full API Design

## When to Use

- Designing new REST APIs
- Reviewing API contracts
- Planning API versioning
- Implementing pagination
- Standardizing error responses

## Input

- Business requirements
- Data models
- Client needs

## Output

- API specification (OpenAPI)
- Endpoint design
- Error handling strategy
- Versioning plan

## Checklist

1. **URL Design**
   - Use nouns, not verbs
   - Use plural resources
   - Nest for relationships
   - Use kebab-case

2. **HTTP Methods**
   - GET: read (idempotent)
   - POST: create
   - PUT: full update
   - PATCH: partial update
   - DELETE: delete

3. **Response Format**
   - Consistent envelope
   - Proper status codes
   - Error details
   - Pagination metadata

4. **Versioning**
   - URL versioning: /api/v1/
   - Header versioning
   - Deprecation strategy

## Best Practices

- Use OpenAPI specification
- Implement proper pagination
- Use consistent error format
- Add rate limiting
- Document with examples
- Support filtering/sorting
- Use HATEOAS when appropriate

## Anti-Patterns

❌ Verbs in URLs
❌ Inconsistent response format
❌ Missing pagination
❌ No versioning
❌ Poor error messages
❌ No documentation

## Validation

- Endpoints follow REST conventions
- Responses are consistent
- Errors are descriptive
- Pagination works correctly
- API is documented

## Examples

### Example 1: Resource Endpoints
```
# Users
GET    /api/v1/users          # List users
GET    /api/v1/users/:id      # Get user
POST   /api/v1/users          # Create user
PUT    /api/v1/users/:id      # Update user
PATCH  /api/v1/users/:id      # Partial update
DELETE /api/v1/users/:id      # Delete user

# User Posts (nested)
GET    /api/v1/users/:id/posts    # User's posts
POST   /api/v1/users/:id/posts    # Create post for user

# Filtering & Sorting
GET    /api/v1/users?role=admin&sort=-createdAt
GET    /api/v1/users?page=2&limit=20
```

### Example 2: Response Envelope
```json
{
  "success": true,
  "data": {
    "id": "123",
    "name": "John Doe",
    "email": "john@example.com"
  },
  "meta": null,
  "error": null
}

// With pagination
{
  "success": true,
  "data": [...],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  },
  "error": null
}
```

### Example 3: Error Response (RFC 7807)
```json
{
  "success": false,
  "data": null,
  "error": {
    "type": "https://api.example.com/errors/validation",
    "title": "Validation Error",
    "status": 422,
    "detail": "The request body contains invalid fields",
    "instance": "/api/v1/users",
    "errors": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  }
}
```

### Example 4: OpenAPI Specification
```yaml
openapi: 3.0.0
info:
  title: User API
  version: 1.0.0
paths:
  /api/v1/users:
    get:
      summary: List users
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserList'
    post:
      summary: Create user
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUser'
      responses:
        '201':
          description: Created
components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
        name:
          type: string
        email:
          type: string
          format: email
```

## Status Codes Reference

| Code | Meaning | Use When |
|------|---------|----------|
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Invalid input |
| 401 | Unauthorized | Not authenticated |
| 403 | Forbidden | Not authorized |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Duplicate resource |
| 422 | Unprocessable | Validation error |
| 429 | Too Many Requests | Rate limited |
| 500 | Server Error | Internal error |

## Output Structure

```
├── api/
│   ├── v1/
│   │   ├── users.ts
│   │   ├── posts.ts
│   │   └── index.ts
│   └── middleware/
│       ├── validate.ts
│       └── errorHandler.ts
├── openapi.yaml           # API specification
├── types/
│   └── api.ts             # API types
└── docs/
    └── api-examples.md
```
