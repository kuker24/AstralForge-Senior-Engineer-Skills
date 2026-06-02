---
name: websocket
description: Implement real-time communication with WebSocket or Socket.IO. Use when building chat, live updates, notifications, or collaborative features.
---

# WebSocket & Socket.IO

## When to Use

- Building real-time chat applications
- Implementing live notifications
- Creating collaborative editing
- Live dashboards and updates
- Gaming applications

## Input

- Real-time requirements
- Event specifications
- Scaling needs

## Output

- WebSocket server configuration
- Event handlers
- Room management
- Authentication middleware
- Client integration

## Checklist

1. **Server Setup**
   - Install Socket.IO or ws
   - Configure CORS
   - Set up authentication
   - Configure transports

2. **Event Design**
   - Define event names (namespaced)
   - Design message format
   - Implement acknowledgments
   - Handle errors

3. **Room Management**
   - Create/join/leave rooms
   - Broadcast to rooms
   - Private messaging
   - Room metadata

4. **Scaling**
   - Use Redis adapter for multi-server
   - Implement sticky sessions
   - Handle reconnection
   - Monitor connections

## Best Practices

- Namespace events
- Use rooms for grouping
- Implement authentication handshake
- Handle reconnection gracefully
- Use acknowledgments for reliability
- Implement rate limiting
- Monitor connection count

## Anti-Patterns

❌ Broadcasting without authorization
❌ No reconnection handling
❌ Unbounded event listeners
❌ No rate limiting
❌ Ignoring error events
❌ Not using namespaces

## Validation

- Events fire correctly
- Rooms work as expected
- Authentication prevents unauthorized access
- Reconnection works
- Rate limiting prevents abuse

## Examples

### Example 1: Socket.IO Server
```typescript
// lib/socket.ts
import { Server } from 'socket.io';
import { createServer } from 'http';
import { verifyToken } from './jwt';

export function initializeSocket(httpServer: any) {
  const io = new Server(httpServer, {
    cors: {
      origin: process.env.CLIENT_URL,
      credentials: true,
    },
    transports: ['websocket', 'polling'],
  });

  // Authentication middleware
  io.use(async (socket, next) => {
    const token = socket.handshake.auth.token;
    if (!token) {
      return next(new Error('Authentication required'));
    }

    try {
      const user = await verifyToken(token);
      socket.data.user = user;
      next();
    } catch (error) {
      next(new Error('Invalid token'));
    }
  });

  // Connection handler
  io.on('connection', (socket) => {
    console.log(`User connected: ${socket.data.user.id}`);

    // Join user's personal room
    socket.join(`user:${socket.data.user.id}`);

    // Chat events
    socket.on('chat:join', (roomId) => {
      socket.join(`chat:${roomId}`);
      socket.to(`chat:${roomId}`).emit('chat:user-joined', {
        userId: socket.data.user.id,
        username: socket.data.user.name,
      });
    });

    socket.on('chat:message', async (data) => {
      const message = {
        id: Date.now(),
        userId: socket.data.user.id,
        username: socket.data.user.name,
        content: data.content,
        timestamp: new Date(),
      };

      // Save to database
      await saveMessage(data.roomId, message);

      // Broadcast to room
      io.to(`chat:${data.roomId}`).emit('chat:message', message);
    });

    socket.on('chat:leave', (roomId) => {
      socket.leave(`chat:${roomId}`);
      socket.to(`chat:${roomId}`).emit('chat:user-left', {
        userId: socket.data.user.id,
      });
    });

    // Typing indicator
    socket.on('chat:typing', (roomId) => {
      socket.to(`chat:${roomId}`).emit('chat:typing', {
        userId: socket.data.user.id,
        username: socket.data.user.name,
      });
    });

    socket.on('disconnect', () => {
      console.log(`User disconnected: ${socket.data.user.id}`);
    });
  });

  return io;
}
```

### Example 2: Client Integration
```typescript
// lib/socket-client.ts
import { io, Socket } from 'socket.io-client';

let socket: Socket;

export function connectSocket(token: string) {
  socket = io(process.env.NEXT_PUBLIC_WS_URL, {
    auth: { token },
    transports: ['websocket'],
    reconnection: true,
    reconnectionAttempts: 5,
    reconnectionDelay: 1000,
  });

  socket.on('connect', () => {
    console.log('Connected to server');
  });

  socket.on('disconnect', (reason) => {
    console.log('Disconnected:', reason);
  });

  socket.on('connect_error', (error) => {
    console.error('Connection error:', error.message);
  });

  return socket;
}

export function joinChat(roomId: string) {
  socket.emit('chat:join', roomId);
}

export function sendMessage(roomId: string, content: string) {
  socket.emit('chat:message', { roomId, content });
}

export function onMessage(callback: (message: any) => void) {
  socket.on('chat:message', callback);
}

export function onTyping(callback: (data: any) => void) {
  socket.on('chat:typing', callback);
}

export function disconnectSocket() {
  if (socket) {
    socket.disconnect();
  }
}
```

### Example 3: Event Namespacing
```typescript
// Event naming convention
const EVENTS = {
  CHAT: {
    JOIN: 'chat:join',
    LEAVE: 'chat:leave',
    MESSAGE: 'chat:message',
    TYPING: 'chat:typing',
    USER_JOINED: 'chat:user-joined',
    USER_LEFT: 'chat:user-left',
  },
  NOTIFICATION: {
    SEND: 'notification:send',
    RECEIVED: 'notification:received',
    READ: 'notification:read',
  },
  PRESENCE: {
    ONLINE: 'presence:online',
    OFFLINE: 'presence:offline',
    STATUS: 'presence:status',
  },
} as const;
```

### Example 4: Redis Adapter for Scaling
```typescript
// lib/socket-cluster.ts
import { Server } from 'socket.io';
import { createAdapter } from '@socket.io/redis-adapter';
import { createClient } from 'redis';

export async function createClusteredSocketIO(httpServer: any) {
  const pubClient = createClient({ url: process.env.REDIS_URL });
  const subClient = pubClient.duplicate();

  await Promise.all([pubClient.connect(), subClient.connect()]);

  const io = new Server(httpServer, {
    cors: {
      origin: process.env.CLIENT_URL,
      credentials: true,
    },
  });

  io.adapter(createAdapter(pubClient, subClient));

  return io;
}
```

## Event Design Patterns

| Pattern | Use Case | Example |
|---------|----------|---------|
| Request-Response | Acknowledged operations | `chat:message` → `chat:message:sent` |
| Broadcast | One-to-many | `chat:message` to room |
| Private | One-to-one | `user:${id}:notification` |
| Namespace | Feature separation | `/chat`, `/notifications` |

## Output Structure

```
├── server/
│   ├── lib/
│   │   ├── socket.ts        # Socket.IO setup
│   │   ├── handlers/        # Event handlers
│   │   └── middleware/       # Auth middleware
│   └── index.ts
├── client/
│   ├── lib/
│   │   └── socket-client.ts # Client connection
│   └── hooks/
│       └── useSocket.ts     # React hook
└── shared/
    └── events.ts            # Event definitions
```
