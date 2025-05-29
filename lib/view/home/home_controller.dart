import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/data/model/get_todo_model.dart';
import 'package:todo_app/data/repository/todo_repository.dart';


class HomeController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<TextEditingController> titleController = TextEditingController().obs;
  Rx<TextEditingController> subtitleController = TextEditingController().obs;
  RxList<GetTodoModel> todoList = <GetTodoModel>[].obs;
  RxString id = ''.obs;

  @override
  Future<void> onReady() async {
    super.onReady();
    await TodoRepository.getTodoApi(isInitial: true, isLoader: isLoading);
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
            // onPressed: () async {
            //   await TodoRepository.postTodoApi(
            //     title: titleController.value.text,
            //     subtitle: subtitleController.value.text,
            //     isLoader: isLoading,
            //   );

            //   await TodoRepository.getTodoApi(isLoader: isLoading); // this updates the todoList

            //   // ✅ Save latest todoList to local storage
            //   LocalStorage.saveTodoList(todoList);

            //   todoList.refresh();

            //   Get.back();
            //   titleController.value.clear();
            //   subtitleController.value.clear();
            // },

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
