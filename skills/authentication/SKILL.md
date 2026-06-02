---
name: authentication
description: Implement authentication and authorization. Use when setting up JWT, OAuth, session management, passkeys, or integrating with Auth.js/NextAuth.
---

# Authentication & Authorization

## When to Use

- Implementing user authentication
- Setting up OAuth providers (Google, GitHub, etc.)
- Managing JWT tokens
- Implementing passkey/WebAuthn
- Setting up session management
- Adding CSRF protection

## Input

- Authentication requirements
- OAuth provider credentials
- Session strategy preference

## Output

- Authentication configuration
- Login/logout endpoints
- Protected routes
- Session management
- CSRF protection

## Checklist

1. **Choose Strategy**
   - JWT: stateless, scalable, no server storage
   - Session: server-side storage, easier revocation
   - OAuth: third-party providers
   - Passkey: passwordless, WebAuthn

2. **Implementation**
   - Set up Auth.js/NextAuth or custom solution
   - Configure providers (OAuth, email, credentials)
   - Implement login/logout flows
   - Add middleware for protected routes

3. **Security**
   - Use httpOnly cookies for tokens
   - Implement CSRF protection
   - Add rate limiting on login
   - Secure password hashing (bcrypt)
   - Token refresh mechanism

4. **Authorization**
   - Role-based access control (RBAC)
   - Permission-based access
   - Protected API routes
   - Middleware for auth checks

## Best Practices

- Use httpOnly cookies, not localStorage
- Implement CSRF tokens
- Use secure, httpOnly, sameSite cookie flags
- Hash passwords with bcrypt/argon2
- Implement token refresh
- Add rate limiting on auth endpoints
- Log authentication events

## Anti-Patterns

❌ Storing tokens in localStorage
❌ No CSRF protection
❌ Weak password hashing (MD5, SHA1)
❌ No rate limiting on login
❌ Expiring tokens too long
❌ Not invalidating tokens on logout

## Validation

- Login/logout works correctly
- Tokens are properly refreshed
- Protected routes redirect to login
- CSRF protection active
- Rate limiting prevents brute force
- Session invalidation works

## Examples

### Example 1: Auth.js Configuration
```typescript
// auth.ts
import NextAuth from 'next-auth';
import Github from 'next-auth/providers/github';
import Google from 'next-auth/providers/google';
import Credentials from 'next-auth/providers/credentials';
import { PrismaAdapter } from '@auth/prisma-adapter';
import { prisma } from './lib/db';

export const { handlers, auth, signIn, signOut } = NextAuth({
  adapter: PrismaAdapter(prisma),
  providers: [
    Github({
      clientId: process.env.GITHUB_ID,
      clientSecret: process.env.GITHUB_SECRET,
    }),
    Google({
      clientId: process.env.GOOGLE_ID,
      clientSecret: process.env.GOOGLE_SECRET,
    }),
    Credentials({
      credentials: {
        email: {},
        password: {},
      },
      authorize: async (credentials) => {
        const user = await validateUser(credentials.email, credentials.password);
        return user || null;
      },
    }),
  ],
  callbacks: {
    authorized: async ({ auth }) => {
      return !!auth;
    },
  },
  session: {
    strategy: 'jwt',
    maxAge: 30 * 24 * 60 * 60, // 30 days
  },
});
```

### Example 2: Protected Route Middleware
```typescript
// middleware.ts
import { auth } from './auth';
import { NextResponse } from 'next/server';

export default auth((req) => {
  const isLoggedIn = !!req.auth;
  const isPublicRoute = publicRoutes.includes(req.nextUrl.pathname);

  if (!isLoggedIn && !isPublicRoute) {
    return NextResponse.redirect(new URL('/login', req.nextUrl));
  }

  return NextResponse.next();
});

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
};
```

### Example 3: JWT Token Management
```typescript
// lib/jwt.ts
import jwt from 'jsonwebtoken';

const SECRET = process.env.JWT_SECRET!;

interface TokenPayload {
  userId: string;
  email: string;
  role: string;
}

export function generateTokens(payload: TokenPayload) {
  const accessToken = jwt.sign(payload, SECRET, {
    expiresIn: '15m',
  });

  const refreshToken = jwt.sign(payload, SECRET, {
    expiresIn: '7d',
  });

  return { accessToken, refreshToken };
}

export function verifyToken(token: string): TokenPayload {
  return jwt.verify(token, SECRET) as TokenPayload;
}

export function refreshAccessToken(refreshToken: string) {
  const payload = verifyToken(refreshToken);
  return generateTokens({
    userId: payload.userId,
    email: payload.email,
    role: payload.role,
  });
}
```

### Example 4: OAuth Flow
```typescript
// app/login/page.tsx
import { signIn } from '@/auth';

export default function LoginPage() {
  return (
    <div>
      <h1>Login</h1>
      <form
        action={async (formData) => {
          'use server';
          await signIn('credentials', formData);
        }}
      >
        <input name="email" type="email" required />
        <input name="password" type="password" required />
        <button type="submit">Sign in</button>
      </form>
      
      <button onClick={() => signIn('github')}>
        Sign in with GitHub
      </button>
      
      <button onClick={() => signIn('google')}>
        Sign in with Google
      </button>
    </div>
  );
}
```

## Security Checklist

- [ ] Passwords hashed with bcrypt/argon2
- [ ] Tokens stored in httpOnly cookies
- [ ] CSRF protection enabled
- [ ] Rate limiting on auth endpoints
- [ ] Secure cookie flags (httpOnly, secure, sameSite)
- [ ] Token refresh mechanism
- [ ] Session invalidation on logout
- [ ] Audit logging for auth events

## Output Structure

```
├── auth.ts                 # Auth.js configuration
├── middleware.ts            # Auth middleware
├── lib/
│   ├── jwt.ts              # JWT utilities
│   ├── password.ts         # Password hashing
│   └── db.ts               # Database client
├── app/
│   ├── login/
│   │   └── page.tsx        # Login page
│   ├── api/
│   │   └── auth/
│   │       └── [...nextauth]/
│   │           └── route.ts
│   └── protected/
│       └── page.tsx        # Protected page
└── .env                    # Environment variables
```
