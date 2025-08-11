# Compound Components

Expose a component family under a single namespace to share state and behavior.

## Pattern

- Parent manages context/state.
- Children consume context to render parts.

## Example

{% raw %}
```tsx
// Select.tsx
import React, { createContext, useContext, useState } from "react";

type Ctx = { value: string | null; set: (v: string) => void };
const C = createContext<Ctx | null>(null);

function Root({ children }: { children: React.ReactNode }) {
  const [value, set] = useState<string | null>(null);
  return <C.Provider value={{ value, set }}>{children}</C.Provider>;
}

function Option({
  value,
  children,
}: {
  value: string;
  children: React.ReactNode;
}) {
  const ctx = useContext(C)!;
  const selected = ctx.value === value;
  return (
    <div onClick={() => ctx.set(value)} aria-selected={selected}>
      {children}
    </div>
  );
}

export const Select = Object.assign(Root, { Option });
```
{% endraw %}

## Why it works

- Scales options without prop-drilling.
- Clear, ergonomic API: `<Select><Select.Option ... /></Select>`.

---

## Live end-to-end example (copy/paste)

Make a small `Select` using RN primitives and shared context.

{% raw %}
```tsx
// components/Select.tsx
import React, { createContext, useContext, useState } from "react";
import { Pressable, Text, View } from "react-native";

type Ctx = { value: string | null; set: (v: string) => void };
const C = createContext<Ctx | null>(null);

function Root({
  children,
  initialValue = null,
}: {
  children: React.ReactNode;
  initialValue?: string | null;
}) {
  const [value, set] = useState<string | null>(initialValue);
  return <C.Provider value={{ value, set }}>{children}</C.Provider>;
}

function Option({
  value,
  children,
}: {
  value: string;
  children: React.ReactNode;
}) {
  const ctx = useContext(C);
  if (!ctx) throw new Error("Select must be used within Select.Root");
  const selected = ctx.value === value;
  return (
    <Pressable
      onPress={() => ctx.set(value)}
      style={{
        padding: 8,
        backgroundColor: selected ? "#def" : "#eee",
        marginVertical: 4,
      }}
    >
      <Text>{children}</Text>
    </Pressable>
  );
}

function Value() {
  const ctx = useContext(C);
  if (!ctx) throw new Error("Select must be used within Select.Root");
  return <Text>Selected: {ctx.value ?? "—"}</Text>;
}

export const Select = Object.assign(Root, { Option, Value });
```
{% endraw %}

{% raw %}
```tsx
// screens/SelectDemo.tsx
import React from "react";
import { View } from "react-native";
import { Select } from "../components/Select";

export function SelectDemo() {
  return (
    <View style={{ padding: 16 }}>
      <Select initialValue="b">
        <Select.Value />
        <Select.Option value="a">Alpha</Select.Option>
        <Select.Option value="b">Beta</Select.Option>
        <Select.Option value="g">Gamma</Select.Option>
      </Select>
    </View>
  );
}
```
{% endraw %}

Notes

- You can expose `Select.Trigger`, `Select.Content`, etc., as the component grows.

## Sandbox copy map

Paste into an Expo app (see sandboxes/react-native-expo):

- components/Select.tsx — compound component
- screens/SelectDemo.tsx — demo screen
- App.tsx — render <SelectDemo />
