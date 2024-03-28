import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_to_app/app/app%20info/app_info.dart';
import 'package:web_to_app/app/modules/splash_screen/view/splash_screen.dart';

import 'app/modules/network_connectivity/network_controller.dart';
import 'app/modules/webview_screen/view/webview_screen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
await Permission.notification.request();
  runApp(const WebviewApp());
}

class WebviewApp extends StatelessWidget {
  const WebviewApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(NetworkController());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}