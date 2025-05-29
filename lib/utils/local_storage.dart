import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get_storage/get_storage.dart';

class LocalStorage {
  static GetStorage prefs = GetStorage("localStorage");

  static RxString accessToken = "".obs;
}

// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:todo_app/data/model/get_todo_model.dart';

// class LocalStorage {
//   static RxString accessToken = "".obs;
//   static GetStorage prefs = GetStorage("localStorage");

//   static const String _todoListKey = "TODO_LIST";

//   static void saveTodoList(List<GetTodoModel> todos) {
//     List<Map<String, dynamic>> jsonList = todos.map((e) => e.toJson()).toList();
//     prefs.write(_todoListKey, jsonList);
//   }

//   static List<GetTodoModel> getTodoList() {
//     final List<dynamic>? jsonList = prefs.read<List<dynamic>>(_todoListKey);
//     if (jsonList == null) return [];
//     return jsonList.map((e) => GetTodoModel.fromJson(e)).toList();
//   }

//   static void clearTodoList() {
//     prefs.remove(_todoListKey);
//   }
// }
