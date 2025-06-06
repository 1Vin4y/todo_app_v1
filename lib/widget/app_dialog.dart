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
      barrierDismissible: true,
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
            GestureDetector(
              onTap: !isSaving.value
                  ? () {
                      Get.back();
               
                    }
                  : () {
                      controller.titleController.value.clear();
                      controller.subtitleController.value.clear();
                      Get.back();
                    },
              child: Icon(Icons.cancel_outlined),
            ),
          ],
        ),
        content: SizedBox(
          width: 300.w,
          child: Form(
            key: controller.updateFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: controller.titleController.value,
                  label: 'Title',
                  hint: 'Title',
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
                18.verticalSpace,
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
                          onPressed: isSaving.value
                              ? () {}
                              : () async {
                                  if (!controller.updateFormKey.currentState!.validate()) return;
                                  if (controller.titleController.value.text.isEmpty) {
                                    return;
                                  }

                                  isSaving.value = true;

                                  if (await getConnectivityResult()) {
                                    debugPrint(" Online - updating todo via API");
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
                                  height: 14.h,
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
                    Obx(
                      () => SizedBox(
                        height: 35.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lightPeach1Color,
                            side: BorderSide(),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                            ),
                          ),
                          onPressed: isSaving.value == true
                              ? () {}
                              : () {
                                  controller.titleController.value.clear();
                                  controller.subtitleController.value.clear();
                                },
                          child: Text(
                            'Clear',
                            style: AppTextStyles.todoSubtitle.copyWith(fontSize: 12.sp, color: AppColors.orangeColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                8.verticalSpace
              ],
            ),
          ),
        ),
      ),
    );
  }
}
