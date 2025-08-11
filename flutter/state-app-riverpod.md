# State management with Riverpod

Goal: Declarative, testable state with providers.

## Pattern

- Providers expose state and logic.
- Widgets read/watch providers to react to changes.

## Example

```dart
// todos_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final todosListProvider = FutureProvider<List<String>>((ref) async {
  // Could depend on repository provider
  return ['Milk', 'Bread', 'Eggs'];
});
```

```dart
// todos_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'todos_providers.dart';

class TodosRiverpodScreen extends ConsumerWidget {
  const TodosRiverpodScreen({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(todosListProvider);
    return asyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (items) => ListView(children: items.map(Text.new).toList()),
    );
  }
}
```

## Live end-to-end example

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'todos_providers.dart';

void main() => runApp(const ProviderScope(child: MyApp()));
class MyApp extends StatelessWidget { const MyApp({super.key});
  @override Widget build(BuildContext context) => const MaterialApp(home: Scaffold(
    appBar: AppBar(title: Text('Riverpod')),
    body: TodosRiverpodScreen(),
  ));
}
```

Notes

- Compose providers: repo, dio, cache.
- Use `StateNotifierProvider` for complex reducers.

---

## Sandbox copy map

- Copy `todos_providers.dart` and screen to `sandboxes/flutter/lib/`.
- Wrap `MyApp` with `ProviderScope` and add `flutter_riverpod` in pubspec.
