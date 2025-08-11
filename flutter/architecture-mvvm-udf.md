# MVVM + UDF in Flutter (Dart)

Goal: Model UI as a function of state with a ViewModel-like class and a discriminated-union style state.

## Pattern

- View: Widget renders by `state` only.
- ViewModel: class exposes state (ValueNotifier/StateNotifier) and actions.
- UDF: events -> reducer -> new state; effects inside VM.

## Example

```dart
// view_model.dart
import 'package:flutter/foundation.dart';

sealed class State {}
class Idle extends State {}
class Loading extends State {}
class Success extends State { final List<String> items; Success(this.items); }
class ErrorState extends State { final String message; ErrorState(this.message); }

class TodosVm extends ChangeNotifier {
  State _state = Idle();
  State get state => _state;

  final Future<List<String>> Function() list;
  TodosVm(this.list);

  Future<void> load() async {
    _state = Loading(); notifyListeners();
    try { final items = await list(); _state = Success(items); }
    catch (e) { _state = ErrorState(e.toString()); }
    notifyListeners();
  }
}
```

```dart
// todos_screen.dart
import 'package:flutter/material.dart';
import 'view_model.dart';

class TodosScreen extends StatefulWidget {
  final TodosVm vm;
  const TodosScreen({super.key, required this.vm});
  @override State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  @override void initState() { super.initState(); widget.vm.addListener(_onVm); widget.vm.load(); }
  @override void dispose() { widget.vm.removeListener(_onVm); super.dispose(); }
  void _onVm() => setState(() {});

  @override Widget build(BuildContext context) {
    final s = widget.vm.state;
    return switch (s) {
      Loading() => const Center(child: CircularProgressIndicator()),
      ErrorState(:final message) => Center(child: Text(message)),
      Success(:final items) => ListView(children: items.map(Text.new).toList()),
      _ => Center(child: ElevatedButton(onPressed: widget.vm.load, child: const Text('Load'))),
    };
  }
}
```

## Why it works

- Predictable states; easy tests.
- Side effects isolated in the ViewModel.

---

## Live end-to-end example (copy/paste)

VM + screen + fake API.

```dart
// app/api.dart
Future<List<String>> fakeList() async => ['Milk', 'Bread', 'Eggs'];
```

```dart
// app/todos_vm.dart
import 'package:flutter/foundation.dart';

sealed class VmState {}
class VmLoading extends VmState {}
class VmData extends VmState { final List<String> items; VmData(this.items); }
class VmError extends VmState { final String msg; VmError(this.msg); }

class TodosVm extends ChangeNotifier {
  VmState state = VmLoading();
  final Future<List<String>> Function() list;
  TodosVm(this.list) { load(); }
  Future<void> load() async {
    state = VmLoading(); notifyListeners();
    try { state = VmData(await list()); }
    catch (e) { state = VmError(e.toString()); }
    notifyListeners();
  }
}
```

```dart
// screens/todos_mvvm.dart
import 'package:flutter/material.dart';
import '../app/todos_vm.dart';

class TodosMvvm extends StatefulWidget {
  final TodosVm vm;
  const TodosMvvm({super.key, required this.vm});
  @override State<TodosMvvm> createState() => _TodosMvvmState();
}

class _TodosMvvmState extends State<TodosMvvm> {
  @override void initState() { super.initState(); widget.vm.addListener(_on); }
  @override void dispose() { widget.vm.removeListener(_on); super.dispose(); }
  void _on() => setState(() {});

  @override Widget build(BuildContext context) {
    final s = widget.vm.state;
    return switch (s) {
      VmLoading() => const Center(child: CircularProgressIndicator()),
      VmError(:final msg) => Center(child: Text(msg)),
      VmData(:final items) => ListView(children: items.map(Text.new).toList()),
      _ => const SizedBox.shrink(),
    };
  }
}
```

```dart
// main.dart
import 'package:flutter/material.dart';
import 'app/api.dart';
import 'app/todos_vm.dart';
import 'screens/todos_mvvm.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override Widget build(BuildContext context) {
    final vm = TodosVm(fakeList);
    return MaterialApp(home: Scaffold(appBar: AppBar(title: const Text('Todos')), body: TodosMvvm(vm: vm)));
  }
}
```

Notes

- Swap `fakeList` with a repository-backed implementation.

---

## Sandbox copy map

- Create files under `sandboxes/flutter/lib/` matching the paths shown.
- Replace `main.dart` in the sandbox with the page's `main.dart`.
- Add any missing packages to `sandboxes/flutter/pubspec.yaml` and run Flutter.
