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
import 'time-record-item.dart';
import 'time-record-pie-chart.dart';

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {

  var timeCategory = [];
  var timeRecord = [];
  var lastDayTimeRecord = [];
  var selectedDate;
  ScrollController timeRecordListViewController = new ScrollController();

  @override
  void dispose() {
    timeRecordListViewController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getTimeCategory();
    getTimeRecord();
    final now = DateTime.now();
    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );
    setState(() {
      selectedDate = today;
    });
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
      WHERE DATETIME(time)
      BETWEEN DATETIME('${selectedDate}')
      AND DATETIME('${selectedDate}', '+1 day')
    ''');
    final lastDayRecords = await db.rawQuery('''
      SELECT time_record.*, time_category.name
      FROM time_record
      LEFT JOIN time_category
      on time_record.categoryId = time_category.id
      WHERE DATETIME(time)
      BETWEEN DATETIME('${selectedDate}', '-1 day')
      AND DATETIME('${selectedDate}')
    ''');
    setState(() {
      timeRecord = records;
      lastDayTimeRecord = lastDayRecords;
    });
  }

  handleTimeCategoryButtonPressed(timeCategoryId) async {
    final now = new DateTime.now();
    final time = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
      now.microsecond,
    );
    final db = await database();
    await db.insert(
      'time_record',
      {
        'time': time.toIso8601String(),
        'categoryId': timeCategoryId,
      }
    );
    await getTimeRecord();
    Timer(Duration(milliseconds: 100), () {
      scrollTimeRecordListViewToBottom();
    });
  }

  handleDatePressed(context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2019),
      lastDate: DateTime(2021),
    );
    if(date != null) {
      setState(() {
        selectedDate = date;
      });
      getTimeRecord();
    }
  }

  scrollTimeRecordListViewToBottom() {
    timeRecordListViewController.animateTo(
      timeRecordListViewController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    var records = timeRecord.map((record) {
      return TimeRecordItem(
        record: record,
        getTimeRecord: getTimeRecord,
        timeCategory: timeCategory,
      );
    }).toList();
    var buttons = timeCategory.map((category) {
      return RaisedButton(
        color: Color(int.parse(category['color'])),
        onPressed: () {
          handleTimeCategoryButtonPressed(category['id']);
        },
        child: Text(category['name']),
      );
    }).toList();
    final selectedDateString = '${selectedDate.month}.${selectedDate.day}';
    return Scaffold(
      appBar: AppBar(
        title: Text('时间助手'),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 240.0,
            child: TimeRecordPieChart(
              timeRecord: timeRecord,
              timeCategory: timeCategory,
              lastDayTimeRecord: lastDayTimeRecord,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 20),
                child: RaisedButton(
                  color: Color(0xffc4e0e1),
                  onPressed: () {
                    handleDatePressed(context);
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.date_range),
                      Text(selectedDateString),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: records,
              controller: timeRecordListViewController,
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
