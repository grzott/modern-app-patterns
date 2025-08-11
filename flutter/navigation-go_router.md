# Navigation with go_router

Goal: Typed, declarative navigation and deep linking.

## Pattern

- Define routes with builders.
- Navigate with `context.go('/path')`.

## Example

```dart
// nav/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Home extends StatelessWidget { const Home({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Home')),
    body: Center(child: ElevatedButton(
      onPressed: () => context.go('/todos'),
      child: const Text('Go Todos'),
    )),
  );
}

class TodosPage extends StatelessWidget { const TodosPage({super.key});
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Todos')));
}

final router = GoRouter(routes: [
  GoRoute(path: '/', builder: (_, __) => const Home()),
  GoRoute(path: '/todos', builder: (_, __) => const TodosPage()),
]);
```

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'nav/router.dart';

void main() => runApp(const MyApp());
class MyApp extends StatelessWidget { const MyApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp.router(routerConfig: router);
}
```

Notes

- Add typed params with path segments and `state.uri.queryParameters`.
- Use `ShellRoute` for shared layout.

---

## Sandbox copy map

- Place `nav/router.dart` and update sandbox `lib/main.dart` to use `MaterialApp.router` with `routerConfig`.
- Add `go_router` to sandbox `pubspec.yaml`.
