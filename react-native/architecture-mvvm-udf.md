# MVVM + UDF in React Native (TypeScript)

Goal: Model UI as a function of state with a ViewModel-like hook and a discriminated-union state machine.

## Pattern

- View: functional component renders by `state` only.
- ViewModel: hook encapsulates actions, effects, and state transitions.
- UDF: events -> reducer -> new state; effects handled in hook.

## Example

```tsx
// view-model.ts
import { useEffect, useReducer, useCallback } from "react";

type State =
  | { kind: "idle" }
  | { kind: "loading" }
  | { kind: "success"; items: string[] }
  | { kind: "error"; message: string };

type Event =
  | { type: "LOAD" }
  | { type: "LOADED"; items: string[] }
  | { type: "FAILED"; message: string };

function reducer(state: State, ev: Event): State {
  switch (ev.type) {
    case "LOAD":
      return { kind: "loading" };
    case "LOADED":
      return { kind: "success", items: ev.items };
    case "FAILED":
      return { kind: "error", message: ev.message };
    default:
      return state;
  }
}

export function useTodos(api: { list: () => Promise<string[]> }) {
  const [state, dispatch] = useReducer(reducer, { kind: "idle" } as State);

  const load = useCallback(async () => {
    dispatch({ type: "LOAD" });
    try {
      const items = await api.list();
      dispatch({ type: "LOADED", items });
    } catch (e: any) {
      dispatch({ type: "FAILED", message: e?.message ?? "Unknown error" });
    }
  }, [api]);

  useEffect(() => {
    if (state.kind === "idle") load();
  }, [state.kind, load]);

  return { state, load };
}
```

```tsx
// TodosScreen.tsx
import React from "react";
import { View, Text, Button, ActivityIndicator, FlatList } from "react-native";
import { useTodos } from "./view-model";

export function TodosScreen({
  api,
}: {
  api: { list: () => Promise<string[]> };
}) {
  const { state, load } = useTodos(api);

  if (state.kind === "loading") return <ActivityIndicator />;
  if (state.kind === "error")
    return (
      <View>
        <Text>{state.message}</Text>
        <Button title="Retry" onPress={load} />
      </View>
    );
  if (state.kind === "success")
    return (
      <FlatList
        data={state.items}
        keyExtractor={(x) => x}
        renderItem={({ item }) => <Text>{item}</Text>}
      />
    );
  return <Button title="Load" onPress={load} />;
}
```

## Why it works

- Predictable states; easy tests.
- Side effects isolated in the hook.
- Maps 1:1 to MVVM without heavy frameworks.

---

## Live end-to-end example (copy/paste)

Hook as ViewModel + simple screen using a fake API.

```tsx
// app/api.ts
export type Api = { list: () => Promise<string[]> };
export const fakeApi: Api = {
  async list() {
    return ["Milk", "Bread", "Eggs"];
  },
};
```

```tsx
// app/useTodosVM.ts
import { useEffect, useReducer } from "react";
import type { Api } from "./api";

type State =
  | { kind: "idle" }
  | { kind: "loading" }
  | { kind: "ok"; items: string[] }
  | { kind: "err"; msg: string };
type Ev =
  | { type: "LOAD" }
  | { type: "OK"; items: string[] }
  | { type: "ERR"; msg: string };

function reducer(s: State, e: Ev): State {
  switch (e.type) {
    case "LOAD":
      return { kind: "loading" };
    case "OK":
      return { kind: "ok", items: e.items };
    case "ERR":
      return { kind: "err", msg: e.msg };
  }
}

export function useTodosVM(api: Api) {
  const [state, dispatch] = useReducer(reducer, { kind: "idle" } as State);
  useEffect(() => {
    if (state.kind === "idle") {
      (async () => {
        dispatch({ type: "LOAD" });
        try {
          const items = await api.list();
          dispatch({ type: "OK", items });
        } catch (e: any) {
          dispatch({ type: "ERR", msg: e?.message ?? "Oops" });
        }
      })();
    }
  }, [state.kind, api]);
  return { state };
}
```

```tsx
// screens/TodosMVVM.tsx
import React from "react";
import { ActivityIndicator, FlatList, Text, View } from "react-native";
import { fakeApi } from "../app/api";
import { useTodosVM } from "../app/useTodosVM";

export function TodosMVVM() {
  const { state } = useTodosVM(fakeApi);
  if (state.kind === "loading") return <ActivityIndicator />;
  if (state.kind === "err") return <Text>{state.msg}</Text>;
  if (state.kind === "ok")
    return (
      <FlatList
        data={state.items}
        keyExtractor={(x) => x}
        renderItem={({ item }) => <Text>{item}</Text>}
      />
    );
  return <View />;
}
```

Notes

- Swap `fakeApi` with the real repo without changing the screen.

## Sandbox copy map

Paste into an Expo app (see sandboxes/react-native-expo):

- app/api.ts and app/useTodosVM.ts — ViewModel-like hook and API
- screens/TodosMVVM.tsx — screen component
- App.tsx — render <TodosMVVM />
