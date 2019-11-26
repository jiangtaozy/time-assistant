/*
 * Maintained by jemo from 2019.11.14 to now
 * Created by jemo on 2019.11.14 17:39:20
 * Home
 */

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'db.dart';

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {

  var timeCategory = [];
  var timeRecord = [];

  @override
  void initState() {
    super.initState();
    getTimeCategory();
    getTimeRecord();
  }

  getTimeCategory() async {
    final Database db = await database();
    final List<Map<String, dynamic>> category = await db.query('time_category');
    setState(() {
      timeCategory = category;
    });
  }

  getTimeRecord() async {
    final Database db = await database();
    final records = await db.rawQuery('''
      SELECT time_record.*, time_category.name
      FROM time_record
      LEFT JOIN time_category
      on time_record.categoryId = time_category.id
    ''');
    setState(() {
      timeRecord = records;
    });
  }

  handleTimeCategoryButtonPressed(timeCategoryId) async {
    final now = new DateTime.now();
    final db = await database();
    await db.insert(
      'time_record',
      {
        'time': now.toIso8601String(),
        'categoryId': timeCategoryId,
      }
    );
    getTimeRecord();
  }

  handleTimeRecordLongPressed(context, recordId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('删除这条记录吗？'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('取消'),
            ),
            FlatButton(
              onPressed: () {
                deleteRecord(recordId);
                Navigator.pop(context);
              },
              child: Text('确定'),
            ),
          ],
        );
      }
    );
  }

  deleteRecord(recordId) async {
    final db = await database();
    await db.delete(
      'time_record',
      where: 'id = ?',
      whereArgs: [recordId],
    );
    getTimeRecord();
  }

  @override
  Widget build(BuildContext context) {
    var records = timeRecord.map((record) {
      var recordId = record['id'];
      var time = DateTime.parse(record['time']);
      var timeString = '${time.hour}:${time.minute}';
      return Card(
        child: InkWell(
          onTap: () {
          },
          onLongPress: () {
            handleTimeRecordLongPressed(context, recordId);
          },
          child: ListTile(
            title: Text(timeString + ' ' + record['name'])
          ),
        ),
      );
    }).toList();
    var buttons = timeCategory.map((category) {
      return RaisedButton(
        onPressed: () {
          handleTimeCategoryButtonPressed(category['id']);
        },
        child: Text(category['name']),
      );
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('时间助手'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: records,
            ),
          ),
          Wrap(
            spacing: 8.0,
            direction: Axis.horizontal,
            children: buttons,
          ),
        ],
      ),
    );
  }
}
