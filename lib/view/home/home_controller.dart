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

//   @override
//   void onInit() {
//     super.onInit();
//     loadData();
//   }

//   void loadData() async {
//       await TodoRepository.getTodoApi(isInitial: true, isLoader: isLoading);

//       // final List<GetTodoModel> localData = LocalStorage.getTodoList();
//       //   if (localData.isNotEmpty) {
//       todoList.assignAll(LocalStorage.getTodoList());

//       //  }
//       todoList.refresh();
// //localData;
//       LocalStorage.getTodoList();
//     }

// @override
// void onInit() {
//   super.onInit();
//   loadData();
// }

// void loadData() async {
//   // Load local data immediately (offline-first)
//   final List<GetTodoModel> localData = LocalStorage.getTodoList();
//   if (localData.isNotEmpty) {
//     todoList.addAll(localData);
//   }

//   isLoading.value = false; // Hide the loader if local data was shown

//   // Try to fetch from API if connected
//   if (await getConnectivityResult()) {
//     isLoading.value = true;
//     await TodoRepository.getTodoApi(isInitial: true, isLoader: isLoading);
//     isLoading.value = false;
//   }
// }

  @override
  void onInit() {
    super.onInit();
    loadLocalDataThenApi();
  }
void loadLocalDataThenApi() async {
  // Always load local data first
  final localTodos = LocalStorage.getTodoList();
  if (localTodos.isNotEmpty) {
    todoList.assignAll(localTodos);
    isLoading.value = false;
  }

  // Then try to sync with API if online
  if (await getConnectivityResult()) {
    isLoading.value = true;
    await TodoRepository.getTodoApi(isInitial: true, isLoader: isLoading);
  }
  isLoading.value = false;
}

  // @override
  // Future<void> onReady() async {
  //   super.onReady();
  //   await TodoRepository.getTodoApi(isInitial: true, isLoader: isLoading);
  // }

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
              //review needed
              await TodoRepository.postTodoApi(
                title: titleController.value.text,
                subtitle: subtitleController.value.text,
                isLoader: isLoading,
              );
              await TodoRepository.getTodoApi(isLoader: isLoading);
              //  await TodoRepository.postTodoApi(
              //   title: titleController.value.text,
              //   subtitle: subtitleController.value.text,
              //   isLoader: isLoading,
              //   onSuccess: (response) async {
              //     await TodoRepository.getTodoApi(isLoader: isLoading);
              //   },
              // );
              todoList.refresh();

              Get.back();
              titleController.value.clear();
              subtitleController.value.clear();
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void showUpdateDialog(BuildContext context, GetTodoModel todo) {
    titleController.value.text = todo.title ?? '';
    subtitleController.value.text = todo.subtitle ?? '';
    id.value = todo.id ?? '';

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
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            //review needed
            onPressed: () async {
              await TodoRepository.updateTodoApi(
                id: id.value,
                updatedTitle: titleController.value.text,
                updatedSubtitle: subtitleController.value.text,
              );
              await TodoRepository.getTodoApi(isLoader: isLoading);
              // await TodoRepository.updateTodoApi(
              //   id: id.value,
              //   updatedTitle: titleController.value.text,
              //   updatedSubtitle: subtitleController.value.text,
              //   onSuccess: () async {
              //     await TodoRepository.getTodoApi(isLoader: isLoading);
              //   },
              // );
              Get.back();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
