import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/data/model/get_todo_model.dart';
import 'package:todo_app/data/repository/todo_repository.dart';
import 'package:todo_app/utils/app_colors.dart';
import 'package:todo_app/utils/app_text_style.dart';
import 'package:todo_app/utils/routes/app_routes.dart';
import 'package:todo_app/view/home/home_controller.dart';
import 'package:todo_app/widget/app_dialog.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final HomeController controller = Get.put(HomeController());
  final DateTime date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    String formattedDayDate = DateFormat('EEE, MMM d').format(date.toLocal());

    return Obx(
      () => Scaffold(
        appBar: AppBar(
          surfaceTintColor: AppColors.lightPeachColor,
          backgroundColor: AppColors.lightPeachColor,
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$formattedDayDate\n',
                  style: AppTextStyles.appBarTitle.copyWith(
                    fontSize: 12,
                    color: AppColors.greyColor,
                  ),
                ),
                TextSpan(
                  text: "Todo List",
                  style: AppTextStyles.appBarTitle.copyWith(color: AppColors.darkPurpleColor),
                ),
              ],
            ),
          ),
        ),
        body: controller.todoList.isNotEmpty
            ? RefreshIndicator(
                color: AppColors.darkPurpleColor,
                backgroundColor: AppColors.lightPeachColor,
                onRefresh: () async => await TodoRepository.getTodoApi(),
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 15.h, bottom: 85.h),
                  itemCount: controller.todoList.length,
                  itemBuilder: (context, index) {
                    final todo = controller.todoList[index];
                    return _buildTodoTile(context, todo, index);
                  },
                ),
              )
            : _buildEmptyState(),
        floatingActionButton: Container(
          margin: EdgeInsets.only(right: 8.w),
          width: 60.w,
          height: 60.h,
          decoration: BoxDecoration(
            border: Border.all(),
            shape: BoxShape.circle,
          ),
          child: FloatingActionButton(
            backgroundColor: AppColors.lightPeachColor,
            onPressed: () {
              // controller.titleController.value.clear();
              // controller.subtitleController.value.clear();
              Get.toNamed(AppRoutes.addTodo);
            },
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: AppColors.darkPurpleColor),
          ),
        ),
      ),
    );
  }

  Widget _buildTodoTile(BuildContext context, GetTodoModel todo, int index) {
    return Obx(() {
      final isCompleted = controller.completedTodos[todo.id] ?? false;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.grey.shade200 : AppColors.peachColor,
          border: Border.all(width: 1.5.w),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                checkColor: AppColors.darkPurpleColor,
                activeColor: AppColors.transparentColor,
                value: isCompleted,
                onChanged: (value) {
                  controller.completedTodos[todo.id ?? ''] = value ?? false;
                },
              ),
              3.horizontalSpace,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (todo.title ?? '').trim().toUpperCase(),
                        style: AppTextStyles.todoTitle.copyWith(
                          color: AppColors.darkPurpleColor,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      Text(
                        (todo.subtitle ?? '').replaceAll(RegExp(r'\n+'), ' ').trim(),
                        style: AppTextStyles.todoSubtitle.copyWith(
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              3.horizontalSpace,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isCompleted)
                    GestureDetector(
                      onTap: () => AppDialog.showUpdateDialog(context, todo),
                      child: Icon(Icons.edit, color: AppColors.black54),
                    ),
                  Obx(
                    () {
                      final isDeleting = controller.deletingId.value == todo.id;
                      return IconButton(
                        onPressed: () async {
                          controller.deletingId.value = todo.id ?? '';
                          await TodoRepository.deleteTodoApi(id: todo.id);
                          controller.deleteTodoLocally(todo.id ?? '');
                          controller.deletingId.value = '';
                        },
                        icon: isDeleting
                            ? SizedBox(
                                width: 15.w,
                                height: 14.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.darkPurpleColor,
                                ),
                              )
                            : Icon(Icons.delete, color: AppColors.orangeColor),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/svg/empty_data.svg'),
          5.verticalSpace,
          Text("WOW , Such an Empty", style: AppTextStyles.emptyMessage),
        ],
      ),
    );
  }
}
