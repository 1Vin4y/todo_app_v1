import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';


bool isValEmpty(dynamic val) {
  String? value = val.toString();
  return (val == null || value.isEmpty || value == "null" || value == "" || value == "NULL");
}

bool isRegistered<S>({RxBool? isLoader}) {
  if (Get.isRegistered<S>()) {
    return true;
  } else {
    debugPrint(S.toString());

    isLoader?.value = false;
    return false;
  }
}

/// ------ To Check Internet Ability -------------------->>>
ConnectivityResult? connectivityResult;
final Connectivity connectivity = Connectivity();

Future<bool> getConnectivityResult({bool showToast = true, RxBool? isLoader}) async {
  try {
    connectivityResult = (await connectivity.checkConnectivity()) as ConnectivityResult?;
    if (connectivityResult == ConnectivityResult.wifi || connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else {
      if (showToast == true) {
//UiUtils.toast(AppStrings.noInternetAvailable);
        debugPrint('No Internet Available');
        isLoader?.value = false;
      }
      return false;
    }
  } on PlatformException catch (e) {
    // printErrors(type: "getConnectivityResult Function", errText: e);
    debugPrint("Error Message : $e");
    // UiUtils.toast(AppStrings.noInternetAvailable);
    debugPrint('No internet Available');
    isLoader?.value = false;
    return false;
  }
}
