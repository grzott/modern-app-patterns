# Repository + Dio + DTO Mapping (Flutter/Dart)

Goal: Isolate HTTP, map DTOs to domain models.

## Pattern

- DTO: matches API.
- Model: used in UI/domain.
- Repository: uses Dio to fetch, maps to Model.

## Example

```dart
// data/models.dart
class TodoDto { final int id; final String title; final bool done;
  TodoDto({required this.id, required this.title, required this.done});
  factory TodoDto.fromJson(Map<String, dynamic> j) => TodoDto(id: j['id'], title: j['title'], done: j['completed'] ?? false);
}

class Todo { final int id; final String title; final bool done;
  Todo({required this.id, required this.title, required this.done});
}

extension on TodoDto { Todo toModel() => Todo(id: id, title: title, done: done); }
```

```dart
// data/repository.dart
import 'package:dio/dio.dart';
import 'models.dart';

abstract class TodosRepo { Future<List<Todo>> getTodos(); }
class TodosRepoDio implements TodosRepo {
  final Dio dio; TodosRepoDio(this.dio);
  @override Future<List<Todo>> getTodos() async {
    final res = await dio.get('/todos');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map(TodoDto.fromJson).map((d) => d.toModel()).toList();
  }
}
```

```dart
// ui/todos_screen.dart
import 'package:flutter/material.dart';
import '../data/repository.dart';

class TodosRepoScreen extends StatefulWidget {
  final TodosRepo repo;
  const TodosRepoScreen({super.key, required this.repo});
  @override State<TodosRepoScreen> createState() => _TodosRepoScreenState();
}

class _TodosRepoScreenState extends State<TodosRepoScreen> {
  late Future<List<Todo>> future;
  @override void initState() { super.initState(); future = widget.repo.getTodos(); }
  @override Widget build(BuildContext context) => FutureBuilder(
    future: future,
    builder: (_, snap) {
      if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
      if (snap.hasError) return Center(child: Text(snap.error.toString()));
      final items = snap.data!;
      return ListView(children: items.map((t) => CheckboxListTile(value: t.done, onChanged: null, title: Text(t.title))).toList());
    },
  );
}
```

## Live end-to-end example

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'data/repository.dart';
import 'ui/todos_screen.dart';

void main() => runApp(const MyApp());
class MyApp extends StatelessWidget { const MyApp({super.key});
  @override Widget build(BuildContext context) {
    final repo = TodosRepoDio(Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com')));
    return MaterialApp(home: Scaffold(appBar: AppBar(title: const Text('Repository + Dio + DTO')),
      body: TodosRepoScreen(repo: repo)));
  }
}
```

Sandbox copy map

- Create files under `lib/` mirroring the paths above.
- Ensure `dio` is in pubspec dependencies.
  - In the sandbox, these go under `sandboxes/flutter/lib/`.
