import 'package:get/get.dart';
import 'package:todo_app/utils/routes/app_routes.dart';
import 'package:todo_app/view/home/home_screen.dart';
import 'package:todo_app/view/todos/add_todo.dart';

class AppPages {
  AppPages._();

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.home,
      page: () => HomeScreen(),
    ),
    GetPage(
      name: AppRoutes.addTodo,
      page: () => AddTodo(),
    ),
  ];
}
