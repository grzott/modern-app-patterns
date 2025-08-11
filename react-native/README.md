# React Native (TypeScript) Patterns

Quick, modder-friendly recipes for common React Native patterns. Copy, paste, tweak.

- Architecture & State
  - [MVVM + UDF (hooks + state machines)](./architecture-mvvm-udf.md)
  - [App State with Redux Toolkit](./state-app-redux-toolkit.md)
  - [App State with Zustand](./state-app-zustand.md)
  - [Server State with React Query](./state-server-react-query.md)
- Data & DI
  - [Repository + DTO mapping](./repository-and-dto-mapping.md)
  - [DI with React Context](./di-with-context.md)
  - [Local caching (AsyncStorage/MMKV)](./caching-asyncstorage-mmkv.md)
- UI & Navigation
  - [React Navigation basics](./navigation-react-navigation.md)
  - [Expo Router 101](./navigation-expo-router-101.md)
  - [Compound Components](./component-compound-components.md)

Tip: keep examples in a `/sandbox` app and promote stable pieces into `core/`.

See also: `../sandboxes/react-native-expo` for a minimal Expo starter. Wrap your root with `NavigationContainer` and/or `QueryClientProvider` as noted in each guide.

## Try it

Expo (recommended on Windows)

```powershell
# 1) Create a sandbox app
npx create-expo-app@latest rn-sandbox
cd rn-sandbox

# 2) Install libs as needed per pattern (pick what you use)
npx expo install @tanstack/react-query
npx expo install @react-navigation/native @react-navigation/native-stack react-native-screens react-native-safe-area-context
npx expo install @react-native-async-storage/async-storage
npx expo install react-native-mmkv
npx expo install expo-router # only for the Expo Router guide

# 3) Run
npx expo start
```

Then copy files from a pattern page into your `app/` or `src/` folders (e.g., screens/, hooks/, navigation/) and tweak imports. For React Navigation, wrap your root with `NavigationContainer`. For React Query, wrap with a `QueryClientProvider`.
