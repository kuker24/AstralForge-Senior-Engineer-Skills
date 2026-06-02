---
name: graphql-impl
description: Implement GraphQL APIs with Apollo Server or similar. Use when building GraphQL schemas, resolvers, or integrating with frontend clients.
---

# GraphQL Implementation

## When to Use

- Building GraphQL APIs
- Implementing schemas and resolvers
- Setting up Apollo Server
- Integrating with databases
- Adding authentication to GraphQL

## Input

- API requirements
- Data models
- Client requirements

## Output

- GraphQL schema
- Resolvers
- Apollo Server configuration
- Context setup
- Error handling

## Checklist

1. **Schema Design**
   - Define types and inputs
   - Use enums for fixed values
   - Implement interfaces for shared fields
   - Design for client needs

2. **Resolvers**
   - Implement query resolvers
   - Implement mutations
   - Use DataLoader for N+1 prevention
   - Handle errors properly

3. **Context**
   - Set up authentication
   - Pass user to context
   - Include database connections
   - Handle authorization

4. **Performance**
   - Use DataLoader for batching
   - Implement query complexity limits
   - Add persisted queries
   - Monitor resolver performance

## Best Practices

- Design schema for client needs
- Use DataLoader to prevent N+1
- Implement proper error handling
- Add query complexity limits
- Use fragments for shared fields
- Implement pagination properly
- Add schema validation

## Anti-Patterns

❌ N+1 queries in resolvers
❌ Overly permissive schema
❌ No error handling
❌ Missing authorization
❌ No query complexity limits
❌ Exposing internal IDs

## Validation

- Schema is valid GraphQL
- Resolvers return correct types
- DataLoader prevents N+1
- Authorization works correctly
- Errors are handled gracefully

## Examples

### Example 1: Schema Definition
```graphql
# schema.graphql
type User {
  id: ID!
  email: String!
  name: String
  posts: [Post!]!
  createdAt: DateTime!
}

type Post {
  id: ID!
  title: String!
  content: String
  author: User!
  published: Boolean!
  createdAt: DateTime!
}

type Query {
  users(limit: Int, offset: Int): [User!]!
  user(id: ID!): User
  posts(limit: Int, offset: Int): [Post!]!
  post(id: ID!): Post
}

type Mutation {
  createUser(input: CreateUserInput!): User!
  updateUser(id: ID!, input: UpdateUserInput!): User!
  createPost(input: CreatePostInput!): Post!
  publishPost(id: ID!): Post!
}

input CreateUserInput {
  email: String!
  name: String
  password: String!
}

input UpdateUserInput {
  email: String
  name: String
}

input CreatePostInput {
  title: String!
  content: String
}

scalar DateTime
```

### Example 2: Apollo Server Setup
```typescript
// server.ts
import { ApolloServer } from '@apollo/server';
import { expressMiddleware } from '@apollo/server/express4';
import { ApolloServerPluginDrainHttpServer } from '@apollo/server/plugin/drainHttpServer';
import express from 'express';
import http from 'http';
import cors from 'cors';
import { typeDefs } from './schema';
import { resolvers } from './resolvers';
import { createContext } from './context';

const app = express();
const httpServer = http.createServer(app);

const server = new ApolloServer({
  typeDefs,
  resolvers,
  plugins: [ApolloServerPluginDrainHttpServer({ httpServer })],
  formatError: (error) => {
    console.error(error);
    return {
      message: error.message,
      code: error.extensions?.code || 'INTERNAL_SERVER_ERROR',
      path: error.path,
    };
  },
});

await server.start();

app.use(
  '/graphql',
  cors<cors.CorsRequest>(),
  express.json(),
  expressMiddleware(server, {
    context: createContext,
  })
);

await new Promise<void>((resolve) => httpServer.listen({ port: 4000 }, resolve));
console.log('Server ready at http://localhost:4000/graphql');
```

### Example 3: Resolvers with DataLoader
```typescript
// resolvers/user.ts
import DataLoader from 'dataloader';
import { Context } from '../context';

// DataLoader for batching user queries
const userLoader = new DataLoader(async (userIds: string[]) => {
  const users = await prisma.user.findMany({
    where: { id: { in: userIds } },
  });
  
  const userMap = new Map(users.map((u) => [u.id, u]));
  return userIds.map((id) => userMap.get(id) || null);
});

export const userResolvers = {
  Query: {
    users: async (_: any, args: { limit?: number; offset?: number }, ctx: Context) => {
      return ctx.prisma.user.findMany({
        take: args.limit || 10,
        skip: args.offset || 0,
      });
    },
    
    user: async (_: any, { id }: { id: string }, ctx: Context) => {
      return userLoader.load(id);
    },
  },
  
  User: {
    posts: async (parent: any, _: any, ctx: Context) => {
      return ctx.prisma.post.findMany({
        where: { authorId: parent.id },
      });
    },
  },
  
  Mutation: {
    createUser: async (_: any, { input }: any, ctx: Context) => {
      return ctx.prisma.user.create({
        data: input,
      });
    },
  },
};
```

### Example 4: Context with Authentication
```typescript
// context.ts
import { prisma } from './lib/db';
import { verifyToken } from './lib/jwt';

export interface Context {
  prisma: typeof prisma;
  user: { id: string; email: string; role: string } | null;
}

export async function createContext({ req }: { req: any }): Promise<Context> {
  const token = req.headers.authorization?.replace('Bearer ', '');
  
  let user = null;
  if (token) {
    try {
      user = await verifyToken(token);
    } catch (error) {
      // Invalid token, user remains null
    }
  }
  
  return {
    prisma,
    user,
  };
}
```

### Example 5: Pagination
```typescript
// resolvers/post.ts
export const postResolvers = {
  Query: {
    posts: async (_: any, args: { first?: number; after?: string }, ctx: Context) => {
      const limit = args.first || 10;
      
      const posts = await ctx.prisma.post.findMany({
        take: limit + 1, // Fetch one extra to check if there's more
        cursor: args.after ? { id: args.after } : undefined,
        skip: args.after ? 1 : 0,
        orderBy: { createdAt: 'desc' },
      });
      
      const hasNextPage = posts.length > limit;
      const edges = hasNextPage ? posts.slice(0, -1) : posts;
      
      return {
        edges: edges.map((post) => ({
          node: post,
          cursor: post.id,
        })),
        pageInfo: {
          hasNextPage,
          endCursor: edges[edges.length - 1]?.id,
        },
      };
    },
  },
};
```

## Query Complexity

```typescript
// plugins/complexity.ts
import { ApolloServerPlugin } from '@apollo/server';

export const complexityPlugin: ApolloServerPlugin = {
  async requestDidStart() {
    return {
      async didResolveOperation({ request, document }) {
        const complexity = calculateComplexity(document);
        if (complexity > 1000) {
          throw new Error('Query too complex');
        }
      },
    };
  },
};

function calculateComplexity(document: any): number {
  // Implementation for complexity calculation
  return 0;
}
```

## Output Structure

```
├── schema/
│   ├── schema.graphql       # Schema definition
│   ├── typeDefs.ts          # Type definitions
│   └── scalars.ts           # Custom scalars
├── resolvers/
│   ├── user.ts
│   ├── post.ts
│   └── index.ts
├── lib/
│   ├── context.ts           # Context setup
│   ├── dataloaders.ts       # DataLoader instances
│   └── db.ts                # Database client
├── plugins/
│   └── complexity.ts        # Query complexity
└── server.ts                # Server entry point
```
