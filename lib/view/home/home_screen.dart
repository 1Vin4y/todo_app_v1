import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/data/model/get_todo_model.dart';
import 'package:todo_app/data/repository/todo_repository.dart';
import 'package:todo_app/utils/app_colors.dart';
import 'package:todo_app/utils/app_text_style.dart';
import 'package:todo_app/utils/utils.dart';
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        appBar: AppBar(
          backgroundColor: AppColors.lightGreen4Color,
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
                onRefresh: () async => await TodoRepository.getTodoApi(),
                child: ListView.builder(
                  itemCount: controller.todoList.length,
                  itemBuilder: (context, index) {
                    final todo = controller.todoList[index];
                    return _buildTodoTile(context, todo, index);
                  },
                ),
              )
            : _buildEmptyState(),
        floatingActionButton: Container(
          width: 60.w,
          height: 60.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                // ignore: deprecated_member_use
                AppColors.lightGreen4Color.withOpacity(0.8),
                AppColors.lightGreen4Color,
              ],
            ),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: AppColors.lightGreen4Color.withOpacity(0.6),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: FloatingActionButton(
            backgroundColor: AppColors.greenColor,
            onPressed: () => AppDialog.showAddDialog(context),
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildTodoTile(BuildContext context, GetTodoModel todo, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.lightGreen4Color,
            offset: Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
        color: AppColors.lightGreen3Color,
        border: Border.all(color: AppColors.lightGreen4Color, width: 1.5.w),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: ListTile(
        titleAlignment: ListTileTitleAlignment.top,
        contentPadding: EdgeInsets.only(
          left: 16.w,
        ),
        leading: Text((index + 1).toString(), style: AppTextStyles.todoSubtitle),
        title: Text((todo.title ?? '').toUpperCase(), style: AppTextStyles.todoTitle.copyWith(color: AppColors.greenColor)),
        subtitle: Text(todo.subtitle ?? '', style: AppTextStyles.todoSubtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => AppDialog.showUpdateDialog(context, todo),
              icon: Icon(Icons.edit, color: AppColors.black54),
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
                    if (await getConnectivityResult()) {
                      Get.snackbar(
                        'Deleted',
                        'Todo Deleted',
                        icon: Icon(Icons.delete, color: AppColors.whiteColor),
                        backgroundColor: AppColors.orangeColor,
                        colorText: AppColors.whiteColor,
                      );
                    } else {
                      Get.snackbar(
                        'Deleted',
                        'Todo Deleted Locally',
                        icon: Icon(Icons.delete, color: AppColors.whiteColor),
                        backgroundColor: AppColors.orangeColor,
                        colorText: AppColors.whiteColor,
                      );
                    }
                  },
                  icon: isDeleting
                      ? SizedBox(
                          width: 15.w,
                          height: 15.h,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.delete, color: AppColors.orangeColor),
                );
              },
            ),
          ],
        ),
      ),
    );
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
