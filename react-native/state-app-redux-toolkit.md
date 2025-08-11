# App State with Redux Toolkit

Use Redux Toolkit (RTK) for global app state and predictable updates.

## Pattern

- Slice per feature.
- Thunks for async or use RTK Query for server state.
- Co-locate actions, reducer, selectors.

## Example

```ts
// features/todos/slice.ts
import { createSlice, createAsyncThunk, PayloadAction } from "@reduxjs/toolkit";

export const fetchTodos = createAsyncThunk("todos/fetch", async () => {
  const res = await fetch("https://example.com/todos");
  return (await res.json()) as string[];
});

type TodosState = { items: string[]; loading: boolean; error?: string };
const initialState: TodosState = { items: [], loading: false };

const todosSlice = createSlice({
  name: "todos",
  initialState,
  reducers: {
    add(state, action: PayloadAction<string>) {
      state.items.push(action.payload);
    },
  },
  extraReducers: (b) => {
    b.addCase(fetchTodos.pending, (s) => {
      s.loading = true;
      s.error = undefined;
    })
      .addCase(fetchTodos.fulfilled, (s, a) => {
        s.loading = false;
        s.items = a.payload;
      })
      .addCase(fetchTodos.rejected, (s, a) => {
        s.loading = false;
        s.error = a.error.message;
      });
  },
});

export const { add } = todosSlice.actions;
export default todosSlice.reducer;
```

```ts
// store.ts
import { configureStore } from "@reduxjs/toolkit";
import todos from "./features/todos/slice";

export const store = configureStore({ reducer: { todos } });
export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
```

## Why it works

- Batteries-included tooling; less boilerplate.
- DevTools time travel; predictable updates.

---

## Live end-to-end example (copy/paste)

Wire the store, expose typed hooks, and render a screen that loads todos via thunk.

```ts
// app/store.ts
import { configureStore } from "@reduxjs/toolkit";
import todos from "../features/todos/slice";

export const store = configureStore({ reducer: { todos } });
export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
```

```ts
// app/hooks.ts
import { TypedUseSelectorHook, useDispatch, useSelector } from "react-redux";
import type { RootState, AppDispatch } from "./store";

export const useAppDispatch: () => AppDispatch = useDispatch;
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;
```

```tsx
// App.tsx
import React from "react";
import { Provider } from "react-redux";
import { store } from "./app/store";
import { TodosScreen } from "./features/todos/TodosScreen";

export default function App() {
  return (
    <Provider store={store}>
      <TodosScreen />
    </Provider>
  );
}
```

{% raw %}
```tsx
// features/todos/TodosScreen.tsx
import React, { useEffect } from "react";
import { View, Text, Button, ActivityIndicator, FlatList } from "react-native";
import { useAppDispatch, useAppSelector } from "../../app/hooks";
import { add, fetchTodos } from "./slice";

export function TodosScreen() {
  const dispatch = useAppDispatch();
  const { items, loading, error } = useAppSelector((s) => s.todos);

  useEffect(() => {
    dispatch(fetchTodos());
  }, [dispatch]);

  if (loading) return <ActivityIndicator />;
  if (error)
    return (
      <View>
        <Text>{error}</Text>
        <Button title="Retry" onPress={() => dispatch(fetchTodos())} />
      </View>
    );
  return (
    <View style={{ padding: 16 }}>
      <Button title="Add" onPress={() => dispatch(add("Learn RTK"))} />
      <FlatList
        data={items}
        keyExtractor={(x, i) => String(i)}
        renderItem={({ item }) => <Text>{item}</Text>}
      />
    </View>
  );
}
```
{% endraw %}

Notes

- Keep server state in RTK Query or React Query; use slices for app/UI state.

## Sandbox copy map

Paste into an Expo app (see sandboxes/react-native-expo):

- features/todos/slice.ts — slice and thunk
- app/store.ts and app/hooks.ts — store and typed hooks
- features/todos/TodosScreen.tsx — screen UI
- App.tsx — wrap with <Provider store={store}>
