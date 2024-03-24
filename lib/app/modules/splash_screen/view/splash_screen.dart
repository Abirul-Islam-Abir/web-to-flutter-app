import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/app/app%20info/app_info.dart';
import 'package:web_to_app/app/modules/webview_screen/view/webview_screen.dart';

import '../../../data/app_images.dart';
import '../../../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration(seconds: 3))
        .then((value) => Get.to(() => WebviewScreen(loadUrl: AppInfo.webUrl)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              const Spacer(),
              Container(
                  width: MediaQuery.of(context).size.width / 1.5,
                  height: MediaQuery.of(context).size.width / 2,
                  child: Image.asset(AppImages.splashLogo)),
              const Spacer(),
              Text(AppInfo.appName,
                  style: const TextStyle(color: AppColor.kGreyColor)),
              Text('Version:${AppInfo.appVersion}',
                  style: const TextStyle(color: AppColor.kGreyColor)),
            ],
          ),
        ),
      ),
    );
  }
}