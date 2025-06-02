import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/data/model/get_todo_model.dart';
import 'package:todo_app/utils/local_storage.dart';
import 'package:todo_app/utils/utils.dart';
import 'package:todo_app/view/home/home_controller.dart';
import 'package:todo_app/data/repository/todo_repository.dart';

void showUpdateDialog(BuildContext context, HomeController controller, GetTodoModel todo) {
  controller.titleController.value.text = todo.title ?? '';
  controller.subtitleController.value.text = todo.subtitle ?? '';
  controller.id.value = todo.id ?? '';
  debugPrint("Starting update for todo ID: ${controller.id.value}");

  RxBool isSaving = false.obs;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Update To-Do'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller.titleController.value,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: controller.subtitleController.value,
            decoration: InputDecoration(labelText: 'Subtitle'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Cancel'),
        ),
        Obx(() => ElevatedButton(
              onPressed: isSaving.value
                  ? null
                  : () async {
                      if (controller.titleController.value.text.isEmpty) {
                        Get.snackbar('Error', 'Title cannot be empty', backgroundColor: Colors.red);
                        return;
                      }

                      if (controller.id.value.isEmpty) {
                        debugPrint(" Error: Todo ID is empty");
                        Get.snackbar('Error', 'Invalid todo ID', backgroundColor: Colors.red);
                        return;
                      }

                      isSaving.value = true;
                      Get.back();

                      if (await getConnectivityResult()) {
                        debugPrint(" Online - updating todo via API (ID: ${controller.id.value})");
                        await TodoRepository.updateTodoApi(
                          id: controller.id.value,
                          updatedTitle: controller.titleController.value.text,
                          updatedSubtitle: controller.subtitleController.value.text,
                          onSuccess: () {
                            final index = controller.todoList.indexWhere((t) => t.id == controller.id.value);
                            if (index != -1) {
                              controller.todoList[index] = GetTodoModel(
                                id: controller.id.value,
                                title: controller.titleController.value.text,
                                subtitle: controller.subtitleController.value.text,
                                createdAt: controller.todoList[index].createdAt,
                              );
                              LocalStorage.saveTodoList(controller.todoList);
                              debugPrint(" Updated todo via API: ${controller.id.value}");
                            } else {
                              debugPrint(" Could not find todo with ID: ${controller.id.value}");
                            }
                          },
                        );
                      } else {
                        debugPrint(" Offline - updating todo locally (ID: ${controller.id.value})");
                        controller.updateTodoLocally(
                          controller.id.value,
                          controller.titleController.value.text,
                          controller.subtitleController.value.text,
                        );
                        Get.snackbar(
                          'Offline Mode',
                          'Todo updated locally. Changes will sync when online.',
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                        );
                      }

                      controller.titleController.value.clear();
                      controller.subtitleController.value.clear();
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
