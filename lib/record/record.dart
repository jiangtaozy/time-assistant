/*
 * Maintained by jemo from 2019.12.7 to now
 * Created by jemo on 2019.12.7 10:13:15
 * Record
 */

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../db.dart';
import 'time-record-item/time-record-item.dart';
import 'time-record-pie-chart.dart';
import '../colors.dart';
import 'time-record-item/time-record-item-time-picker.dart';
import 'time-record-item/time-record-item-category-dropdown-menu.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class Record extends StatefulWidget {
  @override
  RecordState createState() => RecordState();
}

class RecordState extends State<Record> {

  var timeCategory = [];
  var timeRecord = [];
  var lastDayTimeRecord = [];
  var selectedDate;
  var recordTime;
  var recordContent;
  var recordCategoryId;
  int pieSwiperIndex = 0;
  ScrollController timeRecordListViewController = new ScrollController();

  updateRecordTime(time) {
    setState(() {
      recordTime = time;
    });
  }

  updateRecordCategoryId(categoryId) {
    setState(() {
      recordCategoryId = categoryId;
    });
  }

  handleRecordContentChanged(value) {
    setState(() {
      recordContent = value;
    });
  }

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
      ORDER BY datetime(time_record.time) ASC
    ''');
    final lastDayRecords = await db.rawQuery('''
      SELECT time_record.*, time_category.name
      FROM time_record
      LEFT JOIN time_category
      on time_record.categoryId = time_category.id
      WHERE DATETIME(time)
      BETWEEN DATETIME('${selectedDate}', '-1 day')
      AND DATETIME('${selectedDate}')
      ORDER BY datetime(time_record.time) ASC
    ''');
    final timeRecordList = [];
    for(var i = 0; i < records.length; i++) {
      final record = records[i];
      final now = DateTime.now();
      var duration;
      final time = DateTime.parse(record['time']);
      if(i != records.length - 1) {
        final nextRecord = records[i + 1];
        final nextTime = DateTime.parse(nextRecord['time']);
        duration = nextTime.difference(time);
      } else if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day) {
        duration = now.difference(time);
      } else {
        final nextDay = DateTime(
          time.year,
          time.month,
          time.day + 1,
        );
        duration = nextDay.difference(time);
      }
      timeRecordList.add({
        'id': record['id'],
        'time': record['time'],
        'categoryId': record['categoryId'],
        'content': record['content'],
        'name': record['name'],
        'duration': duration,
      });
    }
    setState(() {
      timeRecord = timeRecordList;
      lastDayTimeRecord = lastDayRecords;
    });
  }

  handleRecordTimeSubmitButtonPressed(context) async {
    final db = await database();
    await db.insert(
      'time_record',
      {
        'time': recordTime.toIso8601String(),
        'categoryId': recordCategoryId,
        'content': recordContent,
      }
    );
    await getTimeRecord();
    Timer(Duration(milliseconds: 100), () {
      scrollTimeRecordListViewToBottom();
    });
    Navigator.of(context).pop();
  }

  handleTimeCategoryButtonPressed(context, timeCategoryId) async {
    setState(() {
      recordContent = '';
    });
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
    updateRecordTime(time);
    updateRecordCategoryId(timeCategoryId);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('修改记录'),
          children: <Widget>[
            TimeRecordItemTimePicker(
              recordTime: time,
              updateRecordTime: updateRecordTime,
            ),
            Container(
              margin: EdgeInsets.only(left: 10, right: 20),
              child: TextFormField(
                autofocus: true,
                initialValue: '',
                decoration: InputDecoration(
                  icon: Icon(Icons.code),
                  hintText: '内容',
                ),
                maxLines: null,
                onChanged: handleRecordContentChanged,
              ),
            ),
            TimeRecordItemCategoryDropdownMenu(
              timeCategory: timeCategory,
              timeRecordCategoryId: timeCategoryId,
              updateRecordCategoryId: updateRecordCategoryId,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                  color: Color(YauMaTeiGray),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('取消'),
                ),
                RaisedButton(
                  color: Color(AdmiraltyBlue),
                  onPressed: () {
                    handleRecordTimeSubmitButtonPressed(context);
                  },
                  child: Text('确定'),
                ),
              ],
            ),
          ],
        );
      }
    );
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
          handleTimeCategoryButtonPressed(context, category['id']);
        },
        child: Text(category['name']),
      );
    }).toList();
    final selectedDateString = '${selectedDate.month}.${selectedDate.day}';
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10),
              child: RaisedButton(
                color: Color(YauMaTeiGray),
                onPressed: () {
                  handleDatePressed(context);
                },
                child: Row(
                  children: <Widget>[
                    Icon(Icons.date_range),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Text(selectedDateString),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 240.0,
          child: Swiper(
            itemBuilder: (BuildContext context, int index) {
              return TimeRecordPieChart(
                timeRecord: timeRecord,
                timeCategory: timeCategory,
                lastDayTimeRecord: lastDayTimeRecord,
              );
            },
            itemCount: 3,
            onIndexChanged: (int index) {
              bool isSwiperForward = index - pieSwiperIndex == 1 ||
                index - pieSwiperIndex == -2;
              DateTime newDate = selectedDate.add(
                Duration(days: isSwiperForward ? 1 : -1)
              );
              setState(() {
                pieSwiperIndex = index;
                selectedDate = newDate;
              });
              getTimeRecord();
            },
          ),
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
    );
  }
}
