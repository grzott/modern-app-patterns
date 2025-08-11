import { View, Text, ActivityIndicator, FlatList } from "react-native";
import { useQuery } from "@tanstack/react-query";

async function fetchTodos() {
  const r = await fetch("https://jsonplaceholder.typicode.com/todos?_limit=10");
  if (!r.ok) throw new Error("Network");
  return (await r.json()) as { id: number; title: string }[];
}

export default function Todos() {
  const q = useQuery({ queryKey: ["todos"], queryFn: fetchTodos });
  if (q.isLoading) return <ActivityIndicator />;
  if (q.error) return <Text>{(q.error as Error).message}</Text>;
  return (
    <View style={{ padding: 16 }}>
      <FlatList
        data={q.data}
        keyExtractor={(x) => String(x.id)}
        renderItem={({ item }) => <Text>{item.title}</Text>}
      />
    </View>
  );
}
