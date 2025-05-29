import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:todo_app/data/repository/todo_repository.dart';
import 'package:todo_app/utils/app_colors.dart';
import 'package:todo_app/utils/app_text_style.dart';
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
        floatingActionButton: FloatingActionButton(
          //review needed
          onPressed: () => controller.showAddDialog(context),
          child: Icon(Icons.add),
        ),
        body: controller.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : controller.todoList.isNotEmpty
                ? RefreshIndicator(
                    onRefresh: () async => await TodoRepository.getTodoApi(),
                    child: ListView.builder(
                      itemCount: controller.todoList.length,
                      itemBuilder: (context, index) {
                        final todo = controller.todoList[index];
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: AppColors.black12,
                            border: Border.all(
                              color: AppColors.purpleColor,
                              width: 1.5.w,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Card(
                            color: AppColors.transparentColor,
                            elevation: 1,
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              leading: Text(todo.id ?? '', style: AppTextStyles.todoSubtitle),
                              title: Text(todo.title ?? '', style: AppTextStyles.todoTitle),
                              subtitle: Text(todo.subtitle ?? '', style: AppTextStyles.todoSubtitle),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      controller.showUpdateDialog(context, todo); //review needed
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      color: AppColors.lightPeachColor,
                                    ),
                                  ),
                                  IconButton(
                                    //review needed
                                    onPressed: () async {
                                      await TodoRepository.deleteTodoApi(
                                        isLoader: controller.isLoading,
                                        id: todo.id,
                                      );
                                      await TodoRepository.getTodoApi(
                                        isLoader: controller.isLoading,
                                      );


                                      final myValue =  GetStorage().write('title', controller.titleController.value.text);
                                      debugPrint("my value : ${myValue.toString()}");

                                      
                                      // await TodoRepository.deleteTodoApi(
                                      //     isLoader: controller.isLoading,
                                      //     id: todo.id,
                                      //     onSuccess: () async {
                                      //       await TodoRepository.getTodoApi(
                                      //         isLoader: controller.isLoading,
                                      //       );
                                      //     });
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: AppColors.orangeColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Center(child: Text("Nothing to show. List is empty.", style: AppTextStyles.emptyMessage)),
      ),
    );
  }
}
