# Navigation with React Navigation

Type-safe navigation with nested stacks and tabs.

## Pattern

- Define param lists for each navigator.
- Nest navigators; keep each focused.
- Typed helpers for `navigate` and route params.

## Example

```ts
// navigation/types.ts
export type RootStackParamList = {
  Home: undefined;
  Details: { id: string };
};
```

```tsx
// AppNavigator.tsx
import { NavigationContainer } from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";
import type { RootStackParamList } from "./navigation/types";

const Stack = createNativeStackNavigator<RootStackParamList>();

export function AppNavigator() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Details" component={DetailsScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
```

## Why it works

- Static typing reduces runtime errors.
- Clear separation of navigation concerns.

---

## Live end-to-end example (copy/paste)

Typed root stack + two screens navigating with params.

```ts
// navigation/types.ts
export type RootStackParamList = { Home: undefined; Details: { id: string } };
```

{% raw %}
```tsx
// screens/HomeScreen.tsx
import React from "react";
import { View, Text, Button } from "react-native";
import type { NativeStackScreenProps } from "@react-navigation/native-stack";
import type { RootStackParamList } from "../navigation/types";

type Props = NativeStackScreenProps<RootStackParamList, "Home">;
export function HomeScreen({ navigation }: Props) {
  return (
    <View style={{ padding: 16 }}>
      <Text>Home</Text>
      <Button
        title="Go to Details 42"
        onPress={() => navigation.navigate("Details", { id: "42" })}
      />
    </View>
  );
}
```
{% endraw %}

{% raw %}
```tsx
// screens/DetailsScreen.tsx
import React from "react";
import { View, Text } from "react-native";
import type { NativeStackScreenProps } from "@react-navigation/native-stack";
import type { RootStackParamList } from "../navigation/types";

type Props = NativeStackScreenProps<RootStackParamList, "Details">;
export function DetailsScreen({ route }: Props) {
  return (
    <View style={{ padding: 16 }}>
      <Text>Details for {route.params.id}</Text>
    </View>
  );
}
```
{% endraw %}

```tsx
// AppNavigator.tsx
import React from "react";
import { NavigationContainer } from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";
import type { RootStackParamList } from "./navigation/types";
import { HomeScreen } from "./screens/HomeScreen";
import { DetailsScreen } from "./screens/DetailsScreen";

const Stack = createNativeStackNavigator<RootStackParamList>();

export function AppNavigator() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Details" component={DetailsScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
```

Notes

- Use nested navigators for larger apps (tabs + stacks) and keep params typed per navigator.

## Sandbox copy map

Paste into an Expo app (see sandboxes/react-native-expo):

- navigation/types.ts — param list types
- screens/HomeScreen.tsx and screens/DetailsScreen.tsx — screens
- AppNavigator.tsx — create the navigator
- App.tsx — export <AppNavigator /> as default
