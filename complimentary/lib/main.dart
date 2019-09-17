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
    return MaterialApp(
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: themeColorMaterial,
      ),
      home: LoginPage(),
    );
  }
}