import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/app/app%20info/app_info.dart';
import 'package:web_to_app/app/modules/webview_screen/view/webview_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration(seconds: 5)).then((value) =>
        Get.to(() => WebviewScreen(loadUrl: AppInfo.webUrl)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.red,);
  }
}