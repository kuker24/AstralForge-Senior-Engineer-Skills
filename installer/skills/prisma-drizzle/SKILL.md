---
name: prisma-drizzle
description: Work with Prisma or Drizzle ORM for database operations. Use when designing schemas, running migrations, or implementing type-safe database queries.
---

# Prisma & Drizzle ORM

## When to Use

- Designing database schemas
- Running migrations
- Implementing type-safe queries
- Setting up database connections
- Seed data management

## Input

- Database requirements
- Entity relationships
- Query patterns needed

## Output

- Database schema (Prisma Schema or Drizzle)
- Migration files
- Type-safe query functions
- Seed scripts

## Checklist

1. **Choose ORM**
   - Prisma: schema-first, auto-generated client, migrations
   - Drizzle: code-first, SQL-like, lightweight
   - Consider: team familiarity, project size, performance needs

2. **Schema Design**
   - Define models/tables
   - Set up relations (1:1, 1:N, M:N)
   - Add indexes for performance
   - Define enums for fixed values

3. **Migrations**
   - Create migration files
   - Review before applying
   - Test rollback strategy
   - Version control migrations

4. **Queries**
   - Use transactions for multi-step operations
   - Implement pagination
   - Add error handling
   - Use select to limit returned fields

## Best Practices

- Use migrations, never manual schema changes
- Add indexes for frequently queried fields
- Use transactions for data consistency
- Limit returned fields with select
- Use connection pooling in production
- Implement soft deletes for critical data

## Anti-Patterns

❌ Manual SQL migrations
❌ N+1 queries
❌ Missing indexes on foreign keys
❌ Fetching all fields when not needed
❌ No connection pooling
❌ Ignoring migration rollbacks

## Validation

- Migrations run successfully
- Queries return expected data
- Transactions handle errors properly
- Connection pooling works
- No N+1 query issues

## Examples

### Example 1: Prisma Schema
```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  posts     Post[]
  profile   Profile?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([email])
}

model Post {
  id        String   @id @default(cuid())
  title     String
  content   String?
  published Boolean  @default(false)
  author    User     @relation(fields: [authorId], references: [id])
  authorId  String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([authorId])
  @@index([published])
}

model Profile {
  id     String  @id @default(cuid())
  bio    String?
  user   User    @relation(fields: [userId], references: [id])
  userId String  @unique
}
```

### Example 2: Drizzle Schema
```typescript
// src/db/schema.ts
import { pgTable, text, boolean, timestamp, index } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: text('id').primaryKey().default(crypto.randomUUID()),
  email: text('email').notNull().unique(),
  name: text('name'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
}, (table) => ({
  emailIdx: index('email_idx').on(table.email),
}));

export const posts = pgTable('posts', {
  id: text('id').primaryKey().default(crypto.randomUUID()),
  title: text('title').notNull(),
  content: text('content'),
  published: boolean('published').default(false),
  authorId: text('author_id').notNull().references(() => users.id),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
}, (table) => ({
  authorIdx: index('author_idx').on(table.authorId),
  publishedIdx: index('published_idx').on(table.published),
}));
```

### Example 3: Type-Safe Query (Prisma)
```typescript
// Get user with posts
const userWithPosts = await prisma.user.findUnique({
  where: { id: userId },
  include: {
    posts: {
      where: { published: true },
      orderBy: { createdAt: 'desc' },
      take: 10,
    },
    profile: true,
  },
});

// Create user with profile
const user = await prisma.user.create({
  data: {
    email: 'john@example.com',
    name: 'John Doe',
    profile: {
      create: {
        bio: 'Software developer',
      },
    },
  },
  include: { profile: true },
});
```

## Prisma vs Drizzle

| Aspect | Prisma | Drizzle |
|--------|--------|---------|
| Approach | Schema-first | Code-first |
| Type Safety | Auto-generated | Manual types |
| Migrations | Built-in | Separate tool |
| Bundle Size | Large (~2MB) | Small (~50KB) |
| Learning Curve | Moderate | Low |
| SQL Control | Less | More |

## Output Structure

```
├── prisma/
│   ├── schema.prisma
│   ├── migrations/
│   └── seed.ts
├── src/
│   ├── db/
│   │   ├── index.ts
│   │   ├── schema.ts (Drizzle)
│   │   └── client.ts
│   └── services/
│       └── user.service.ts
└── .env
```
