---
name: full-database-migration
description: Plan and execute database migrations with zero downtime. Use when designing migration strategies, implementing rollbacks, or managing schema changes.
---

# Full Database Migration

## When to Use

- Planning schema migrations
- Implementing zero-downtime deploys
- Managing database versions
- Rolling back failed migrations

## Input

- Current schema
- Target schema
- Data volume
- Downtime constraints

## Output

- Migration scripts
- Rollback scripts
- Migration strategy
- Testing plan

## Checklist

1. **Planning**
   - Analyze schema changes
   - Estimate data volume
   - Plan rollback strategy
   - Schedule maintenance window

2. **Migration Scripts**
   - Write forward migration
   - Write rollback script
   - Test on staging
   - Verify data integrity

3. **Zero-Downtime Strategy**
   - Expand-contraction pattern
   - Backfill data
   - Switch traffic
   - Clean up old schema

4. **Validation**
   - Test migration locally
   - Test on staging
   - Verify data integrity
   - Monitor performance

## Best Practices

- Always have rollback scripts
- Test on production-like data
- Use expand-contraction pattern
- Backfill data in batches
- Monitor during migration
- Keep migrations small
- Version control migrations

## Anti-Patterns

❌ No rollback script
❌ Large single migration
❌ Not testing on production data
❌ Breaking changes without backward compatibility
❌ No monitoring during migration

## Validation

- Migration runs successfully
- Rollback works correctly
- Data integrity maintained
- Performance acceptable
- No downtime

## Examples

### Example 1: Safe Column Addition
```sql
-- Step 1: Add column (nullable)
ALTER TABLE users ADD COLUMN phone VARCHAR(20) NULL;

-- Step 2: Backfill data (in batches)
UPDATE users SET phone = 'unknown' WHERE phone IS NULL LIMIT 10000;

-- Step 3: Add NOT NULL constraint (after backfill)
ALTER TABLE users ALTER COLUMN phone SET NOT NULL;

-- Rollback
ALTER TABLE users DROP COLUMN phone;
```

### Example 2: Zero-Downtime Column Rename
```sql
-- Step 1: Add new column
ALTER TABLE users ADD COLUMN first_name VARCHAR(255);

-- Step 2: Copy data
UPDATE users SET first_name = name WHERE first_name IS NULL;

-- Step 3: Update application to write to both columns
-- Step 4: Update application to read from new column
-- Step 5: Drop old column
ALTER TABLE users DROP COLUMN name;
```

### Example 3: Migration with Prisma
```typescript
// prisma/migrations/20260524_add_phone/migration.sql
-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "phone" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");
```

### Example 4: Batch Migration Script
```typescript
// scripts/migrate.ts
import { prisma } from '../lib/db';

async function migrate() {
  const batchSize = 1000;
  let processed = 0;
  
  while (true) {
    const users = await prisma.user.findMany({
      where: { phone: null },
      take: batchSize,
    });
    
    if (users.length === 0) break;
    
    await prisma.$transaction(
      users.map(user =>
        prisma.user.update({
          where: { id: user.id },
          data: { phone: 'unknown' },
        })
      )
    );
    
    processed += users.length;
    console.log(`Processed ${processed} users`);
    
    // Small delay to avoid overwhelming database
    await new Promise(resolve => setTimeout(resolve, 100));
  }
}

migrate().catch(console.error);
```

## Migration Strategies

| Strategy | Use When | Complexity |
|----------|----------|------------|
| Direct | Small tables, maintenance window | Low |
| Expand-Contract | Zero downtime | Medium |
| Shadow Table | Large tables, critical | High |

## Output Structure

```
├── migrations/
│   ├── 20260524_add_phone/
│   │   ├── up.sql
│   │   ├── down.sql
│   │   └── migrate.ts
│   └── 20260525_rename_column/
├── scripts/
│   ├── migrate.ts
│   └── rollback.ts
└── docs/
    └── migration-plan.md
```
