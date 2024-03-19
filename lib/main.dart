import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_to_app/app/app%20info/app_info.dart';

import 'app/data/custom_dialog.dart';
import 'app/modules/webview_screen/webview_screen.dart';
import 'package:permission_handler/permission_handler.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.location.request();
  await Permission.camera.request();
    if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  runApp(WebviewApp());
}

class WebviewApp extends StatelessWidget {
  const WebviewApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebviewScreen(
        loadUrl: AppInfo.webUrl,
      ),
    );
  }
}