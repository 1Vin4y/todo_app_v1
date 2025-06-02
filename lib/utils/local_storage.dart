import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:todo_app/data/model/get_todo_model.dart';

class LocalStorage {
  LocalStorage._();
  static late GetStorage prefs;
  static RxString accessToken = "".obs;

  static const String todoListKey = "TODO_LIST";

  static Future<void> init() async {
    await GetStorage.init("localStorage");
    prefs = GetStorage("localStorage");
    debugPrint(" LocalStorage initialized");
  }

  static void saveTodoList(List<GetTodoModel> todos) {
    try {
      final List<Map<String, dynamic>> jsonList = todos.map((e) => e.toJson()).toList();
      prefs.write(todoListKey, jsonList);
      debugPrint(" Saved ${todos.length} todos to local storage");
    } catch (e) {
      debugPrint(" Error saving todos to local storage: $e");
    }
  }

  static List<GetTodoModel> getTodoList() {
    try {
      final jsonList = prefs.read<List>(todoListKey);
      debugPrint(" Reading from local storage: ${jsonList?.length ?? 0} items");

      if (jsonList != null) {
        final todos = jsonList.map((e) => GetTodoModel.fromJson(Map<String, dynamic>.from(e))).toList();
        debugPrint("Successfully loaded ${todos.length} todos from local storage");
        return todos;
      }
    } catch (e) {
      debugPrint(" Error reading from local storage: $e");
    }
    return [];
  }

  static void printTodoList() {
    final todos = getTodoList();
    debugPrint(" Current todos in local storage:");
    for (var todo in todos) {
      debugPrint("- ${todo.title} (${todo.id})");
    }
  }

  static void clearAll() {
    try {
      prefs.erase();
      debugPrint(" Cleared all local storage data");
    } catch (e) {
      debugPrint(" Error clearing local storage: $e");
    }
  }
}

