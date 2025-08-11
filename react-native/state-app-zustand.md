# App State with Zustand

Minimal, fast global state without reducers or boilerplate. Great for feature-scoped stores and UI coordination; pair with React Query for server state.

## Install

- yarn add zustand (or npm i zustand)

## Pattern

- Create a typed store with actions and selectors.
- Use hooks to read slices; avoid re-renders via selectors/shallow.
- Persist optionally with zustand/middleware.

## Basic example

```ts
// stores/todos.ts
import { create } from "zustand";
import { devtools } from "zustand/middleware";

type Todo = { id: string; title: string; done: boolean };

type State = {
  items: Todo[];
  add: (title: string) => void;
  toggle: (id: string) => void;
  clear: () => void;
};

export const useTodos = create<State>()(
  devtools(
    (set) => ({
      items: [],
      add: (title) =>
        set((s) => ({
          items: [...s.items, { id: String(Date.now()), title, done: false }],
        })),
      toggle: (id) =>
        set((s) => ({
          items: s.items.map((t) =>
            t.id === id ? { ...t, done: !t.done } : t
          ),
        })),
      clear: () => set({ items: [] }),
    }),
    { name: "todos" }
  )
);
```

```tsx
// screens/TodosZustandScreen.tsx
import React, { useState } from "react";
import {
  View,
  Text,
  Button,
  TextInput,
  FlatList,
  Pressable,
} from "react-native";
import { useTodos } from "../stores/todos";

export function TodosZustandScreen() {
  const items = useTodos((s) => s.items);
  const add = useTodos((s) => s.add);
  const toggle = useTodos((s) => s.toggle);
  const clear = useTodos((s) => s.clear);

  const [text, setText] = useState("");

  return (
    <View style={{ padding: 16 }}>
      <View style={{ flexDirection: "row", gap: 8 }}>
        <TextInput
          value={text}
          onChangeText={setText}
          placeholder="Add todo"
          style={{ flex: 1, borderWidth: 1, padding: 8 }}
        />
        <Button
          title="Add"
          onPress={() => {
            if (text.trim()) {
              add(text.trim());
              setText("");
            }
          }}
        />
        <Button title="Clear" onPress={clear} />
      </View>
      <FlatList
        data={items}
        keyExtractor={(t) => t.id}
        renderItem={({ item }) => (
          <Pressable
            onPress={() => toggle(item.id)}
            style={{ paddingVertical: 8 }}
          >
            <Text
              style={{
                textDecorationLine: item.done ? "line-through" : "none",
              }}
            >
              {item.title}
            </Text>
          </Pressable>
        )}
      />
    </View>
  );
}
```

## Selectors and shallow comparison

```ts
import { shallow } from "zustand/shallow";
const [count, double] = useCounter((s) => [s.count, s.count * 2], shallow);
```

## Persisting state

```ts
import { create } from "zustand";
import { persist, createJSONStorage } from "zustand/middleware";
import AsyncStorage from "@react-native-async-storage/async-storage";

export const useSettings = create(
  persist(
    (set) => ({
      theme: "light" as "light" | "dark",
      setTheme: (t: "light" | "dark") => set({ theme: t }),
    }),
    {
      name: "settings",
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);
```

## With React Query

- Keep server data in React Query; use Zustand for UI state, filters, selections.

## Testing

```ts
// simple store test idea
import { act } from "@testing-library/react";
import { useTodos } from "./stores/todos";

act(() => useTodos.getState().add("Item"));
expect(useTodos.getState().items).toHaveLength(1);
```

## Tips

- Co-locate small stores per feature instead of a single global monolith.
- Use selectors to avoid unnecessary re-renders.
- Devtools middleware helps during development; remove or scope for prod.
