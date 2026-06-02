---
name: nextjs
description: Build full-stack React applications with Next.js. Use when creating SSR/SSG apps, API routes, or implementing App Router patterns.
---

# Next.js

## When to Use

- Building React applications with SSR/SSG
- Creating API routes with Route Handlers
- Implementing server-side data fetching
- Setting up authentication with NextAuth.js
- Deploying to Vercel or self-hosted

## Input

- Application requirements
- Data fetching strategy (SSR, SSG, ISR)
- Authentication needs
- Deployment target

## Output

- Next.js application with App Router
- Server/Client components
- API routes
- Middleware for auth/redirects
- Metadata and SEO configuration

## Checklist

1. **Project Setup**
   - Initialize with `create-next-app`
   - Configure TypeScript
   - Set up Tailwind CSS
   - Configure path aliases

2. **App Router**
   - Use app/ directory structure
   - Implement layouts for shared UI
   - Use loading.tsx for loading states
   - Use error.tsx for error handling

3. **Server vs Client Components**
   - Server Components: data fetching, heavy computation
   - Client Components: interactivity, hooks, browser APIs
   - Use 'use client' directive explicitly

4. **Data Fetching**
   - Server Components: fetch directly
   - Route Handlers: API endpoints
   - Server Actions: form mutations
   - Client-side: SWR/React Query

## Best Practices

- Use Server Components by default
- Add 'use client' only when needed
- Implement proper loading states
- Use Next.js Image component
- Configure metadata for SEO
- Use Server Actions for mutations
- Implement proper error boundaries

## Anti-Patterns

❌ Making everything a Client Component
❌ Not using Next.js built-in optimizations
❌ Fetching data in useEffect for initial render
❌ Not implementing loading/error states
❌ Hardcoding URLs instead of using environment variables
❌ Not using Next.js Image component

## Validation

- Pages load correctly with SSR/SSG
- API routes return proper responses
- Loading states display correctly
- Error boundaries catch errors
- Metadata renders for SEO
- Images are optimized

## Examples

### Example 1: Server Component with Data Fetching
```typescript
// app/users/page.tsx
import { Suspense } from 'react';

async function getUsers() {
  const res = await fetch('https://api.example.com/users', {
    next: { revalidate: 60 }, // ISR: revalidate every 60 seconds
  });
  return res.json();
}

export default async function UsersPage() {
  const users = await getUsers();
  
  return (
    <div>
      <h1>Users</h1>
      <Suspense fallback={<div>Loading...</div>}>
        <UserList users={users} />
      </Suspense>
    </div>
  );
}
```

### Example 2: Server Action
```typescript
// app/actions/user.ts
'use server';

import { revalidatePath } from 'next/cache';

export async function createUser(formData: FormData) {
  const name = formData.get('name') as string;
  const email = formData.get('email') as string;
  
  await db.user.create({
    data: { name, email },
  });
  
  revalidatePath('/users');
}
```

### Example 3: Route Handler
```typescript
// app/api/users/route.ts
import { NextResponse } from 'next/server';

export async function GET() {
  const users = await db.user.findMany();
  return NextResponse.json(users);
}

export async function POST(request: Request) {
  const body = await request.json();
  const user = await db.user.create({ data: body });
  return NextResponse.json(user, { status: 201 });
}
```

## Output Structure

```
├── app/
│   ├── layout.tsx          # Root layout
│   ├── page.tsx            # Home page
│   ├── loading.tsx         # Loading UI
│   ├── error.tsx           # Error UI
│   ├── users/
│   │   ├── page.tsx        # Users page
│   │   └── [id]/
│   │       └── page.tsx    # User detail
│   └── api/
│       └── users/
│           └── route.ts    # API route
├── components/
│   ├── ui/                 # UI components
│   └── features/           # Feature components
├── lib/
│   ├── db.ts               # Database client
│   └── utils.ts            # Utilities
├── public/
├── next.config.js
└── tsconfig.json
```
