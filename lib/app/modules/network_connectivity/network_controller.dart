
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkController extends GetxController {


  //this variable 0 = No Internet, 1 = connected to WIFI ,2 = connected to Mobile Data.
  static int connectionType = 0;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _streamSubscription;
  @override
  void onInit() {
    super.onInit();
    getConnectionType();
    _streamSubscription =
        _connectivity.onConnectivityChanged.listen(_updateState);
  }

  Future<void> getConnectionType() async {
    ConnectivityResult connectivityResult;
    try {
        connectivityResult = await (Connectivity().checkConnectivity());
    } on PlatformException {
      return;
    }
    return _updateState(connectivityResult);
  }

  // state update, of network, if you are connected to WIFI connectionType will get set to 1,
  // and update the state to the consumer of that variable.
  _updateState(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        if (Get.isSnackbarOpen) {
          Get.closeAllSnackbars();
          Get.back(closeOverlays: true);
        }
        connectionType = 1;
        break;
      case ConnectivityResult.mobile:
        if (Get.isSnackbarOpen) {

          Get.closeAllSnackbars();
          Get.back(closeOverlays: true);
        }
        connectionType = 2;
        break;
      case ConnectivityResult.none:
        showNetworkSnackBar();
        connectionType = 0;
        break;
      default:
        break;
    }
  }

  @override
  void onClose() {
    //stop listening to network state when app is closed
    _streamSubscription.cancel();
  }
}

void showNetworkSnackBar() {
  Get.dialog(
    PopScope(canPop: false, onPopInvoked: (didPop) {}, child: Container()),
    barrierDismissible: false,
  );
  Get.showSnackbar(const GetSnackBar(
    title: 'No Internet!',
    message: 'Please check your internet connection!',
    isDismissible: false,
    backgroundColor: Colors.blue,
    showProgressIndicator: true,
  ));

}