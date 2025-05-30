import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:todo_app/data/api/api_function.dart';
import 'package:todo_app/data/handler/api_urls.dart';
import 'package:todo_app/data/model/get_todo_model.dart';
import 'package:todo_app/utils/local_storage.dart';
import 'package:todo_app/utils/utils.dart';
import 'package:todo_app/view/home/home_controller.dart';

class TodoRepository {
  TodoRepository._();

  /// ***********************************************************************************
  /// *                                    GET METHOD                                    *
  /// ***********************************************************************************

  // static Future<void> getTodoApi({RxBool? isLoader, bool isInitial = true}) async {
  //   if (isRegistered<HomeController>()) {
  //     if (await getConnectivityResult(isLoader: isLoader)) {
  //       try {
  //         isLoader?.value = true;
  //         await ApiFunction.getApiCall(
  //           apiName: ApiUrls.getTodoApi,
  //           showErrorToast: false,
  //         ).then((response) {
  //           if (response != null && response is List) {
  //             List tempRes = response;
  //             final List<GetTodoModel> getTodos = tempRes.map((item) => GetTodoModel.fromJson(item)).toList();
  //             final HomeController controller = Get.find<HomeController>();
  //             if (isInitial) {
  //               controller.todoList.assignAll(getTodos);
  //             } else {
  //               controller.todoList.addAll(getTodos);
  //             }

  //             controller.todoList.refresh();
  //             LocalStorage.saveTodoList(controller.todoList);
  //           } else {
  //             debugPrint("Unexpected response format: $response");
  //           }
  //         });
  //         isLoader?.value = false;
  //       } catch (e) {
  //         isLoader?.value = false;
  //         debugPrint("Error Msg : $e");
  //       }
  //     } else {
  //       LocalStorage.getTodoList();
  //     }
  //   }
  // }

//   static Future<void> getTodoApi({RxBool? isLoader, bool isInitial = true}) async {
//     if (isRegistered<HomeController>()) {
//       final HomeController controller = Get.find<HomeController>();

//       if (await getConnectivityResult(isLoader: isLoader)) {
//         try {
//           isLoader?.value = true;

//           await ApiFunction.getApiCall(
//             apiName: ApiUrls.getTodoApi,
//             showErrorToast: false,
//           ).then((response) {
//             if (response != null && response is List) {
//               List tempRes = response;
//               final List<GetTodoModel> getTodos = tempRes.map((item) => GetTodoModel.fromJson(item)).toList();

//               if (isInitial) {
//                 controller.todoList.assignAll(getTodos);
//               } else {
//                 controller.todoList.addAll(getTodos);
//               }

//               controller.todoList.refresh();

//               LocalStorage.saveTodoList(controller.todoList);
//             } else {
//               debugPrint("Unexpected response format: $response");
//             }
//           });

//           isLoader?.value = false;
//         } catch (e) {
//           isLoader?.value = false;
//           debugPrint("Error Msg : $e");
//         }
//       // } else {
//       //   final List<GetTodoModel> localTodos = LocalStorage.getTodoList();
//       //   controller.todoList.assignAll(localTodos);
//       //   controller.todoList.refresh();
//       // }
//       } else {
//   final List<GetTodoModel> localTodos = LocalStorage.getTodoList();
//   final HomeController controller = Get.find<HomeController>();
//   controller.todoList.assignAll(localTodos);
//   controller.todoList.refresh();
//   controller.isLoading.value = false; // Ensure loader hides
// }

//     }
//   }
static Future<void> getTodoApi({RxBool? isLoader, bool isInitial = true}) async {
  final HomeController controller = Get.find<HomeController>();
  
  // Show local data immediately
  final localTodos = LocalStorage.getTodoList();
  if (localTodos.isNotEmpty) {
    controller.todoList.assignAll(localTodos);
    isLoader?.value = false;
  }

  // Only proceed with API call if online
  if (!(await getConnectivityResult(isLoader: isLoader))) {
    return; // Exit if offline
  }

  try {
    isLoader?.value = true;
    final response = await ApiFunction.getApiCall(
      apiName: ApiUrls.getTodoApi,
      showErrorToast: false,
    );
    
    if (response != null && response is List) {
      final getTodos = response.map((item) => GetTodoModel.fromJson(item)).toList();
      controller.todoList.assignAll(getTodos);
      LocalStorage.saveTodoList(controller.todoList);
    }
  } catch (e) {
    debugPrint("API Error: $e");
    // Even if API fails, we still have local data shown
  } finally {
    isLoader?.value = false;
  }
}
  /// ***********************************************************************************
  /// *                                    POST METHOD                                  *
  /// ***********************************************************************************
  static Future<void> postTodoApi({RxBool? isLoader, bool isInitial = true, String? title, String? subtitle, bool? isCompleted, Function(dynamic response)? onSuccess}) async {
    if (await getConnectivityResult(isLoader: isLoader)) {
      try {
        isLoader?.value = true;
        await ApiFunction.postApiCall(apiName: ApiUrls.postTodoApi, showErrorToast: false, body: {
          if (!isValEmpty(title)) "title": title,
          if (!isValEmpty(subtitle)) "subtitle": subtitle,
          if (!isValEmpty(isCompleted)) "isCompleted": isCompleted,
        }).then((response) {
          if (response != null) {
            onSuccess!(response).call();
          }
          isLoader?.value = false;
          return response;
        });
      } catch (e) {
        debugPrint("Error Msg :  $e");
        isLoader?.value = false;
      }
    }
  }

  /// ***********************************************************************************
  /// *                                    DELETE METHOD                                        *
  /// ***********************************************************************************
  static Future<void> deleteTodoApi({RxBool? isLoader, bool isInitial = true, String? id, Function()? onSuccess}) async {
    if (await getConnectivityResult(isLoader: isLoader)) {
      try {
        isLoader?.value = true;
        await ApiFunction.deleteApiCall(apiName: ApiUrls.deleteTodoApi(id: id!)).then((response) async {
          isLoader?.value = false;
          if (response != null) {
            if (isRegistered<HomeController>()) {
              final HomeController controller = Get.find<HomeController>();

              controller.todoList.removeWhere((todo) => todo.id == id);
            }

            if (onSuccess != null) {
              onSuccess();
            }
          }
          isLoader?.value = false;
          return response;
        });
      } catch (e) {
        isLoader?.value = false;
        debugPrint("Error Msg : $e");
      }
    }
  }

  /// ***********************************************************************************
  /// *                                    UPDATE METHOD                                *
  /// ***********************************************************************************
  static Future<void> updateTodoApi({
    RxBool? isLoader,
    bool isIntial = true,
    String? id,
    String? updatedTitle,
    String? updatedSubtitle,
    Function()? onSuccess,
  }) async {
    if (await getConnectivityResult(isLoader: isLoader)) {
      try {
        isLoader?.value = true;

        await ApiFunction.putApiCall(
          apiName: ApiUrls.updateTodoApi(id: id!),
          body: {
            if (!isValEmpty(updatedTitle)) "title": updatedTitle,
            if (!isValEmpty(updatedSubtitle)) "subtitle": updatedSubtitle,
          },
        ).then((response) async {
          isLoader?.value = false;

          if (response != null) {
            if (onSuccess != null) {
              onSuccess();
            }
          }
        });
      } catch (e) {
        isLoader?.value = false;
        debugPrint("Error Msg :  $e");
      }
    }
  }
}
