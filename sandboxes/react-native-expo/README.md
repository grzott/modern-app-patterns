# React Native (Expo) Sandbox

Minimal Expo app shell; paste pattern files into `app/` or `src/`.

## Setup

```powershell
# Create an Expo app and copy this folder's contents into it
npx create-expo-app@latest rn-sandbox
cd rn-sandbox

# Install commonly used libs; add more per pattern
npx expo install @tanstack/react-query
npx expo install @react-navigation/native @react-navigation/native-stack react-native-screens react-native-safe-area-context
npx expo install @react-native-async-storage/async-storage
npx expo install react-native-mmkv
npx expo install expo-router

# Start
npx expo start
```

## Files to add

- app/QueryProvider.tsx (React Query)
- app/ServicesProvider.tsx (DI)
- screens/\* (from guides)
- navigation/\* (React Navigation)
- app/ (Expo Router routes)
