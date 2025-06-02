import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_app/data/model/get_todo_model.dart';
import 'package:todo_app/data/repository/todo_repository.dart';
import 'package:todo_app/utils/app_colors.dart';
import 'package:todo_app/utils/app_text_style.dart';
import 'package:todo_app/utils/utils.dart';
import 'package:todo_app/view/home/home_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.darkPurpleColor,
          title: Text("Todo App", style: AppTextStyles.appBarTitle),
          centerTitle: true,
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
        floatingActionButton: FloatingActionButton(
          onPressed: () => controller.showAddDialog(context),
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTodoTile(BuildContext context, GetTodoModel todo, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.black12,
        border: Border.all(color: AppColors.purpleColor, width: 1.5.w),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Card(
        color: AppColors.transparentColor,
        elevation: 1,
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: Text((index + 1).toString(), style: AppTextStyles.todoSubtitle),
          title: Text(todo.title ?? '', style: AppTextStyles.todoTitle),
          subtitle: Text(todo.subtitle ?? '', style: AppTextStyles.todoSubtitle),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => controller.showUpdateDialog(context, todo),
                icon: Icon(Icons.edit, color: AppColors.lightPeachColor),
              ),
              Obx(
                () {
                  final isDeleting = controller.deletingId.value == todo.id;
                  return IconButton(
                    onPressed: () async {
                      controller.deletingId.value = todo.id ?? '';
                      if (await getConnectivityResult()) {
                        await TodoRepository.deleteTodoApi(
                          id: todo.id,
                          onSuccess: () {
                            controller.deleteTodoLocally(todo.id!);
                          },
                        );
                      } else {
                        controller.deleteTodoLocally(todo.id ?? '');
                        Get.snackbar(
                          'Offline Mode',
                          'Todo deleted locally. Changes will sync when online.',
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                        );
                      }
                      controller.deletingId.value = '';
                    },
                    icon: isDeleting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(Icons.delete, color: AppColors.orangeColor),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Nothing to show. List is empty.", style: AppTextStyles.emptyMessage),
        ],
      ),
    );
  }
}
