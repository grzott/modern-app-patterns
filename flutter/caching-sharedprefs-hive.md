# Caching with SharedPreferences and Hive

Goal: Persist small settings or lists locally.

## SharedPreferences

```dart
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
}

Future<String?> readToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}
```

## Hive (key-value boxes with adapters)

```dart
import 'package:hive/hive.dart';

class TodoEntity {
  final int id; final String title; final bool done;
  TodoEntity(this.id, this.title, this.done);
}

Future<void> initHive() async {
  // await Hive.initFlutter(); // if using hive_flutter
  Hive.registerAdapter(/* Generated adapter for TodoEntity */);
}

Future<void> saveTodos(List<TodoEntity> todos) async {
  final box = await Hive.openBox('todos');
  await box.put('items', todos.map((t) => {'id': t.id, 'title': t.title, 'done': t.done}).toList());
}

Future<List<TodoEntity>> loadTodos() async {
  final box = await Hive.openBox('todos');
  final list = (box.get('items', defaultValue: <Map<String, dynamic>>[]) as List).cast<Map<String, dynamic>>();
  return list.map((j) => TodoEntity(j['id'], j['title'], j['done'])).toList();
}
```

Notes

- Use `hive_generator` for strong typing; example keeps it simple for copy/paste.
- Consider `flutter_secure_storage` for secrets.

---

## Sandbox copy map

- Add `shared_preferences` or `hive` deps in sandbox pubspec.
- Put helpers under `sandboxes/flutter/lib/` and call from `main.dart`.
