---
name: mongodb
description: Work with MongoDB for NoSQL database operations. Use when designing schemas, implementing queries, aggregations, or setting up connection management.
---

# MongoDB

## When to Use

- Designing document schemas
- Implementing CRUD operations
- Writing aggregation pipelines
- Setting up indexes for performance
- Managing connections and pooling

## Input

- Data requirements
- Query patterns
- Performance needs

## Output

- MongoDB schemas
- Index configurations
- Query functions
- Aggregation pipelines
- Connection setup

## Checklist

1. **Schema Design**
   - Design document structure
   - Decide: embed vs reference
   - Add validation rules
   - Plan for growth

2. **Indexes**
   - Create indexes for queries
   - Use compound indexes
   - Monitor index usage
   - Avoid over-indexing

3. **Queries**
   - Use projections to limit fields
   - Implement pagination
   - Handle errors properly
   - Use transactions when needed

4. **Connection Management**
   - Use connection pooling
   - Handle reconnection
   - Set timeouts
   - Monitor connection health

## Best Practices

- Design schemas for query patterns
- Use indexes strategically
- Implement connection pooling
- Use aggregation for complex queries
- Enable validation
- Use transactions for multi-document operations
- Monitor slow queries

## Anti-Patterns

❌ N+1 queries
❌ Missing indexes on query fields
❌ Unbounded documents (arrays growing forever)
❌ No connection pooling
❌ Fetching all fields
❌ No schema validation

## Validation

- Queries return expected results
- Indexes improve query performance
- Connection pooling works
- Transactions handle errors
- Validation catches invalid data

## Examples

### Example 1: Schema with Validation
```javascript
// models/user.js
const { Schema, model } = require('mongoose');

const userSchema = new Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true,
  },
  name: {
    type: String,
    required: true,
    trim: true,
  },
  role: {
    type: String,
    enum: ['user', 'admin', 'moderator'],
    default: 'user',
  },
  profile: {
    bio: String,
    avatar: String,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
}, {
  timestamps: true,
});

// Index for common queries
userSchema.index({ email: 1 });
userSchema.index({ role: 1, createdAt: -1 });

module.exports = model('User', userSchema);
```

### Example 2: Aggregation Pipeline
```javascript
// Get user statistics
const userStats = await User.aggregate([
  // Match active users
  { $match: { status: 'active' } },
  
  // Lookup orders
  {
    $lookup: {
      from: 'orders',
      localField: '_id',
      foreignField: 'userId',
      as: 'orders',
    },
  },
  
  // Add computed fields
  {
    $addFields: {
      totalOrders: { $size: '$orders' },
      totalSpent: { $sum: '$orders.amount' },
    },
  },
  
  // Group by role
  {
    $group: {
      _id: '$role',
      count: { $sum: 1 },
      avgOrders: { $avg: '$totalOrders' },
      avgSpent: { $avg: '$totalSpent' },
    },
  },
  
  // Sort by count
  { $sort: { count: -1 } },
]);
```

### Example 3: Connection with Pooling
```javascript
// lib/db.js
const { MongoClient } = require('mongodb');

let client;
let db;

async function connectDB() {
  if (db) return db;

  client = new MongoClient(process.env.MONGODB_URI, {
    maxPoolSize: 50,
    minPoolSize: 10,
    maxIdleTimeMS: 60000,
    connectTimeoutMS: 5000,
    socketTimeoutMS: 45000,
  });

  await client.connect();
  db = client.db(process.env.DB_NAME);

  // Handle connection events
  client.on('close', () => console.log('MongoDB connection closed'));
  client.on('error', (err) => console.error('MongoDB error:', err));

  return db;
}

async function closeDB() {
  if (client) {
    await client.close();
    db = null;
  }
}

module.exports = { connectDB, closeDB };
```

### Example 4: Transaction
```javascript
async function createOrderWithItems(userId, items) {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    // Create order
    const order = await Order.create([{
      userId,
      items,
      total: items.reduce((sum, item) => sum + item.price, 0),
    }], { session });

    // Update inventory
    for (const item of items) {
      await Product.updateOne(
        { _id: item.productId, stock: { $gte: item.quantity } },
        { $inc: { stock: -item.quantity } },
        { session }
      );
    }

    await session.commitTransaction();
    return order[0];
  } catch (error) {
    await session.abortTransaction();
    throw error;
  } finally {
    session.endSession();
  }
}
```

## Embed vs Reference

| Scenario | Strategy | Reason |
|----------|----------|--------|
| 1:1 relationship | Embed | Query together, no joins needed |
| 1:Few relationship | Embed | Limited array size |
| 1:Many relationship | Reference | Array could grow unbounded |
| Many:Many relationship | Reference | Normalization |
| Data updated frequently | Reference | Avoid updating multiple documents |

## Output Structure

```
├── models/
│   ├── user.js
│   ├── order.js
│   └── product.js
├── lib/
│   ├── db.js              # Connection management
│   └── queries.js         # Query helpers
├── migrations/            # If using migrations
└── seed.js                # Seed data
```
