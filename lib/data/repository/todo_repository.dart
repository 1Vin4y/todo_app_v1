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

  static Future<void> getTodoApi({RxBool? isLoader, bool isInitial = true}) async {
 
    if (await getConnectivityResult(isLoader: isLoader)) {
     
      if (Get.isRegistered<HomeController>()) {
        final HomeController controller = Get.find<HomeController>();

        try {
          isLoader?.value = true;

       
          final localTodos = LocalStorage.getTodoList();
          if (localTodos.isNotEmpty) {
            controller.todoList.assignAll(localTodos);
            debugPrint(" Loaded ${localTodos.length} todos from local storage");
          }

   
          await ApiFunction.getApiCall(
            apiName: ApiUrls.getTodoApi,
            showErrorToast: false,
          ).then((response) {
            if (response != null && response is List) {
              final getTodos = response.map((item) => GetTodoModel.fromJson(item)).toList();

              if (getTodos.isNotEmpty) {
                controller.todoList.assignAll(getTodos);
                LocalStorage.saveTodoList(controller.todoList);
                debugPrint(" Synced ${getTodos.length} items from API to local storage");
              }
            }
          });
        } catch (e) {
          debugPrint(" API Error: $e - keeping local data");
        } finally {
          isLoader?.value = false;
        }
      }
    } else {
  
      if (Get.isRegistered<HomeController>()) {
        final HomeController controller = Get.find<HomeController>();
        final localTodos = LocalStorage.getTodoList();
        if (localTodos.isNotEmpty) {
          controller.todoList.assignAll(localTodos);
          debugPrint("Offline - loaded ${localTodos.length} todos from local storage");
        }
      }
      isLoader?.value = false;
    }
  }

  /// ***********************************************************************************
  /// *                                    POST METHOD                                  *
  /// ***********************************************************************************
  static Future<void> postTodoApi({
    RxBool? isLoader,
    bool isInitial = true,
    String? title,
    String? subtitle,
    Function(Map<String, dynamic> response)? onSuccess,
  }) async {
    // Try to sync with API if online
    if (await getConnectivityResult(isLoader: isLoader)) {
      try {
        isLoader?.value = true;
        await ApiFunction.postApiCall(
          apiName: ApiUrls.postTodoApi,
          showErrorToast: false,
          body: {
            if (!isValEmpty(title)) "title": title,
            if (!isValEmpty(subtitle)) "subtitle": subtitle,
          },
        ).then((response) {
          if (response != null && onSuccess != null) {
            onSuccess(response as Map<String, dynamic>);
          }
        });
      } catch (e) {
        debugPrint(" API Error while posting: $e - keeping local data");
      } finally {
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

        await ApiFunction.deleteApiCall(apiName: ApiUrls.deleteTodoApi(id: id ?? '')).then(
          (response) async {
            if (response != null) {
              if (isRegistered<HomeController>()) {
                final HomeController controller = Get.find<HomeController>();

                controller.todoList.removeWhere((todo) => todo.id == id);
              }

              if (onSuccess != null) {
                onSuccess().call();
              }
              isLoader?.value = false;
            }
            isLoader?.value = false;
          },
        );
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
          if (response != null) {
            if (onSuccess != null) {
              onSuccess();
            }
            isLoader?.value = false;
          }
          isLoader?.value = false;
        });
      } catch (e) {
        isLoader?.value = false;
        debugPrint("Error Msg :  $e");
      }
    }
  }
}
