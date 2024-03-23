import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../main.dart';
import '../../data/custom_dialog.dart';
import 'components/forward_back_navigate.dart';

class WebviewScreen extends StatefulWidget {
  const WebviewScreen({Key? key, required this.loadUrl}) : super(key: key);
  final String loadUrl;
  @override
  _WebviewScreenState createState() => new _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;

  late PullToRefreshController pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: handleWillPop,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(url: WebUri(widget.loadUrl)),
                initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                        javaScriptEnabled: true,
                        useOnDownloadStart: true,
                        useOnLoadResource: true,
                        useShouldOverrideUrlLoading: true,
                        cacheEnabled: true,
                        preferredContentMode: UserPreferredContentMode.MOBILE,
                        useShouldInterceptAjaxRequest: true,
                        mediaPlaybackRequiresUserGesture: true,
                        allowFileAccessFromFileURLs: true,
                        allowUniversalAccessFromFileURLs: true),
                    android: AndroidInAppWebViewOptions(
                      useHybridComposition: true,
                      allowFileAccess: true,
                      allowContentAccess: true,
                    ),
                    ios: IOSInAppWebViewOptions(
                      allowsAirPlayForMediaPlayback: true,
                      suppressesIncrementalRendering: true,
                      ignoresViewportScaleLimits: true,
                      selectionGranularity: IOSWKSelectionGranularity.DYNAMIC,
                      isPagingEnabled: true,
                      enableViewportScale: true,
                      sharedCookiesEnabled: true,
                      automaticallyAdjustsScrollIndicatorInsets: true,
                      useOnNavigationResponse: true,
                      allowsInlineMediaPlayback: true,
                    )),
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onCreateWindow:
                    (InAppWebViewController, createWindowRequest) async {
                  InAppWebViewController.addJavaScriptHandler(
                      handlerName: 'openDRMOKWindow', callback: (args) {});
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                androidOnPermissionRequest: (controller, origin,
                        resources) async =>
                    PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT),
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  var uri = navigationAction.request.url!;

                  if (![
                    "http",
                    "https",
                    "file",
                    "chrome",
                    "data",
                    "javascript",
                    "about"
                  ].contains(uri.scheme)) {
                    if (!await canLaunch(url)) {
                      // Launch the App
                      await launch(
                        url,
                      );
                      // and cancel the request
                      return NavigationActionPolicy.CANCEL;
                    }
                  }

                  return NavigationActionPolicy.ALLOW;
                },
                onLoadStop: (controller, url) async {
                  pullToRefreshController.endRefreshing();
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                onLoadError: (controller, url, code, message) {
                  pullToRefreshController.endRefreshing();
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    pullToRefreshController.endRefreshing();
                  }
                  setState(() {
                    this.progress = progress / 100;
                    urlController.text = this.url;
                  });
                },
                onUpdateVisitedHistory: (controller, url, androidIsReload) {
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                onConsoleMessage: (controller, consoleMessage) {
                  print(consoleMessage);
                },
              ),
              progress < 1.0
                  ? LinearProgressIndicator(value: progress)
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  DateTime? backButtonPressTime;

  Future<bool> handleWillPop(data) async {
    final now = DateTime.now();
    final backButtonHasNotBeenPressedOrSnackBarHasBeenClosed =
        backButtonPressTime == null ||
            now.difference(backButtonPressTime!) > Duration(seconds: 5);

    if (backButtonHasNotBeenPressedOrSnackBarHasBeenClosed) {
      backButtonPressTime = now;
      CustomDialog.onBackPressed(context);
      return false;
    }
    return false;
  }
}