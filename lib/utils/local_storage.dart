import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:todo_app/data/model/get_todo_model.dart';

class LocalStorage {
  LocalStorage._();
  static GetStorage prefs = GetStorage("localStorage");
  static RxString accessToken = "".obs;

  static const String todoListKey = "TODO_LIST";
  static void saveTodoList(List<GetTodoModel> todos) {
    final List<Map<String, dynamic>> jsonList = todos.map((e) => e.toJson()).toList();
    prefs.write(todoListKey, jsonList);
  }

  // static List<GetTodoModel> getTodoList() {
  //   final jsonList = prefs.read<List>(todoListKey);
  //   if (jsonList != null) {
  //     return jsonList.map((e) => GetTodoModel.fromJson(Map<String, dynamic>.from(e))).toList();
  //   } else {
  //     return [];
  //   }
  // }
  static List<GetTodoModel> getTodoList() {
  final jsonList = prefs.read<List>(todoListKey);
  debugPrint("Local Storage Contents: ${jsonList?.length ?? 0} items"); // Add this line
  if (jsonList != null) {
    return jsonList.map((e) => GetTodoModel.fromJson(Map<String, dynamic>.from(e))).toList();
  } else {
    return [];
  }
}
  static void printTodoList() {
    final todos = getTodoList();
    for (var todo in todos) {
      debugPrint(todo.toJson().toString());
    }
  }

  static void clearAll() {
    prefs.erase();
  }
}


               // final jsonList = getTodos.map((todo) => todo.toJson()).toList();
              // final myVal = LocalStorage.prefs.write(LocalStorage.todoListKey, jsonList);
              // debugPrint("my value : $myVal");
              // final myfinalVal = LocalStorage.prefs.read(LocalStorage.todoListKey);
              // final todoList = (jsonList).map((item) => GetTodoModel.fromJson(item)).toList();

              // for (var todo in todoList) {
              //   debugPrint("Todo title: ${todo.title}\n Todo subtitle : ${todo.subtitle}");
              // }
              // debugPrint("my final read value : $myfinalVal");