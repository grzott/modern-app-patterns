# Dependency Injection with get_it

Goal: Register and resolve dependencies without passing them through constructors everywhere.

## Pattern

- Use `get_it` as a service locator.
- Register singletons/factories at app start.

## Example

```dart
// di/config.dart
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void configureDi() {
  sl.registerLazySingleton(() => Dio(BaseOptions(baseUrl: 'https://example.com')));
  // sl.registerLazySingleton<TodosRepo>(() => TodosRepoDio(sl()));
}
```

```dart
// main.dart
import 'package:flutter/material.dart';
import 'di/config.dart';

void main() { configureDi(); runApp(const MyApp()); }
class MyApp extends StatelessWidget { const MyApp({super.key});
  @override Widget build(BuildContext context) => const MaterialApp(home: Scaffold(body: Center(child: Text('DI ready'))));
}
```

Notes

- Prefer explicit constructor injection in pure code; use locator at app boundary.

---

## Sandbox copy map

- Put `di/` under `sandboxes/flutter/lib/` and call `configureDi()` in `main()`.
- Add `get_it` (and `dio` if used) to the sandbox `pubspec.yaml`.
