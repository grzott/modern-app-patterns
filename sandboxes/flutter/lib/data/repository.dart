import 'package:dio/dio.dart';
import 'models.dart';

abstract class TodosRepo {
  Future<List<Todo>> getTodos();
}

class TodosRepoDio implements TodosRepo {
  final Dio dio;
  TodosRepoDio(this.dio);

  @override
  Future<List<Todo>> getTodos() async {
    final res = await dio.get('/todos');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map(TodoDto.fromJson).map((d) => d.toModel()).toList();
  }
}
