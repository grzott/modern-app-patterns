import 'package:flutter/material.dart';
import '../data/repository.dart';
import '../data/models.dart';

class TodosRepoScreen extends StatefulWidget {
  final TodosRepo repo;
  const TodosRepoScreen({super.key, required this.repo});
  @override
  State<TodosRepoScreen> createState() => _TodosRepoScreenState();
}

class _TodosRepoScreenState extends State<TodosRepoScreen> {
  late Future<List<Todo>> future;
  @override
  void initState() {
    super.initState();
    future = widget.repo.getTodos();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Todo>>(
        future: future,
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text(snap.error.toString()));
          }
          final items = snap.data ?? const <Todo>[];
          if (items.isEmpty) return const Center(child: Text('No items'));
          return ListView(
            children: items
                .map((t) => CheckboxListTile(
                      value: t.done,
                      onChanged: null,
                      title: Text(t.title),
                    ))
                .toList(),
          );
        },
      );
}
