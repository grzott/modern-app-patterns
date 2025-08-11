# Local Caching (AsyncStorage/MMKV)

Persist lightweight data for faster startups and offline UX.

## Pattern

- Serialize minimal domain or DTOs.
- Keep TTL/versioning to invalidate.
- Wrap storage behind a small API.

## Examples

### AsyncStorage

```ts
// cache.ts
import AsyncStorage from "@react-native-async-storage/async-storage";

const key = "todos-cache-v1";
export type Cache = { ts: number; items: { id: string; title: string }[] };

export async function save(items: Cache["items"]) {
  const value: Cache = { ts: Date.now(), items };
  await AsyncStorage.setItem(key, JSON.stringify(value));
}
export async function load(maxAgeMs = 60_000): Promise<Cache["items"] | null> {
  const raw = await AsyncStorage.getItem(key);
  if (!raw) return null;
  const data = JSON.parse(raw) as Cache;
  if (Date.now() - data.ts > maxAgeMs) return null;
  return data.items;
}
```

### MMKV

```ts
// cache.mmkv.ts
import { MMKV } from "react-native-mmkv";

const storage = new MMKV({
  id: "app-cache" /*, encryptionKey: 'optional-key' */,
});
const key = "todos-cache-v1";
export type Cache = { ts: number; items: { id: string; title: string }[] };

export function save(items: Cache["items"]) {
  const value: Cache = { ts: Date.now(), items };
  storage.set(key, JSON.stringify(value)); // sync and very fast
}

export function load(maxAgeMs = 60_000): Cache["items"] | null {
  const raw = storage.getString(key);
  if (!raw) return null;
  try {
    const data = JSON.parse(raw) as Cache;
    if (Date.now() - data.ts > maxAgeMs) return null;
    return data.items;
  } catch {
    return null;
  }
}
```

Notes

- MMKV is synchronous and extremely fast; ideal for small config, flags, and lightweight caches.
- Optional encryptionKey adds at-rest encryption. Avoid storing sensitive tokens unless required.
- Keep payloads small; for large lists prefer normalized slices and server-state libraries.

## Why it works

- Faster time-to-content.
- Simple TTL prevents stale data.

## Sandbox copy map

Paste into an Expo app (see sandboxes/react-native-expo):

- cache.ts or cache.mmkv.ts — utility module under a data/ or utils/ folder
- Use from a screen or repo decorator (see Repository + DTO mapping guide)
