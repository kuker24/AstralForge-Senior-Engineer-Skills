---
name: react-native-flutter
description: Build mobile applications with React Native or Flutter. Use when creating cross-platform mobile apps, choosing between frameworks, or implementing native features.
---

# React Native & Flutter

## When to Use

- Building cross-platform mobile apps
- Sharing code between iOS and Android
- Implementing native features
- Choosing between React Native and Flutter

## Input

- Mobile app requirements
- Platform targets (iOS, Android, web)
- Native feature requirements

## Output

- Mobile application code
- Navigation structure
- State management
- Native module integration

## Checklist

1. **Choose Framework**
   - React Native: JavaScript/TypeScript, React ecosystem
   - Flutter: Dart, custom widgets, high performance
   - Consider: team skills, performance needs, ecosystem

2. **Project Setup**
   - Initialize project
   - Configure TypeScript/Dart
   - Set up navigation
   - Configure state management

3. **UI Components**
   - Create reusable components
   - Implement responsive layouts
   - Handle platform differences
   - Add animations

4. **Native Features**
   - Camera, GPS, notifications
   - File system access
   - Platform-specific code
   - Native modules

## Best Practices

- Use TypeScript (React Native) or Dart (Flutter)
- Implement proper navigation
- Handle platform differences
- Use proper state management
- Optimize performance
- Test on real devices

## Anti-Patterns

❌ Ignoring platform differences
❌ Not handling offline state
❌ Large bundle size
❌ Poor performance
❌ Not testing on real devices

## Validation

- App runs on both platforms
- Navigation works correctly
- Native features function
- Performance is acceptable
- No platform-specific bugs

## Examples

### Example 1: React Native Component
```typescript
// components/UserCard.tsx
import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';

interface User {
  id: string;
  name: string;
  email: string;
}

interface UserCardProps {
  user: User;
  onPress: (userId: string) => void;
}

export function UserCard({ user, onPress }: UserCardProps) {
  return (
    <TouchableOpacity 
      style={styles.card}
      onPress={() => onPress(user.id)}
    >
      <Text style={styles.name}>{user.name}</Text>
      <Text style={styles.email}>{user.email}</Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  card: {
    padding: 16,
    backgroundColor: '#fff',
    borderRadius: 8,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  name: {
    fontSize: 18,
    fontWeight: '600',
  },
  email: {
    fontSize: 14,
    color: '#666',
    marginTop: 4,
  },
});
```

### Example 2: React Native Navigation
```typescript
// navigation/AppNavigator.tsx
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';

const Stack = createNativeStackNavigator();
const Tab = createBottomTabNavigator();

function HomeTabs() {
  return (
    <Tab.Navigator>
      <Tab.Screen name="Home" component={HomeScreen} />
      <Tab.Screen name="Profile" component={ProfileScreen} />
      <Tab.Screen name="Settings" component={SettingsScreen} />
    </Tab.Navigator>
  );
}

export function AppNavigator() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen 
          name="Main" 
          component={HomeTabs}
          options={{ headerShown: false }}
        />
        <Stack.Screen name="UserDetail" component={UserDetailScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
```

### Example 3: Flutter Widget
```dart
// lib/widgets/user_card.dart
import 'package:flutter/material.dart';

class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});
}

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onTap;

  const UserCard({
    Key? key,
    required this.user,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(user.email),
        onTap: onTap,
      ),
    );
  }
}
```

### Example 4: Flutter Navigation
```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/user_detail_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/user-detail': (context) => const UserDetailScreen(),
      },
    );
  }
}
```

## React Native vs Flutter

| Aspect | React Native | Flutter |
|--------|--------------|---------|
| Language | JavaScript/TypeScript | Dart |
| UI Components | Native components | Custom widgets |
| Performance | Good | Excellent |
| Hot Reload | Yes | Yes |
| Ecosystem | Large | Growing |
| Learning Curve | Moderate | Moderate |

## Output Structure

```
# React Native
├── src/
│   ├── components/
│   │   └── UserCard.tsx
│   ├── screens/
│   │   ├── HomeScreen.tsx
│   │   └── UserDetailScreen.tsx
│   ├── navigation/
│   │   └── AppNavigator.tsx
│   ├── store/
│   │   └── userStore.ts
│   └── App.tsx
├── ios/
├── android/
└── package.json

# Flutter
├── lib/
│   ├── widgets/
│   │   └── user_card.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   └── user_detail_screen.dart
│   ├── models/
│   │   └── user.dart
│   └── main.dart
├── ios/
├── android/
└── pubspec.yaml
```
