/*
 * Maintained by jemo from 2019.11.14 to now
 * Created by jemo on 2019.11.14 17:39:20
 * Home
 */

import 'package:flutter/material.dart';
import 'record/record.dart';

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('小福时间助手'),
      ),
      body: Record(),
    );
  }
}
