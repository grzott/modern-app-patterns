import { Link } from "expo-router";
import { View, Text } from "react-native";

export default function Home() {
  return (
    <View style={{ padding: 16 }}>
      <Text>Expo Sandbox</Text>
      <Link href="/todos">Open Todos</Link>
    </View>
  );
}
