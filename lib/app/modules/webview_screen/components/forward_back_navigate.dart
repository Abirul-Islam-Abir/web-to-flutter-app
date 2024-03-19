import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ForwardBackNavigate extends StatelessWidget {
  const ForwardBackNavigate({
    super.key,
    required this.webViewController,
  });

  final InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          child: Icon(Icons.arrow_back),
          onPressed: () {
            webViewController?.goBack();
          },
        ),
        ElevatedButton(
          child: Icon(Icons.arrow_forward),
          onPressed: () {
            webViewController?.goForward();
          },
        ),
      ],
    );
  }
}