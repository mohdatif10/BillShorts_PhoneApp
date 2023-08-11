import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HyperlinkPage extends StatefulWidget {
  final String destinationUrl;

  HyperlinkPage({required this.destinationUrl});

  @override
  _HyperlinkPageState createState() => _HyperlinkPageState();
}

class _HyperlinkPageState extends State<HyperlinkPage> {
  late InAppWebViewController inAppWebViewController;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var isLastPage = await inAppWebViewController.canGoBack();

        if (isLastPage) {
          inAppWebViewController.goBack();
          return false;
        }

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFD9D9D9),
          title: Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              widget.destinationUrl,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 32.9,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                size: 32.9,
                color: Colors.black,
              ),
              onSelected: (value) {
                if (value == 'reload') {
                  inAppWebViewController.reload();
                } else if (value == 'copy') {
                  // Perform copy action
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'copy',
                  child: Text('Copy'),
                ),
                PopupMenuItem<String>(
                  value: 'reload',
                  child: Text('Reload'),
                ),
              ],
            ),
          ],
          toolbarHeight: 55.0,
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: Uri.parse(widget.destinationUrl),
              ),
              onWebViewCreated: (InAppWebViewController controller) {
                inAppWebViewController = controller;
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100;
                });
              },
            ),
            if (_progress < 1)
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
          ],
        ),
      ),
    );
  }
}
