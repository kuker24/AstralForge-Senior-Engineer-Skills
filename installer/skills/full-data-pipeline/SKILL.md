---
name: full-data-pipeline
description: Build data pipelines for ETL/ELT processes. Use when designing data flows, implementing transformations, or setting up data quality checks.
---

# Full Data Pipeline

## When to Use

- Building ETL/ELT pipelines
- Implementing data transformations
- Setting up data quality checks
- Processing streaming data

## Input

- Data sources
- Transformation rules
- Quality requirements

## Output

- Pipeline configuration
- Transformation logic
- Quality checks
- Monitoring setup

## Checklist

1. **Data Ingestion**
   - Connect to sources
   - Handle schema changes
   - Implement incremental loading
   - Error handling

2. **Transformation**
   - Clean data
   - Apply business rules
   - Aggregate data
   - Handle nulls/defaults

3. **Data Quality**
   - Validate schemas
   - Check completeness
   - Detect anomalies
   - Monitor freshness

4. **Orchestration**
   - Schedule jobs
   - Handle dependencies
   - Implement retries
   - Monitor execution

## Best Practices

- Use incremental loading
- Implement data validation
- Handle schema evolution
- Monitor pipeline health
- Document data lineage
- Test transformations

## Anti-Patterns

❌ Full refresh every time
❌ No data validation
❌ Silent failures
❌ No monitoring
❌ Hardcoded configurations

## Validation

- Data loads correctly
- Transformations are accurate
- Quality checks pass
- Monitoring works

## Examples

### Example 1: ETL Pipeline
```typescript
// pipelines/user-etl.ts
import { prisma } from '../lib/db';

interface RawUser {
  id: string;
  full_name: string;
  email_address: string;
  created_at: string;
}

interface TransformedUser {
  id: string;
  name: string;
  email: string;
  createdAt: Date;
}

async function extract(): Promise<RawUser[]> {
  // Extract from source
  const response = await fetch('https://api.source.com/users');
  return response.json();
}

function transform(raw: RawUser[]): TransformedUser[] {
  return raw.map(user => ({
    id: user.id,
    name: user.full_name.trim(),
    email: user.email_address.toLowerCase(),
    createdAt: new Date(user.created_at),
  }));
}

async function load(users: TransformedUser[]): Promise<void> {
  for (const user of users) {
    await prisma.user.upsert({
      where: { id: user.id },
      update: user,
      create: user,
    });
  }
}

async function runPipeline() {
  console.log('Starting ETL pipeline...');
  
  const raw = await extract();
  console.log(`Extracted ${raw.length} records`);
  
  const transformed = transform(raw);
  console.log(`Transformed ${transformed.length} records`);
  
  await load(transformed);
  console.log('Pipeline complete');
}

runPipeline().catch(console.error);
```

### Example 2: Data Quality Checks
```typescript
// lib/data-quality.ts
interface QualityCheck {
  name: string;
  check: (data: any[]) => boolean;
  message: string;
}

export const qualityChecks: QualityCheck[] = [
  {
    name: 'completeness',
    check: (data) => data.every(row => row.email && row.name),
    message: 'Missing required fields',
  },
  {
    name: 'uniqueness',
    check: (data) => {
      const emails = data.map(r => r.email);
      return emails.length === new Set(emails).size;
    },
    message: 'Duplicate emails found',
  },
  {
    name: 'format',
    check: (data) => data.every(row => /\S+@\S+\.\S+/.test(row.email)),
    message: 'Invalid email format',
  },
];

export function runQualityChecks(
  data: any[],
  checks: QualityCheck[]
): { passed: boolean; failures: string[] } {
  const failures: string[] = [];
  
  for (const check of checks) {
    if (!check.check(data)) {
      failures.push(`${check.name}: ${check.message}`);
    }
  }
  
  return {
    passed: failures.length === 0,
    failures,
  };
}
```

### Example 3: Pipeline with Dagster
```python
# pipelines/definitions.py
from dagster import asset, Definitions, AssetIn
import pandas as pd

@asset
def raw_users() -> pd.DataFrame:
    """Extract raw users from API."""
    return pd.read_json("https://api.example.com/users")

@asset(deps=[raw_users])
def cleaned_users(raw_users: pd.DataFrame) -> pd.DataFrame:
    """Clean and transform users."""
    return (
        raw_users
        .dropna(subset=["email"])
        .assign(email=lambda df: df["email"].str.lower())
        .drop_duplicates(subset=["email"])
    )

@asset(deps=[cleaned_users])
def user_analytics(cleaned_users: pd.DataFrame) -> pd.DataFrame:
    """Generate user analytics."""
    return (
        cleaned_users
        .groupby("role")
        .agg(count=("id", "count"), avg_age=("age", "mean"))
        .reset_index()
    )

defs = Definitions(assets=[raw_users, cleaned_users, user_analytics])
```

### Example 4: Incremental Loading
```typescript
// lib/incremental.ts
interface SyncState {
  lastSyncAt: Date;
  lastId: string;
}

export async function incrementalSync(
  tableName: string,
  syncState: SyncState
): Promise<{ data: any[]; newState: SyncState }> {
  const data = await fetchChanges(tableName, syncState.lastSyncAt);
  
  const newState: SyncState = {
    lastSyncAt: new Date(),
    lastId: data[data.length - 1]?.id || syncState.lastId,
  };
  
  return { data, newState };
}

async function fetchChanges(table: string, since: Date) {
  return prisma[table].findMany({
    where: {
      updatedAt: { gt: since },
    },
    orderBy: { updatedAt: 'asc' },
  });
}
```

## Pipeline Tools

| Tool | Type | Best For |
|------|------|----------|
| Dagster | Orchestrator | Complex pipelines |
| Airflow | Orchestrator | Large scale |
| Prefect | Orchestrator | Python-native |
| dbt | Transformation | SQL transformations |
| Spark | Processing | Big data |

## Output Structure

```
├── pipelines/
│   ├── user-etl.ts
│   ├── analytics.ts
│   └── definitions.py
├── lib/
│   ├── data-quality.ts
│   ├── incremental.ts
│   └── transforms.ts
├── config/
│   └── pipeline-config.yaml
└── monitoring/
    └── pipeline-health.ts
```
