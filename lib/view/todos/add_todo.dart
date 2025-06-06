import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_app/data/model/get_todo_model.dart';
import 'package:todo_app/data/repository/todo_repository.dart';
import 'package:todo_app/res/app_textfield.dart';
import 'package:todo_app/utils/app_colors.dart';
import 'package:todo_app/utils/app_text_style.dart';
import 'package:todo_app/utils/local_storage.dart';
import 'package:todo_app/utils/utils.dart';
import 'package:todo_app/view/home/home_controller.dart';

class AddTodo extends StatelessWidget {
  AddTodo({super.key});

 final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightPeachColor,
        title: Text(
          "Add Task",
          style: AppTextStyles.appBarTitle.copyWith(color: AppColors.darkPurpleColor),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
            controller.titleController.value.clear();
            controller.subtitleController.value.clear();
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Form(
          key: controller.updateFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: controller.titleController.value,
                label: 'Title',
                hint: 'Title',
                minLines: 1,
                maxLines: 1,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title cannot be empty';
                  }
                  return null;
                },
              ),
              10.verticalSpace,
              AppTextField(
                controller: controller.subtitleController.value,
                label: 'Description',
                hint: 'Description',
                minLines: 1,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description cannot be empty';
                  }
                  return null;
                },
              ),
              20.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 0.65.sw,
                    height: 35.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightPeachColor,
                        side: BorderSide(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5.r),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        
                        if (!controller.updateFormKey.currentState!.validate()) return;

                        Get.back();

                        final tempId = DateTime.now().millisecondsSinceEpoch.toString();
                        final newTodo = GetTodoModel(
                          id: tempId,
                          title: controller.titleController.value.text,
                          subtitle: controller.subtitleController.value.text,
                          createdAt: DateTime.now(),
                        );

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
                          Get.back();
                          debugPrint(" Offline - todo saved locally only");
                          Get.snackbar(
                            'Offline Mode',
                            'Todo saved locally. Will sync when online.',
                            snackPosition: SnackPosition.BOTTOM,
                            duration: Duration(milliseconds: 1500),
                            backgroundColor: AppColors.greenColor,
                            colorText: Colors.white,
                            icon: Icon(
                              Icons.done,
                              color: AppColors.whiteColor,
                            ),
                          );
                        }
                        Get.back();
                        controller.titleController.value.clear();
                        controller.subtitleController.value.clear();
                      },
                      child: Text(
                        'Add Task',
                        style: AppTextStyles.appBarTitle.copyWith(color: AppColors.darkPurpleColor, fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                  5.horizontalSpace,
                  SizedBox(
                    //  width: 0.2.sw,
                    height: 35.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightPeach1Color,
                        side: BorderSide(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                      ),
                      onPressed: () {
                        controller.titleController.value.clear();
                        controller.subtitleController.value.clear();
                      },
                      child: Text(
                        'Clear',
                        style: AppTextStyles.todoSubtitle.copyWith(fontSize: 12.sp, color: AppColors.orangeColor),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
