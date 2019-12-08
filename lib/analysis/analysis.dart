/*
 * Maintained by jemo from 2019.12.7 to now
 * Created by jemo on 2019.12.7 10:27:59
 * Analysis
 */

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:sqflite/sqflite.dart';
import '../db.dart';

class Analysis extends StatefulWidget {
  @override
  AnalysisState createState() => AnalysisState();
}

class AnalysisState extends State<Analysis> {

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
      SELECT time_record.time, time_record.categoryId
      FROM time_record
      ORDER BY datetime(time_record.time) ASC
    ''');
    setState(() {
      timeRecord = records;
    });
  }

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var timeRecordDuration = [];
    // 每条记录时长
    for(var i = 0; i < timeRecord.length; i++) {
      final record = timeRecord[i];
      final time = DateTime.parse(record['time']);
      if(i == 0) {
        final dayStart = DateTime(
          time.year,
          time.month,
          time.day,
        );
        final duration = time.difference(dayStart);
        timeRecordDuration.add({
          'time': dayStart,
          'duration': duration,
          'categoryId': 1,
        });
      } else {
        final lastRecord = timeRecord[i - 1];
        final lastTime = DateTime.parse(lastRecord['time']);
        if(lastTime.year == time.year && lastTime.month == time.month && lastTime.day == time.day) {
          final duration = time.difference(lastTime);
          timeRecordDuration.add({
            'time': lastTime,
            'duration': duration,
            'categoryId': lastRecord['categoryId'],
          });
        } else {
          final nextDay = DateTime(
            lastTime.year,
            lastTime.month,
            lastTime.day + 1,
          );
          final duration = nextDay.difference(lastTime);
          timeRecordDuration.add({
            'time': lastTime,
            'duration': duration,
            'categoryId': lastRecord['categoryId'],
          });
          final nextDuration = time.difference(nextDay);
          timeRecordDuration.add({
            'time': nextDay,
            'duration': nextDuration,
            'categoryId': lastRecord['categoryId'],
          });
        }
        if(i == timeRecord.length - 1) {
          var duration;
          if(time.year == now.year && time.month == now.month && time.day == now.day) {
            duration = now.difference(time);
          } else {
            final nextDay = DateTime(
              time.year,
              time.month,
              time.day + 1,
            );
            duration = nextDay.difference(time);
          }
          timeRecordDuration.add({
            'time': time,
            'duration': duration,
            'categoryId': record['categoryId'],
          });
        }
      }
    }
    var timeCategoryDuration = [];
    for(var i = 0; i < timeCategory.length; i++) {
      final category = timeCategory[i];
      timeCategoryDuration.add({
        'categoryId': category['id'],
        'categoryName': category['name'],
        'color': category['color'],
        'durationList': [],
      });
    }
    // 每项类型每天时长
    for(var i = 0; i < timeRecordDuration.length; i++) {
      final recordDuration = timeRecordDuration[i];
      final time = recordDuration['time'];
      for(var j = 0; j < timeCategoryDuration.length; j++) {
        final categoryDuration = timeCategoryDuration[j];
        if(categoryDuration['categoryId'] == recordDuration['categoryId']) {
          final durationList = categoryDuration['durationList'];
          var ifAlreadyInCategoryDurationList = false;
          for(var k = 0; k < durationList.length; k++) {
            final durationListData = durationList[k];
            final durationListDataDayTime = durationListData['dayTime'];
            if(durationListDataDayTime.year == time.year &&
              durationListDataDayTime.month == time.month &&
              durationListDataDayTime.day == time.day) {
              durationListData['duration'] += recordDuration['duration'];
              ifAlreadyInCategoryDurationList = true;
              break;
            }
          }
          if(!ifAlreadyInCategoryDurationList) {
            durationList.add({
              'dayTime': DateTime(
                time.year,
                time.month,
                time.day,
              ),
              'duration': recordDuration['duration'],
            });
          }
        }
      }
    }
    final seriesChartList = timeCategoryDuration.map((categoryDuration) {
      final seriesList = [
        charts.Series<dynamic, DateTime>(
          id: categoryDuration['categoryId'].toString(),
          colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color(int.parse(categoryDuration['color']))),
          domainFn: (record, _) => record['dayTime'],
          measureFn: (record, _) {
            final hours = record['duration'].inHours;
            final minutes = record['duration'].inMinutes % 60;
            final duration = hours + minutes / 60;
            return duration;
          },
          data: categoryDuration['durationList'],
        ),
      ];
      return SizedBox(
        height: 240,
        child: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: charts.TimeSeriesChart(
            seriesList,
            animate: true,
            behaviors: [
              charts.ChartTitle(
                categoryDuration['categoryName'],
                behaviorPosition: charts.BehaviorPosition.top,
                titleOutsideJustification: charts.OutsideJustification.start,
                innerPadding: 18,
              ),
            ],
          ),
        ),
      );
    }).toList();
    return ListView(
      children: seriesChartList,
    );
  }
}
