import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/custom_dialog.dart';

class WebviewScreen extends StatefulWidget {
  const WebviewScreen({super.key, required this.loadUrl});
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

  bool isLoadedScreen = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: handleWillPop,
      child: SafeArea(
        child: Scaffold(
          body: Stack(
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
                      geolocationEnabled: true,
                      saveFormData: true,
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
                    (inAppWebViewController, createWindowRequest) async {
                  inAppWebViewController.addJavaScriptHandler(
                      handlerName: 'openDRMOKWindow', callback: (args) {});
                  return null;
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
                    urlController.text = url;
                  });
                },
                onUpdateVisitedHistory: (controller, url, androidIsReload) {
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                onConsoleMessage: (controller, consoleMessage) {
                  print(consoleMessage.message);
                },
              ),
              /*    Positioned(
                bottom: 0,
                right: 200,
                left: 200,
                child: progress < 1.0
                    ? Center(child: CircularProgressIndicator(value: progress))
                    : Container(),
              )*/
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
            now.difference(backButtonPressTime!) >
                const Duration(microseconds: 1);

    if (await webViewController!.canGoBack()) {
      webViewController!.goBack();
      return false;
    } else {
      if (backButtonHasNotBeenPressedOrSnackBarHasBeenClosed) {
        backButtonPressTime = now;
        CustomDialog.onBackPressed(context);
        return false;
      }
      return false;
    }
  }
}