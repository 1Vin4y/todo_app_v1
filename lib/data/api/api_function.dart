import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:todo_app/data/api/api_class.dart';
import 'package:todo_app/data/handler/api_urls.dart';
import 'package:todo_app/utils/local_storage.dart';
import 'package:todo_app/utils/utils.dart';

class ApiFunction {
  ApiFunction._();

  /// ***********************************************************************************
  ///                                    OPTIONS & HEADER
  /// ***********************************************************************************

  static Options getOptionsAndHeader({Duration? receiveTimeout}) => Options(
        receiveTimeout: receiveTimeout ?? const Duration(seconds: 7),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${LocalStorage.accessToken.value}",
          //   "platform": APIPlatform.app.name,
        },
      );

  /// ------ To Call Get API -------------------->>>
  static Future<dynamic> getApiCall({
    required String apiName,
    dynamic body,
    bool? isDecode,
    dynamic params,
    Duration? receiveTimeout,
    bool withBaseUrl = true,
    bool showErrorToast = true,
  }) async {
    if (await getConnectivityResult()) {
      dynamic response = await HttpUtil(errorToast: showErrorToast).get(
        withBaseUrl == true ? (HttpUtil.apiUrl + apiName) : apiName,
        body: body,
        queryParameters: params,
        isDecode: isDecode ?? false,
        options: getOptionsAndHeader(receiveTimeout: receiveTimeout),
      );
      return response;
    }
  }

  /// ------ To Call Post API -------------------->>>
  static Future<dynamic> postApiCall({
    required String apiName,
    dynamic params,
    dynamic body,
    bool? isDecode,

    /// `null` or `Duration.zero` means no timeout limit.
    Duration? receiveTimeout,
    bool withBaseUrl = true,
    bool showErrorToast = true,
  }) async {
    if (await getConnectivityResult()) {
      if (kDebugMode) {
        if (!isValEmpty(params)) {
          debugPrint("Post API params (Start)");

          debugPrint("$apiName - With params $params");
          debugPrint("Post API params (End)");
        }

        if (!isValEmpty(body)) {
          debugPrint("Post API Body (Start)");
          debugPrint("$apiName - With Body $body");
          debugPrint("Post API Body (Start)");
        }
      }

      dynamic response = await HttpUtil(errorToast: showErrorToast).post(
        withBaseUrl == true ? (ApiUrls.baseUrl + apiName) : apiName,
        isDecode: isDecode ?? false,
        body: body,
        queryParameters: params,
        options: Options(
          receiveTimeout: receiveTimeout ?? const Duration(seconds: 7),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${LocalStorage.accessToken.value}",
          },
        ),
      );
      return response;
    }
  }

  /// ------ To Call DELETE API -------------------->>>
  static Future<dynamic> deleteApiCall({
    required String apiName,
    dynamic body,
    dynamic prams,
    bool? isDecode,
    Duration? receiveTimeout,
    bool withBaseUrl = true,
    bool showErrorToast = true,
  }) async {
    if (await getConnectivityResult()) {
      if (kDebugMode) {
        if (!isValEmpty(body)) {
          debugPrint("Delete API Body (Start)");
          debugPrint("$apiName - With Body $body");
          debugPrint("Delete API Body (End)");
        }
      }
      dynamic response = await HttpUtil(errorToast: showErrorToast).delete(
        withBaseUrl == true ? (ApiUrls.baseUrl + apiName) : apiName,
        body: body,
        isDecode: isDecode ?? false,
        queryParameters: prams,
        options: Options(
          receiveTimeout: receiveTimeout ?? const Duration(seconds: 7),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${LocalStorage.accessToken.value}",
          },
        ),
      );
      return response;
    }
  }

  /// ------ To Call Put API -------------------->>>
  static Future<dynamic> putApiCall({
    required String apiName,
    dynamic params,
    dynamic body,
    bool? isDecode,
    Duration? receiveTimeout,
    bool withBaseUrl = true,
    bool showErrorToast = true,
  }) async {
    if (await getConnectivityResult()) {
      if (kDebugMode) {
        if (!isValEmpty(params)) {
          debugPrint("Put API params (Start)");
          debugPrint("$apiName - With params $params");
          debugPrint("Put API params (End)");
        }

        if (!isValEmpty(body)) {
          debugPrint("Put API Body (Start)");
          debugPrint("$apiName - With Body $body");
          debugPrint("Put API Body (End)");
        }
      }

      dynamic response = await HttpUtil(errorToast: showErrorToast).put(
        withBaseUrl == true ? (ApiUrls.baseUrl + apiName) : apiName,
        isDecode: isDecode ?? false,
        body: body,
        queryParameters: params,
        options: Options(
          receiveTimeout: receiveTimeout ?? const Duration(seconds: 7),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${LocalStorage.accessToken.value}",
          },
        ),
      );
      return response;
    }
  }
}
