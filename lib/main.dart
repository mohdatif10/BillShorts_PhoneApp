import 'package:flutter/material.dart';
import 'package:bill_shorts/pages/home.dart';
import 'package:bill_shorts/pages/loading.dart';
import 'package:bill_shorts/pages/hyperlink.dart';

void main() => runApp(MaterialApp(
  initialRoute: "/",
  routes: {
    '/': (context) => Loading(),
    '/home': (context) => Home(),
    '/hyperlink': (context) => HyperlinkPage(
      destinationUrl: '',
    ),
  },
));
