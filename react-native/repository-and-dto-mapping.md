# Repository + DTO Mapping

Abstract data access and map transport objects to domain models.

## Pattern

- Repository is an interface used by ViewModels.
- Data sources: Remote (HTTP) and Local (storage/db).
- Mappers translate DTOs ↔ Domain.

## Example

```ts
// domain.ts
export type Todo = { id: string; title: string; done: boolean };
export interface TodosRepo {
  list(): Promise<Todo[]>;
}
```

```ts
// dto.ts
export type TodoDTO = { id: string; name: string; completed: boolean };
export const toDomain = (dto: TodoDTO): import("./domain").Todo => ({
  id: dto.id,
  title: dto.name,
  done: dto.completed,
});
```

```ts
// repo-http.ts
import { TodosRepo } from "./domain";
import { TodoDTO, toDomain } from "./dto";

export class HttpTodosRepo implements TodosRepo {
  constructor(private baseUrl: string) {}
  async list() {
    const res = await fetch(`${this.baseUrl}/todos`);
    if (!res.ok) throw new Error("Network error");
    const data = (await res.json()) as TodoDTO[];
    return data.map(toDomain);
  }
}
```

## Why it works

- UI decoupled from transport format.
- Swap data sources without touching UI.

---

## Live end-to-end example (copy/paste)

Build a tiny feature using a Repository that maps DTOs → domain and can be wrapped with a simple cache. You can drop these files into any RN app.

### 1) Domain contract

```ts
// domain/todos.ts
export type Todo = { id: string; title: string; done: boolean };

export interface TodosRepo {
  list(): Promise<Todo[]>;
}
```

### 2) Transport DTO + mapper

```ts
// data/todos.dto.ts
export type TodoDTO = { id: string; name: string; completed: boolean };

export function toDomain(dto: TodoDTO): import("../domain/todos").Todo {
  return { id: dto.id, title: dto.name, done: dto.completed };
}

export function toDomainList(list: TodoDTO[]) {
  return list.map(toDomain);
}
```

### 3) API client helper

```ts
// data/http.ts
export async function getJson<T>(url: string, init?: RequestInit): Promise<T> {
  const res = await fetch(url, init);
  if (!res.ok) throw new Error(`${res.status} ${res.statusText}`);
  return (await res.json()) as T;
}
```

### 4) HTTP repository implementation

```ts
// data/todos.repo.http.ts
import type { TodosRepo } from "../domain/todos";
import type { TodoDTO } from "./todos.dto";
import { getJson } from "./http";
import { toDomainList } from "./todos.dto";

export class HttpTodosRepo implements TodosRepo {
  constructor(private baseUrl: string) {}
  async list() {
    const data = await getJson<TodoDTO[]>(`${this.baseUrl}/todos`);
    return toDomainList(data);
  }
}
```

### 5) Optional: lightweight cached repository wrapper

Pluggable storage adapter lets you swap AsyncStorage or MMKV.

```ts
// data/storage.ts
export type StorageAdapter = {
  getItem(key: string): Promise<string | null>;
  setItem(key: string, value: string): Promise<void>;
};

// AsyncStorage adapter
export function createAsyncStorageAdapter(): StorageAdapter {
  // install: yarn add @react-native-async-storage/async-storage
  // import in app: react-native-async-storage/async-storage
  // kept dynamic here to avoid ESM issues in docs
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const AsyncStorage =
    require("@react-native-async-storage/async-storage").default;
  return {
    async getItem(k) {
      return AsyncStorage.getItem(k);
    },
    async setItem(k, v) {
      return AsyncStorage.setItem(k, v);
    },
  };
}

// MMKV adapter (sync under the hood, wrapped as Promise)
export function createMMKVAdapter(): StorageAdapter {
  // install: yarn add react-native-mmkv
  const { MMKV } =
    require("react-native-mmkv") as typeof import("react-native-mmkv");
  const storage = new MMKV({ id: "app-cache" });
  return {
    async getItem(k) {
      return storage.getString(k) ?? null;
    },
    async setItem(k, v) {
      storage.set(k, v);
    },
  };
}
```

```ts
// data/todos.repo.cached.ts
import type { TodosRepo, Todo } from "../domain/todos";
import type { StorageAdapter } from "./storage";

export class CachedTodosRepo implements TodosRepo {
  constructor(
    private inner: TodosRepo,
    private storage: StorageAdapter,
    private ttlMs = 60_000
  ) {}

  private key = "todos-cache-v1";

  async list(): Promise<Todo[]> {
    const cached = await this.storage.getItem(this.key);
    if (cached) {
      try {
        const parsed = JSON.parse(cached) as { ts: number; items: Todo[] };
        if (Date.now() - parsed.ts < this.ttlMs) return parsed.items;
      } catch {
        /* ignore parse errors */
      }
    }

    const fresh = await this.inner.list();
    await this.storage.setItem(
      this.key,
      JSON.stringify({ ts: Date.now(), items: fresh })
    );
    return fresh;
  }
}
```

### 6) Hook to consume the repository

```tsx
// hooks/useTodos.ts
import { useEffect, useState } from "react";
import type { TodosRepo, Todo } from "../domain/todos";

type State =
  | { kind: "idle" }
  | { kind: "loading" }
  | { kind: "success"; items: Todo[] }
  | { kind: "error"; message: string };

export function useTodos(repo: TodosRepo) {
  const [state, setState] = useState<State>({ kind: "idle" });

  async function load() {
    setState({ kind: "loading" });
    try {
      const items = await repo.list();
      setState({ kind: "success", items });
    } catch (e: any) {
      setState({ kind: "error", message: e?.message ?? "Unknown error" });
    }
  }

  useEffect(() => {
    if (state.kind === "idle") void load();
  }, [state.kind]);

  return { state, load };
}
```

### 7) Screen usage

```tsx
// screens/TodosScreen.tsx
import React from "react";
import { View, Text, Button, ActivityIndicator, FlatList } from "react-native";
import { useTodos } from "../hooks/useTodos";
import { HttpTodosRepo } from "../data/todos.repo.http";
import { CachedTodosRepo } from "../data/todos.repo.cached";
import {
  createMMKVAdapter /* or createAsyncStorageAdapter */,
} from "../data/storage";

const BASE_URL = "https://example.com";
const repo = new CachedTodosRepo(
  new HttpTodosRepo(BASE_URL),
  createMMKVAdapter(),
  60_000
);

export function TodosScreen() {
  const { state, load } = useTodos(repo);
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
        keyExtractor={(x) => x.id}
        renderItem={({ item }) => <Text>{item.title}</Text>}
      />
    );
  return <Button title="Load" onPress={load} />;
}
```

### What this gives you

- Clear separation: DTOs are private to data layer; UI sees only domain `Todo`.
- Swappable data sources: plain HTTP repo vs. cached decorator.
- Testability: mock `TodosRepo` in unit tests or stories.

### Quick tests

- Replace `HttpTodosRepo` with a fake to validate UI without network:

```ts
const fake: TodosRepo = {
  async list() {
    return [{ id: "1", title: "Read", done: false }];
  },
};
```

## Sandbox copy map

Paste into an Expo app (see sandboxes/react-native-expo):

- domain/todos.ts — domain contracts
- data/http.ts, data/todos.dto.ts, data/todos.repo.http.ts, data/todos.repo.cached.ts — data layer
- data/storage.ts — AsyncStorage/MMKV adapters
- hooks/useTodos.ts — hook
- screens/TodosScreen.tsx — UI
