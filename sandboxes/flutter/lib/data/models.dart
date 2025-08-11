class TodoDto {
  final int id;
  final String title;
  final bool done;
  TodoDto({required this.id, required this.title, required this.done});

  factory TodoDto.fromJson(Map<String, dynamic> j) => TodoDto(
        id: j['id'] as int,
        title: j['title'] as String,
        done: (j['completed'] as bool?) ?? false,
      );
}

class Todo {
  final int id;
  final String title;
  final bool done;
  Todo({required this.id, required this.title, required this.done});
}

extension TodoMapping on TodoDto {
  Todo toModel() => Todo(id: id, title: title, done: done);
}
