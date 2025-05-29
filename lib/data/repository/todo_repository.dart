import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:todo_app/data/api/api_function.dart';
import 'package:todo_app/data/handler/api_urls.dart';
import 'package:todo_app/data/model/get_todo_model.dart';
import 'package:todo_app/utils/utils.dart';
import 'package:todo_app/view/home/home_controller.dart';



class TodoRepository {
  TodoRepository._();

  /// ***********************************************************************************
  /// *                                    GET METHOD                                    *
  /// ***********************************************************************************

  static Future<void> getTodoApi({RxBool? isLoader, bool isInitial = true}) async {
    if (isRegistered<HomeController>()) {
      if (await getConnectivityResult(isLoader: isLoader)) {
        try {
          isLoader?.value = true;
          await ApiFunction.getApiCall(
            apiName: ApiUrls.getTodoApi,
            showErrorToast: false,
          ).then((response) {
            if (response != null && response is List) {
              final List<GetTodoModel> getTodos = response.map((item) => GetTodoModel.fromJson(item as Map<String, dynamic>)).toList();
              final HomeController controller = Get.find<HomeController>();

              if (isInitial) {
                controller.todoList.assignAll(getTodos);
              } else {
                controller.todoList.addAll(getTodos);
              }
              controller.todoList.refresh();
            } else {
              debugPrint("Unexpected response format: $response");
            }
          });
          isLoader?.value = false;
        } catch (e) {
          isLoader?.value = false;
          debugPrint("Error Msg : $e");
        }
      }
    }
  }
  // static Future<void> getTodoApi({RxBool? isLoader, bool isInitial = true}) async {
  //   if (!isRegistered<HomeController>()) return;

  //   final HomeController controller = Get.find<HomeController>();

  //   final hasInternet = await getConnectivityResult(isLoader: isLoader);
  //   if (hasInternet) {
  //     try {
  //       isLoader?.value = true;

  //       final response = await ApiFunction.getApiCall(
  //         apiName: ApiUrls.getTodoApi,
  //         showErrorToast: false,
  //       );

  //       if (response != null && response is List) {
  //         final List<GetTodoModel> getTodos = response.map((item) => GetTodoModel.fromJson(item as Map<String, dynamic>)).toList();

  //         // ✅ Save to local storage
  //         LocalStorage.saveTodoList(getTodos);

  //         // ✅ Update controller
  //         controller.todoList.assignAll(getTodos);
  //         controller.todoList.refresh();
  //       }
  //     } catch (e) {
  //       debugPrint("Error Msg: $e");
  //     } finally {
  //       isLoader?.value = false;
  //     }
  //   } else {
  //     // ❌ Offline: Load from local storage
  //     final List<GetTodoModel> localTodos = LocalStorage.getTodoList();
  //     controller.todoList.assignAll(localTodos);
  //     controller.todoList.refresh();
  //   }
  // }

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
          if (response != null && response['success'] == true) {
            onSuccess!(response);
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
          if (response != null && response['success'] == true) {
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

          if (response != null && response['success'] == true) {
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
