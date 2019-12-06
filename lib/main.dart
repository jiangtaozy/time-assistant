/*
 * Maintained by jemo from 2019.11.14 to now
 * Created by jemo on 2019.11.14 17:29:27
 * Main
 */

import 'package:flutter/material.dart';
import 'home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '时间助手',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}
