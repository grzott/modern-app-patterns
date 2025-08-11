# Dependency Injection with React Context

Use a provider as composition root; consume via hooks.

## Pattern

- Create a Services object once.
- Provide via Context at app root.
- Consume with `useX()` hooks; swap in tests.

## Example

```tsx
// services.ts
export type Services = { todos: { list: () => Promise<string[]> } };
export const createServices = (baseUrl: string): Services => ({
  todos: {
    async list() {
      const r = await fetch(`${baseUrl}/todos`);
      return await r.json();
    },
  },
});
```

```tsx
// ServicesProvider.tsx
import React, { createContext, useContext } from "react";
import type { Services } from "./services";

const Ctx = createContext<Services | null>(null);
export function ServicesProvider({
  services,
  children,
}: {
  services: Services;
  children: React.ReactNode;
}) {
  return <Ctx.Provider value={services}>{children}</Ctx.Provider>;
}
export function useServices(): Services {
  const s = useContext(Ctx);
  if (!s) throw new Error("ServicesProvider missing");
  return s;
}
```

```tsx
// usage in a screen
import { useServices } from "./ServicesProvider";
const { todos } = useServices();
```

## Why it works

- Simple DI without extra libraries.
- Easy to override in tests and storybook.

---

## Live end-to-end example (copy/paste)

Create services, provide them at the app root, and consume from a screen.

```tsx
// app/services.ts
export type Services = {
  todos: { list: () => Promise<string[]> };
};
export const createServices = (baseUrl: string): Services => ({
  todos: {
    async list() {
      const r = await fetch(`${baseUrl}/todos`);
      return await r.json();
    },
  },
});
```

```tsx
// app/ServicesProvider.tsx
import React, { createContext, useContext } from "react";
import type { Services } from "./services";

const Ctx = createContext<Services | null>(null);
export function ServicesProvider({
  services,
  children,
}: {
  services: Services;
  children: React.ReactNode;
}) {
  return <Ctx.Provider value={services}>{children}</Ctx.Provider>;
}
export function useServices(): Services {
  const s = useContext(Ctx);
  if (!s) throw new Error("ServicesProvider missing");
  return s;
}
```

```tsx
// App.tsx
import React from "react";
import { ServicesProvider } from "./app/ServicesProvider";
import { createServices } from "./app/services";
import { TodosScreen } from "./screens/TodosScreen";

export default function App() {
  const services = createServices("https://jsonplaceholder.typicode.com");
  return (
    <ServicesProvider services={services}>
      <TodosScreen />
    </ServicesProvider>
  );
}
```

```tsx
// screens/TodosScreen.tsx
import React, { useEffect, useState } from "react";
import { View, Text, ActivityIndicator, FlatList } from "react-native";
import { useServices } from "../app/ServicesProvider";

export function TodosScreen() {
  const { todos } = useServices();
  const [state, set] = useState<
    | { kind: "loading" }
    | { kind: "data"; items: string[] }
    | { kind: "error"; msg: string }
  >({ kind: "loading" });
  useEffect(() => {
    todos
      .list()
      .then((items) => set({ kind: "data", items }))
      .catch((e) => set({ kind: "error", msg: e.message }));
  }, [todos]);
  if (state.kind === "loading") return <ActivityIndicator />;
  if (state.kind === "error") return <Text>{state.msg}</Text>;
  return (
    <FlatList
      data={state.items}
      keyExtractor={(x, i) => String(i)}
      renderItem={({ item }) => <Text>{item}</Text>}
    />
  );
}
```

Notes

- Use a different `services` instance in tests (fake or mock).

## Sandbox copy map

Paste into an Expo app (see sandboxes/react-native-expo):

- app/services.ts — services factory
- app/ServicesProvider.tsx — context provider and hook
- screens/TodosScreen.tsx — consumer UI
- App.tsx — wrap with <ServicesProvider services={...}>
