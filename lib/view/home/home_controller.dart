import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/data/model/get_todo_model.dart';
import 'package:todo_app/data/repository/todo_repository.dart';
import 'package:todo_app/utils/local_storage.dart';

class HomeController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<TextEditingController> titleController = TextEditingController().obs;
  Rx<TextEditingController> subtitleController = TextEditingController().obs;
  final GlobalKey<FormState> updateFormKey = GlobalKey<FormState>();

  RxList<GetTodoModel> todoList = <GetTodoModel>[].obs;
  RxMap<String, bool> completedTodos = <String, bool>{}.obs;

  RxString id = ''.obs;
  RxString deletingId = ''.obs;
  RxString editingId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint(" HomeController initialized");
    loadLocalDataThenApi();
  }

  void loadLocalDataThenApi() {
    titleController.value.clear();
    subtitleController.value.clear();
    TodoRepository.getTodoApi(isInitial: true, isLoader: isLoading);
  }

  // Helper method to delete todo locally
  void deleteTodoLocally(String todoId) {
    todoList.removeWhere((todo) => todo.id == todoId);
    LocalStorage.saveTodoList(todoList);
    debugPrint(" Deleted todo locally: $todoId");
  }

  // Helper method to update todo locally
  void updateTodoLocally(String todoId, String newTitle, String newSubtitle) {
    final index = todoList.indexWhere((todo) => todo.id == todoId);
    if (index != -1) {
      todoList[index] = GetTodoModel(
        id: todoId,
        title: newTitle,
        subtitle: newSubtitle,
        createdAt: todoList[index].createdAt,
      );
      LocalStorage.saveTodoList(todoList);
      debugPrint(" Updated todo locally: $todoId");
    }
  }

  @override
  void onClose() {
    super.onClose();
   
    titleController.value.dispose();
    subtitleController.value.dispose();
  }
}
