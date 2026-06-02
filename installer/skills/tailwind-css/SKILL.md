---
name: tailwind-css
description: Build responsive UI with Tailwind CSS. Use when styling components, creating design systems, or implementing utility-first CSS patterns.
---

# Tailwind CSS

## When to Use

- Styling React/Next.js/Vue components
- Creating responsive layouts
- Implementing design systems
- Building component libraries

## Input

- Design requirements or mockups
- Component specifications
- Brand guidelines (colors, typography)

## Output

- Styled components with Tailwind classes
- Responsive layouts
- Custom theme configuration
- Reusable component patterns

## Checklist

1. **Setup**
   - Install Tailwind CSS
   - Configure tailwind.config.js
   - Set up content paths
   - Configure custom theme

2. **Component Styling**
   - Use utility classes for styling
   - Extract components for reuse
   - Use @apply for complex patterns
   - Implement responsive design

3. **Design System**
   - Define color palette
   - Set typography scale
   - Configure spacing system
   - Create component variants

4. **Accessibility**
   - Use semantic HTML
   - Add focus states
   - Ensure color contrast
   - Support dark mode

## Best Practices

- Use utility classes directly
- Extract components for reuse
- Use @apply sparingly
- Leverage Tailwind's responsive prefixes
- Use arbitrary values when needed
- Implement dark mode with dark: prefix
- Use Tailwind plugins for extensions

## Anti-Patterns

❌ Class soup without structure
❌ Overusing @apply
❌ Not using responsive prefixes
❌ Ignoring accessibility
❌ Hardcoding colors instead of using theme
❌ Not purging unused CSS

## Validation

- All components render correctly
- Responsive breakpoints work
- Dark mode functions properly
- CSS bundle size is optimized
- No unused styles in production

## Examples

### Example 1: Responsive Card
```html
<div class="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6 
            hover:shadow-lg transition-shadow duration-200
            sm:max-w-sm md:max-w-md lg:max-w-lg">
  <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
    Card Title
  </h3>
  <p class="mt-2 text-gray-600 dark:text-gray-300">
    Card description goes here.
  </p>
  <button class="mt-4 px-4 py-2 bg-blue-500 text-white rounded
                 hover:bg-blue-600 focus:outline-none focus:ring-2
                 focus:ring-blue-500 focus:ring-offset-2">
    Learn More
  </button>
</div>
```

### Example 2: Custom Theme
```javascript
// tailwind.config.js
module.exports = {
  content: ['./src/**/*.{js,ts,jsx,tsx}'],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
        },
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
}
```

### Example 3: Component with Variants
```typescript
// Button.tsx
import { cva, type VariantProps } from 'class-variance-authority';

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md font-medium transition-colors',
  {
    variants: {
      variant: {
        primary: 'bg-blue-500 text-white hover:bg-blue-600',
        secondary: 'bg-gray-200 text-gray-900 hover:bg-gray-300',
        outline: 'border border-gray-300 bg-transparent hover:bg-gray-100',
      },
      size: {
        sm: 'h-8 px-3 text-sm',
        md: 'h-10 px-4 text-base',
        lg: 'h-12 px-6 text-lg',
      },
    },
    defaultVariants: {
      variant: 'primary',
      size: 'md',
    },
  }
);

interface ButtonProps extends VariantProps<typeof buttonVariants> {
  children: React.ReactNode;
  onClick?: () => void;
}

export function Button({ children, variant, size, ...props }: ButtonProps) {
  return (
    <button className={buttonVariants({ variant, size })} {...props}>
      {children}
    </button>
  );
}
```

## Output Structure

```
├── tailwind.config.js
├── postcss.config.js
├── src/
│   ├── components/
│   │   ├── Button.tsx
│   │   ├── Card.tsx
│   │   └── Layout.tsx
│   ├── styles/
│   │   └── globals.css
│   └── utils/
│       └── cn.ts
```
