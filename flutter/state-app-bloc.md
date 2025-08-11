# State management with Bloc (flutter_bloc)

Goal: Unidirectional data flow with Events -> Bloc -> States, decoupled from UI.

## Pattern

- Events: user intents.
- Bloc: handles events, emits States.
- View: subscribes to state stream via `BlocBuilder`.

## Example

```dart
// todos_bloc.dart
import 'package:bloc/bloc.dart';

sealed class TodosEvent {}
class LoadTodos extends TodosEvent {}

sealed class TodosState {}
class TodosLoading extends TodosState {}
class TodosLoaded extends TodosState { final List<String> items; TodosLoaded(this.items); }
class TodosError extends TodosState { final String msg; TodosError(this.msg); }

class TodosBloc extends Bloc<TodosEvent, TodosState> {
  final Future<List<String>> Function() list;
  TodosBloc(this.list) : super(TodosLoading()) {
    on<LoadTodos>((event, emit) async {
      emit(TodosLoading());
      try { emit(TodosLoaded(await list())); }
      catch (e) { emit(TodosError(e.toString())); }
    });
  }
}
```

```dart
// todos_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'todos_bloc.dart';

class TodosBlocScreen extends StatelessWidget {
  final TodosBloc bloc;
  const TodosBlocScreen({super.key, required this.bloc});

  @override Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc..add(LoadTodos()),
      child: BlocBuilder<TodosBloc, TodosState>(
        builder: (_, s) => switch (s) {
          TodosLoading() => const Center(child: CircularProgressIndicator()),
          TodosError(:final msg) => Center(child: Text(msg)),
          TodosLoaded(:final items) => ListView(children: items.map(Text.new).toList()),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}
```

## Live end-to-end example

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'todos_bloc.dart';

Future<List<String>> fakeList() async => ['Milk', 'Bread', 'Eggs'];

void main() => runApp(const MyApp());
class MyApp extends StatelessWidget { const MyApp({super.key});
  @override Widget build(BuildContext context) {
    final bloc = TodosBloc(fakeList);
    return MaterialApp(home: Scaffold(appBar: AppBar(title: const Text('Bloc')),
      body: TodosBlocScreen(bloc: bloc)));
  }
}
```

Notes

- Replace `fakeList` with a Repository+Dio call.
- Test bloc with `bloc_test`.

---

## Sandbox copy map

- Copy files into `sandboxes/flutter/lib/`.
- Set `flutter_bloc` in sandbox `pubspec.yaml`.
