import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:complimentary/const.dart';
import 'package:flutter/material.dart';

import 'login.dart';

void main() {
  runApp(MyApp());
}
//Admob Android appID: ca-app-pub-2874072397905886~7278065504
//Banner adUnit id: ca-app-pub-2874072397905886/9050312172
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String _appId = Platform.isAndroid?
    'ca-app-pub-2874072397905886~7278065504' :
    'ca-app-pub-2874072397905886~5583810079';
    Admob.initialize(_appId);
    return MaterialApp(
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: themeColorMaterial,
      ),
      home: LoginPage(),
    );
  }
}