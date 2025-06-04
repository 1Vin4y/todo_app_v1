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
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(color: AppColors.darkPurpleColor, width: 1.r),
        ),
        backgroundColor: AppColors.lightPeach1Color,
        elevation: 1,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Update To-Do',
              style: AppTextStyles.dialogTitle.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                Icons.cancel,
                color: AppColors.orangeColor,
                size: 30,
              ),
            )
          ],
        ),
        content: SizedBox(
          width: 300.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                cursorColor: AppColors.darkPurpleColor,
                maxLines: 1,
                minLines: 1,
                controller: controller.titleController.value,
                decoration: InputDecoration(
                  label: Text('Title', style: TextStyle(color: AppColors.darkPurpleColor)),
                  hintText: 'Title',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.darkPurpleColor, width: 2),
                  ),
                ),
              ),
              10.verticalSpace,
              TextField(
                cursorColor: AppColors.darkPurpleColor,
                maxLines: 5,
                minLines: 1,
                controller: controller.subtitleController.value,
                decoration: InputDecoration(
                  label: Text(
                    'Description',
                    style: TextStyle(color: AppColors.darkPurpleColor),
                  ),
                  hintText: 'Description',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.darkPurpleColor, width: 2),
                  ),
                ),
              ),
              15.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Obx(
                    () => SizedBox(
                      width: 0.45.sw,
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
                          if (controller.titleController.value.text.isEmpty) {
                            Get.snackbar(
                              'Error',
                              'Title cannot be empty',
                              snackPosition: SnackPosition.BOTTOM,
                              duration: Duration(milliseconds: 1500),
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
                          // Close dialog immediately

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
                            Get.back();
                            Get.snackbar(
                              'Offline Mode',
                              'Todo saved locally. Will sync when online.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.greenColor,
                              duration: Duration(milliseconds: 1500),
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
                          isSaving.value = false;
                        },
                        child: isSaving.value
                            ? SizedBox(
                                width: 15.w,
                                height: 15.h,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.darkPurpleColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : Text(
                                'Save',
                                style: AppTextStyles.appBarTitle.copyWith(color: AppColors.darkPurpleColor, fontWeight: FontWeight.normal),
                              ),
                      ),
                    ),
                  ),
                  5.horizontalSpace,
                  SizedBox(
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
              12.verticalSpace
            ],
          ),
        ),
      ),
    );
  }
}
