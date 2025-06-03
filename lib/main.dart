import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_app/utils/app_colors.dart';
import 'package:todo_app/utils/local_storage.dart';
import 'package:todo_app/view/home/home_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await LocalStorage.init();

  // Load and verify initial data
  final initialTodos = LocalStorage.getTodoList();
  debugPrint("App started with ${initialTodos.length} todos in local storage");
  LocalStorage.printTodoList(); // Print current todos for debugging

  runApp(
    const TodoApp(),
  );
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Todo App',
          theme: ThemeData(
          
            scaffoldBackgroundColor: AppColors.lightGreen1Color,
          ),
          home: child,
        );
      },
      child: HomeScreen(),
    );
  }
}
