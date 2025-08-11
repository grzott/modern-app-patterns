# Server state with Riverpod + Dio

Goal: Fetch, cache, and refresh server state declaratively.

## Pattern

- Create a `Dio` client provider.
- Repository wraps http calls.
- Use `FutureProvider` or `AsyncNotifier` to fetch data, with refresh triggers.

## Example

```dart
// data/providers.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider((ref) => Dio(BaseOptions(baseUrl: 'https://example.com')));

class TodoDto { final int id; final String title; TodoDto({required this.id, required this.title});
  factory TodoDto.fromJson(Map<String, dynamic> j) => TodoDto(id: j['id'], title: j['title']); }

abstract class TodosRepo { Future<List<TodoDto>> getTodos(); }
class TodosRepoDio implements TodosRepo {
  final Dio dio; TodosRepoDio(this.dio);
  @override Future<List<TodoDto>> getTodos() async {
    final res = await dio.get('/todos');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map(TodoDto.fromJson).toList();
  }
}

final repoProvider = Provider<TodosRepo>((ref) => TodosRepoDio(ref.read(dioProvider)));

final todosProvider = FutureProvider<List<TodoDto>>((ref) async => ref.read(repoProvider).getTodos());
```

```dart
// ui/todos_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers.dart';

class TodosList extends ConsumerWidget {
  const TodosList({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final asyncTodos = ref.watch(todosProvider);
    return asyncTodos.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (items) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(todosProvider),
        child: ListView(children: items.map((t) => ListTile(title: Text(t.title))).toList()),
      ),
    );
  }
}
```

## Live end-to-end example

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/todos_list.dart';

void main() => runApp(const ProviderScope(child: MyApp()));
class MyApp extends StatelessWidget { const MyApp({super.key});
  @override Widget build(BuildContext context) => const MaterialApp(home: Scaffold(
    appBar: AppBar(title: Text('Server State (Riverpod + Dio)')),
    body: TodosList(),
  ));
}
```

Notes

- Consider `AsyncNotifier` for granular invalidation and pagination.
- Add interceptors for auth, logging.

---

## Sandbox copy map

- Mirror `data/` and `ui/` under `sandboxes/flutter/lib/`.
- Ensure `dio` and `flutter_riverpod` are added to the sandbox `pubspec.yaml`.
