import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_app/data/model/get_todo_model.dart';
import 'package:todo_app/data/repository/todo_repository.dart';
import 'package:todo_app/utils/app_colors.dart';
import 'package:todo_app/utils/app_text_style.dart';
import 'package:todo_app/utils/local_storage.dart';
import 'package:todo_app/utils/utils.dart';
import 'package:todo_app/view/home/home_controller.dart';

class AppDialog {
  AppDialog._();

  static final HomeController controller = Get.find<HomeController>();

  static void showUpdateDialog(
    BuildContext context,
    GetTodoModel todo,
  ) {
    controller.titleController.value.text = todo.title ?? '';
    controller.subtitleController.value.text = todo.subtitle ?? '';
    controller.id.value = todo.id ?? '';
    RxBool isSaving = false.obs;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
          side: BorderSide(color: AppColors.greenColor, width: 1),
        ),
        backgroundColor: AppColors.lightGreen1Color,
        elevation: 1,
        title: Text(
          'Update To-Do',
          style: AppTextStyles.dialogTitle.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
             maxLines: 2,
              controller: controller.titleController.value,
              decoration: InputDecoration(
                hintText: 'Title',
                
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.purpleColor, width: 2),
                ),
              ),
            ),
            10.verticalSpace,
            TextField(
                maxLines: 2,
              controller: controller.subtitleController.value,
              decoration: InputDecoration(
                hintText: 'Description',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.purpleColor, width: 2),
                ),
              ),
            ),
            10.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Obx(
                  () => SizedBox(
                    width: 150.w,
                    height: 30.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greenColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                      ),
                      onPressed: () async {
                        if (controller.titleController.value.text.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Title cannot be empty',
                            icon: Icon(
                              Icons.error,
                              color: AppColors.whiteColor,
                            ),
                            backgroundColor: AppColors.orangeColor,
                            colorText: AppColors.whiteColor,
                          );
                          return;
                        }

                        isSaving.value = true;
                        Get.back(); // Close dialog immediately

                        if (await getConnectivityResult()) {
                          debugPrint(" Online - updating todo via API");
                          await TodoRepository.updateTodoApi(
                            id: controller.id.value,
                            updatedTitle: controller.titleController.value.text,
                            updatedSubtitle: controller.subtitleController.value.text,
                            onSuccess: () {
                              // Update the existing todo in the list
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
                              }
                            },
                          );
                        } else {
                          debugPrint(" Offline - updating todo locally");
                          controller.updateTodoLocally(
                            controller.id.value,
                            controller.titleController.value.text,
                            controller.subtitleController.value.text,
                          );
                          Get.snackbar(
                            'Offline Mode',
                            'Todo saved locally. Will sync when online.',
                            backgroundColor: AppColors.greenColor,
                            colorText: Colors.white,
                            icon: Icon(
                              Icons.done,
                              color: AppColors.whiteColor,
                            ),
                          );
                        }

                        controller.titleController.value.clear();
                        controller.subtitleController.value.clear();
                        isSaving.value = false;
                      },
                      child: isSaving.value
                          ? SizedBox(
                              width: 15,
                              height: 15,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : Text(
                              'Save',
                              style: AppTextStyles.appBarTitle.copyWith(color: AppColors.whiteColor),
                            ),
                    ),
                  ),
                ),
                5.horizontalSpace,
                IconButton(
                  onPressed: () {
                    controller.titleController.value.clear();
                    controller.subtitleController.value.clear();
                   
                  },
                  icon: Icon(Icons.close, color: AppColors.orangeColor),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(AppColors.lightGreen4Color),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  static void showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
          side: BorderSide(color: AppColors.greenColor, width: 1),
        ),
        backgroundColor: AppColors.lightGreen1Color,
        title: Text(
          'New Task',
          style: AppTextStyles.dialogTitle.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField( maxLines: 2,
              controller: controller.titleController.value,
              decoration: InputDecoration(
                hintText: 'Title',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.purpleColor, width: 2),
                ),
              ),
            ),
            10.verticalSpace,
            TextField( maxLines: 2,
              controller: controller.subtitleController.value,
              decoration: InputDecoration(
                hintText: 'Description',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.purpleColor, width: 2),
                ),
              ),
            ),
            20.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 150.w,
                  height: 30.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      if (controller.titleController.value.text.isEmpty) {
                        Get.snackbar(
                          'Error',
                          'Title cannot be empty',
                          icon: Icon(
                            Icons.error,
                            color: AppColors.whiteColor,
                          ),
                          backgroundColor: AppColors.orangeColor,
                          colorText: AppColors.whiteColor,
                        );
                        return;
                      }

                      Get.back();

                      // Create a temporary todo with a local ID
                      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
                      final newTodo = GetTodoModel(
                        id: tempId,
                        title: controller.titleController.value.text,
                        subtitle: controller.subtitleController.value.text,
                        createdAt: DateTime.now(),
                      );

                      // Add to local storage immediately
                      controller.todoList.add(newTodo);
                      LocalStorage.saveTodoList(controller.todoList);
                      debugPrint(" Added new todo to local storage: ${newTodo.title}");

                      if (await getConnectivityResult()) {
                        debugPrint(" Online - syncing new todo with API");
                        // Try to sync with API
                        await TodoRepository.postTodoApi(
                          title: controller.titleController.value.text,
                          subtitle: controller.subtitleController.value.text,
                          onSuccess: (response) {
                            // Update the todo with the server ID
                            final serverId = response['id']?.toString();
                            if (serverId != null) {
                              final index = controller.todoList.indexWhere((todo) => todo.id == tempId);
                              if (index != -1) {
                                controller.todoList[index] = GetTodoModel(
                                  id: serverId,
                                  title: response['title'],
                                  subtitle: response['subtitle'],
                                  createdAt: response['createdAt'] != null ? DateTime.parse(response['createdAt']) : DateTime.now(),
                                );
                                LocalStorage.saveTodoList(controller.todoList);
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
                          backgroundColor: AppColors.greenColor,
                          colorText: Colors.white,
                          icon: Icon(
                            Icons.done,
                            color: AppColors.whiteColor,
                          ),
                        );
                      }

                      controller.titleController.value.clear();
                      controller.subtitleController.value.clear();
                    },
                    child: Text(
                      'Add Task',
                      style: AppTextStyles.appBarTitle.copyWith(color: AppColors.whiteColor),
                    ),
                  ),
                ),
                5.horizontalSpace,
                IconButton(
                  onPressed: () {
                    controller.titleController.value.clear();
                    controller.subtitleController.value.clear();
                
                  },
                  icon: Icon(Icons.close, color: AppColors.orangeColor),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(AppColors.lightGreen4Color),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
