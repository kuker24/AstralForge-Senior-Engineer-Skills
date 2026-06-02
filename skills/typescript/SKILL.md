---
name: typescript
description: Write type-safe TypeScript code. Use when setting up TypeScript projects, defining types, migrating from JS, or implementing advanced type patterns.
---

# TypeScript

## When to Use

- Setting up TypeScript configuration
- Defining interfaces and types
- Migrating JavaScript to TypeScript
- Implementing generics and utility types
- Type-safe API contracts

## Input

- JavaScript codebase to migrate
- API contracts or data models
- Configuration requirements

## Output

- TypeScript configuration (tsconfig.json)
- Type definitions (interfaces, types)
- Type-safe implementation
- Migration guide if applicable

## Checklist

1. **Configuration**
   - Enable strict mode
   - Configure paths and aliases
   - Set target and module system
   - Enable source maps for debugging

2. **Type Definitions**
   - Define interfaces for data models
   - Use discriminated unions for state
   - Implement generics for reusability
   - Use utility types (Pick, Omit, Partial)

3. **Best Practices**
   - Prefer interfaces for object shapes
   - Use type for unions and intersections
   - Implement type guards for runtime checks
   - Use const assertions for literals

4. **Migration**
   - Start with `strict: false`, gradually enable
   - Rename .js to .ts incrementally
   - Add types from outside-in
   - Use JSDoc for quick wins

## Best Practices

- Use `strict: true` in tsconfig
- Prefer `interface` for object shapes
- Use `type` for unions/intersections
- Avoid `any` - use `unknown` and narrow
- Use discriminated unions over type assertions
- Implement type guards for runtime safety
- Use `readonly` for immutable data

## Anti-Patterns

❌ Using `any` everywhere
❌ Type assertions without validation
❌ Ignoring TypeScript errors
❌ Overusing `as` keyword
❌ Not using strict mode
❌ Copying types instead of deriving them

## Validation

- No TypeScript errors (`tsc --noEmit`)
- Strict mode enabled
- No `any` types in new code
- Type guards for external data
- Tests cover type edge cases

## Examples

### Example 1: Interface vs Type
```typescript
// Interface - for object shapes
interface User {
  id: string;
  name: string;
  email: string;
  readonly createdAt: Date;
}

// Type - for unions and intersections
type Status = 'pending' | 'active' | 'deleted';
type UserWithStatus = User & { status: Status };

// Generic interface
interface ApiResponse<T> {
  data: T;
  error: string | null;
  meta: { page: number; total: number };
}
```

### Example 2: Type Guard
```typescript
function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'name' in value &&
    'email' in value
  );
}

// Usage
function processUser(data: unknown) {
  if (isUser(data)) {
    // TypeScript knows data is User here
    console.log(data.name);
  } else {
    throw new Error('Invalid user data');
  }
}
```

### Example 3: Utility Types
```typescript
// Make all properties optional
type PartialUser = Partial<User>;

// Pick specific properties
type UserSummary = Pick<User, 'id' | 'name'>;

// Omit specific properties
type CreateUserInput = Omit<User, 'id' | 'createdAt'>;

// Make all properties required
type RequiredUser = Required<User>;

// Make all properties readonly
type ReadonlyUser = Readonly<User>;
```

## Output Structure

```
├── tsconfig.json
├── src/
│   ├── types/
│   │   ├── index.ts
│   │   ├── user.ts
│   │   └── api.ts
│   ├── utils/
│   │   └── type-guards.ts
│   └── index.ts
└── tests/
    └── types.test.ts
```
