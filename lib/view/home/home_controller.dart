import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/data/model/get_todo_model.dart';
import 'package:todo_app/data/repository/todo_repository.dart';
import 'package:todo_app/utils/local_storage.dart';
import 'package:todo_app/utils/utils.dart';

class HomeController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<TextEditingController> titleController = TextEditingController().obs;
  Rx<TextEditingController> subtitleController = TextEditingController().obs;
  RxList<GetTodoModel> todoList = <GetTodoModel>[].obs;
  RxString id = ''.obs;
  RxString deletingId = ''.obs;
  RxString editingId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint(" HomeController initialized");
    loadLocalDataThenApi();
  }

  void loadLocalDataThenApi() async {
    debugPrint("Starting to load data...");

    // Always load local data first
    final localTodos = LocalStorage.getTodoList();
    if (localTodos.isNotEmpty) {
      todoList.assignAll(localTodos);
      debugPrint(" Loaded ${localTodos.length} todos from local storage");
    } else {
      debugPrint("No todos found in local storage");
    }

    // Hide loader after loading local data
    isLoading.value = false;

    // Then try to sync with API if online
    if (await getConnectivityResult()) {
      debugPrint(" Online - attempting to sync with API");
      await TodoRepository.getTodoApi(isInitial: true, isLoader: isLoading);
    } else {
      debugPrint(" Offline - using local data only");
    }
  }

  void showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add To-Do'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController.value,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: subtitleController.value,
              decoration: InputDecoration(labelText: 'Subtitle'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.value.text.isEmpty) {
                Get.snackbar('Error', 'Title cannot be empty', backgroundColor: Colors.red);
                return;
              }

              Get.back();

              // Create a temporary todo with a local ID
              final tempId = DateTime.now().millisecondsSinceEpoch.toString();
              final newTodo = GetTodoModel(
                id: tempId,
                title: titleController.value.text,
                subtitle: subtitleController.value.text,
                createdAt: DateTime.now(),
              );

              // Add to local storage immediately
              todoList.add(newTodo);
              LocalStorage.saveTodoList(todoList);
              debugPrint(" Added new todo to local storage: ${newTodo.title}");

              if (await getConnectivityResult()) {
                debugPrint(" Online - syncing new todo with API");
                // Try to sync with API
                await TodoRepository.postTodoApi(
                  title: titleController.value.text,
                  subtitle: subtitleController.value.text,
                  onSuccess: (response) {
                    // Update the todo with the server ID
                    final serverId = response['id']?.toString();
                    if (serverId != null) {
                      final index = todoList.indexWhere((todo) => todo.id == tempId);
                      if (index != -1) {
                        todoList[index] = GetTodoModel(
                          id: serverId,
                          title: response['title'],
                          subtitle: response['subtitle'],
                          createdAt: response['createdAt'] != null ? DateTime.parse(response['createdAt']) : DateTime.now(),
                        );
                        LocalStorage.saveTodoList(todoList);
                        debugPrint(" Updated todo with server ID: $serverId");
                      }
                    }
                  },
                );
              } else {
                debugPrint(" Offline - todo saved locally only");
                Get.snackbar(
                  'Offline Mode',
                  'Todo saved locally. Will sync when online.',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              }

              titleController.value.clear();
              subtitleController.value.clear();
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
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

  void showUpdateDialog(BuildContext context, GetTodoModel todo) {
    titleController.value.text = todo.title ?? '';
    subtitleController.value.text = todo.subtitle ?? '';
    id.value = todo.id ?? '';
    // Add a loading state for the save button
    RxBool isSaving = false.obs;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Update To-Do'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController.value,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: subtitleController.value,
              decoration: InputDecoration(labelText: 'Subtitle'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
                onPressed: isSaving.value
                    ? null
                    : () async {
                        if (titleController.value.text.isEmpty) {
                          Get.snackbar('Error', 'Title cannot be empty', backgroundColor: Colors.red);
                          return;
                        }

                        isSaving.value = true;
                        Get.back(); // Close dialog immediately

                        if (await getConnectivityResult()) {
                          debugPrint(" Online - updating todo via API");
                          await TodoRepository.updateTodoApi(
                            id: id.value,
                            updatedTitle: titleController.value.text,
                            updatedSubtitle: subtitleController.value.text,
                            onSuccess: () {
                              // Update the existing todo in the list
                              final index = todoList.indexWhere((t) => t.id == id.value);
                              if (index != -1) {
                                todoList[index] = GetTodoModel(
                                  id: id.value,
                                  title: titleController.value.text,
                                  subtitle: subtitleController.value.text,
                                  createdAt: todoList[index].createdAt,
                                );
                                LocalStorage.saveTodoList(todoList);
                                debugPrint(" Updated todo via API: ${id.value}");
                              }
                            },
                          );
                        } else {
                          debugPrint(" Offline - updating todo locally");
                          updateTodoLocally(
                            id.value,
                            titleController.value.text,
                            subtitleController.value.text,
                          );
                          Get.snackbar(
                            'Offline Mode',
                            'Todo updated locally. Changes will sync when online.',
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                          );
                        }

                        titleController.value.clear();
                        subtitleController.value.clear();
                        isSaving.value = false;
                      },
                child: isSaving.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text('Save'),
              )),
        ],
      ),
    );
  }
}
