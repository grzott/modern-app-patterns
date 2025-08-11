# Server State with React Query

Manage remote data (fetch/cache/invalidate) separately from local UI state.

## Pattern

- Keys identify resources.
- Queries cache, mutations invalidate.
- Keep DTO → UI mapping near the query.

## Example

```tsx
// useTodos.ts
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";

const todosKey = ["todos"];

async function fetchTodos() {
  const res = await fetch("https://example.com/todos");
  if (!res.ok) throw new Error("Network error");
  return (await res.json()) as { id: string; title: string }[];
}

export function useTodos() {
  const qc = useQueryClient();
  const query = useQuery({ queryKey: todosKey, queryFn: fetchTodos });

  const addTodo = useMutation({
    mutationFn: async (title: string) => {
      const res = await fetch("https://example.com/todos", {
        method: "POST",
        body: JSON.stringify({ title }),
      });
      if (!res.ok) throw new Error("Failed to add");
      return await res.json();
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: todosKey }),
  });

  return { ...query, addTodo };
}
```

## Why it works

- Normalizes server concerns; simple cache invalidation.
- Great DX with retries, stale-while-revalidate.

---

## Live end-to-end example (copy/paste)

Provider + query hook + screen wired to an API.

```tsx
// app/QueryProvider.tsx
import React from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

const client = new QueryClient();
export const QueryProvider: React.FC<React.PropsWithChildren> = ({
  children,
}) => <QueryClientProvider client={client}>{children}</QueryClientProvider>;
```

```tsx
// App.tsx
import React from "react";
import { QueryProvider } from "./app/QueryProvider";
import { TodosRQScreen } from "./screens/TodosRQScreen";

export default function App() {
  return (
    <QueryProvider>
      <TodosRQScreen />
    </QueryProvider>
  );
}
```

{% raw %}
```tsx
// screens/TodosRQScreen.tsx
import React from "react";
import { View, Text, Button, ActivityIndicator, FlatList } from "react-native";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";

const key = ["todos"];

async function fetchTodos() {
  const r = await fetch("https://jsonplaceholder.typicode.com/todos?_limit=10");
  if (!r.ok) throw new Error("Network");
  const data: { id: number; title: string; completed: boolean }[] =
    await r.json();
  return data.map((d) => ({ id: String(d.id), title: d.title }));
}

export function TodosRQScreen() {
  const qc = useQueryClient();
  const q = useQuery({ queryKey: key, queryFn: fetchTodos });
  const add = useMutation({
    mutationFn: async (title: string) => {
      const r = await fetch("https://jsonplaceholder.typicode.com/todos", {
        method: "POST",
        body: JSON.stringify({ title }),
      });
      if (!r.ok) throw new Error("Add failed");
      return r.json();
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: key }),
  });

  if (q.isLoading) return <ActivityIndicator />;
  if (q.error)
    return (
      <View>
        <Text>{(q.error as Error).message}</Text>
        <Button title="Retry" onPress={() => q.refetch()} />
      </View>
    );
  return (
    <View style={{ padding: 16 }}>
      <Button title="Add" onPress={() => add.mutate("New Task")} />
      <FlatList
        data={q.data}
        keyExtractor={(x) => x.id}
        renderItem={({ item }) => <Text>{item.title}</Text>}
      />
    </View>
  );
}
```
{% endraw %}

Notes

- Keep domain mapping in the query fn or a small mapper.

## Sandbox copy map

Paste into an Expo app (see sandboxes/react-native-expo):

- app/QueryProvider.tsx — provider setup
- screens/TodosRQScreen.tsx — the screen component
- App.tsx — wrap your root with <QueryProvider> and render the screen
