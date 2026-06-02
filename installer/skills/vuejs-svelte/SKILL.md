---
name: vuejs-svelte
description: Build frontend applications with Vue.js or Svelte. Use when creating reactive UIs, single-page applications, or choosing between Vue and Svelte.
---

# Vue.js & Svelte

## When to Use

- Building reactive user interfaces
- Creating single-page applications
- Implementing component-based architecture
- Choosing between Vue and Svelte

## Input

- UI requirements
- Component specifications
- State management needs

## Output

- Vue/Svelte components
- State management
- Routing configuration
- Build setup

## Checklist

1. **Choose Framework**
   - Vue 3: mature ecosystem, Composition API, Vite
   - Svelte 5: compiler-based, less boilerplate, runes
   - Consider: team experience, ecosystem, performance

2. **Project Setup**
   - Initialize with Vite
   - Configure TypeScript
   - Set up routing (Vue Router/SvelteKit)
   - Configure state management

3. **Components**
   - Create reusable components
   - Implement props and events
   - Use slots (Vue) or snippets (Svelte)
   - Add TypeScript types

4. **State Management**
   - Pinia (Vue) or stores (Svelte)
   - Reactive state
   - Computed properties
   - Side effects

## Best Practices

- Use Composition API (Vue) or runes (Svelte)
- Implement proper TypeScript
- Use single-file components
- Keep components small
- Use proper naming conventions
- Implement lazy loading

## Anti-Patterns

❌ Mixing Options API and Composition API
❌ Overusing global state
❌ Large components
❌ Not using TypeScript
❌ Ignoring accessibility

## Validation

- Components render correctly
- State updates work
- Routing functions properly
- Build succeeds
- TypeScript passes

## Examples

### Example 1: Vue 3 Component
```vue
<!-- components/UserCard.vue -->
<script setup lang="ts">
interface User {
  id: string;
  name: string;
  email: string;
}

const props = defineProps<{
  user: User;
}>();

const emit = defineEmits<{
  (e: 'select', userId: string): void;
}>();

const isSelected = ref(false);

function handleSelect() {
  isSelected.value = !isSelected.value;
  emit('select', props.user.id);
}
</script>

<template>
  <div 
    class="user-card"
    :class="{ selected: isSelected }"
    @click="handleSelect"
  >
    <h3>{{ user.name }}</h3>
    <p>{{ user.email }}</p>
  </div>
</template>

<style scoped>
.user-card {
  padding: 1rem;
  border: 1px solid #ccc;
  border-radius: 8px;
  cursor: pointer;
}

.user-card.selected {
  border-color: #3b82f6;
  background: #eff6ff;
}
</style>
```

### Example 2: Vue 3 Store (Pinia)
```typescript
// stores/user.ts
import { defineStore } from 'pinia';

export const useUserStore = defineStore('user', () => {
  const users = ref<User[]>([]);
  const loading = ref(false);
  const error = ref<string | null>(null);

  const activeUsers = computed(() => 
    users.value.filter(u => u.status === 'active')
  );

  async function fetchUsers() {
    loading.value = true;
    error.value = null;
    
    try {
      const response = await fetch('/api/users');
      users.value = await response.json();
    } catch (e) {
      error.value = e.message;
    } finally {
      loading.value = false;
    }
  }

  function addUser(user: User) {
    users.value.push(user);
  }

  return {
    users,
    loading,
    error,
    activeUsers,
    fetchUsers,
    addUser,
  };
});
```

### Example 3: Svelte 5 Component
```svelte
<!-- components/UserCard.svelte -->
<script lang="ts">
  interface User {
    id: string;
    name: string;
    email: string;
  }

  let { user, onSelect }: { 
    user: User; 
    onSelect: (userId: string) => void;
  } = $props();

  let isSelected = $state(false);

  function handleClick() {
    isSelected = !isSelected;
    onSelect(user.id);
  }
</script>

<div 
  class="user-card" 
  class:selected={isSelected}
  onclick={handleClick}
>
  <h3>{user.name}</h3>
  <p>{user.email}</p>
</div>

<style>
  .user-card {
    padding: 1rem;
    border: 1px solid #ccc;
    border-radius: 8px;
    cursor: pointer;
  }

  .user-card.selected {
    border-color: #3b82f6;
    background: #eff6ff;
  }
</style>
```

### Example 4: Svelte Store
```typescript
// stores/user.ts
import { writable, derived } from 'svelte/store';

export const users = writable<User[]>([]);
export const loading = writable(false);
export const error = writable<string | null>(null);

export const activeUsers = derived(users, ($users) =>
  $users.filter(u => u.status === 'active')
);

export async function fetchUsers() {
  loading.set(true);
  error.set(null);
  
  try {
    const response = await fetch('/api/users');
    const data = await response.json();
    users.set(data);
  } catch (e) {
    error.set(e.message);
  } finally {
    loading.set(false);
  }
}
```

## Vue vs Svelte

| Aspect | Vue 3 | Svelte 5 |
|--------|-------|----------|
| Approach | Virtual DOM | Compiler |
| Bundle Size | ~40KB | ~10KB |
| Learning Curve | Moderate | Low |
| Ecosystem | Large | Growing |
| Reactivity | ref/reactive | runes ($state, $derived) |
| Components | SFC (.vue) | SFC (.svelte) |

## Output Structure

```
# Vue Project
├── src/
│   ├── components/
│   │   └── UserCard.vue
│   ├── stores/
│   │   └── user.ts
│   ├── views/
│   │   └── Users.vue
│   ├── router/
│   │   └── index.ts
│   └── main.ts
├── vite.config.ts
└── tsconfig.json

# Svelte Project
├── src/
│   ├── lib/
│   │   ├── components/
│   │   │   └── UserCard.svelte
│   │   └── stores/
│   │       └── user.ts
│   ├── routes/
│   │   └── +page.svelte
│   └── app.html
├── svelte.config.js
└── vite.config.ts
```
