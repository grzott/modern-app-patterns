# Expo Router 101 (File-based Navigation)

Learn folder-based routing with Expo Router. Copy/paste these minimal files into an Expo app to get started fast.

## Install

- npx expo install expo-router react-native-safe-area-context react-native-screens

## Pattern

- Routes are files under `app/`.
- `_layout.tsx` defines the navigator for a segment.
- `index.tsx` is the default screen for a folder.
- Use `Link` and `router.push()` for navigation.

## Live end-to-end example (copy/paste)

{% raw %}
```tsx
// app/_layout.tsx
import { Stack } from "expo-router";
import { SafeAreaProvider } from "react-native-safe-area-context";

export default function RootLayout() {
  return (
    <SafeAreaProvider>
      <Stack screenOptions={{ headerShown: true }} />
    </SafeAreaProvider>
  );
}
```
{% endraw %}

{% raw %}
```tsx
// app/index.tsx
import { Link } from "expo-router";
import { View, Text, Button } from "react-native";

export default function Home() {
  return (
    <View style={{ padding: 16 }}>
      <Text>Home</Text>
      <Link href={{ pathname: "/details/[id]", params: { id: "42" } }}>
        Go to Details 42
      </Link>
      <Link href="/profile">Go to Profile</Link>
    </View>
  );
}
```
{% endraw %}

{% raw %}
```tsx
// app/details/[id].tsx
import { useLocalSearchParams } from "expo-router";
import { View, Text } from "react-native";

export default function Details() {
  const { id } = useLocalSearchParams<{ id: string }>();
  return (
    <View style={{ padding: 16 }}>
      <Text>Details for {id}</Text>
    </View>
  );
}
```
{% endraw %}

```tsx
// app/profile/_layout.tsx
import { Stack } from "expo-router";
export default function ProfileLayout() {
  return <Stack />;
}
```

{% raw %}
```tsx
// app/profile/index.tsx
import { router } from "expo-router";
import { View, Text, Button } from "react-native";

export default function ProfileHome() {
  return (
    <View style={{ padding: 16 }}>
      <Text>Profile</Text>
      <Button title="Edit" onPress={() => router.push("/profile/edit")} />
    </View>
  );
}
```
{% endraw %}

{% raw %}
```tsx
// app/profile/edit.tsx
import { router } from "expo-router";
import { View, Text, Button } from "react-native";

export default function EditProfile() {
  return (
    <View style={{ padding: 16 }}>
      <Text>Edit Profile</Text>
      <Button title="Save" onPress={() => router.back()} />
    </View>
  );
}
```
{% endraw %}

## Tips

- Nested folders = nested stacks by default; switch to Tabs with `<Tabs />` in a `_layout`.
- Dynamic routes: `[id].tsx`, catch-all: `[...rest].tsx`.
- Use `Link` for declarative navigation; `router` for imperative actions.
- Add `app/+not-found.tsx` for a custom 404.

## Sandbox copy map

Paste the `app/` files directly into an Expo Router app (see sandboxes/react-native-expo). Ensure `expo-router` is installed and your package.json has the Expo Router config.
