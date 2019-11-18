/*
 * Maintained by jemo from 2019.11.14 to now
 * Created by jemo on 2019.11.14 17:39:20
 * Home
 */

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('时间助手'),
      ),
      body: Center(
        child: Text('ok'),
      ),
    );
  }
}
