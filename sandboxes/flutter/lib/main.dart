import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'data/repository.dart';
import 'ui/todos_repo_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final repo = TodosRepoDio(
      Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com')),
    );
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Repository + Dio + DTO')),
        body: TodosRepoScreen(repo: repo),
      ),
    );
  }
}
