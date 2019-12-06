/*
 * Maintained by jemo from 2019.12.4 to now
 * Created by jemo on 2019.12.4 17:59:55
 * Time record pie chart
 */

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class TimeRecordPieChart extends StatefulWidget {

  TimeRecordPieChart({
    Key key,
    this.timeRecord,
    this.timeCategory,
    this.lastDayTimeRecord,
  }) : super(key: key);

  var timeRecord;
  var timeCategory;
  var lastDayTimeRecord;

  @override
  TimeRecordPieChartState createState() => TimeRecordPieChartState();
}

class TimeRecordPieChartState extends State<TimeRecordPieChart> {

  getLastDayLastRecordCategory() {
    final lastDayTimeRecord = widget.lastDayTimeRecord;
    var lastRecordCategory = {
      'categoryId': 1,
      'categoryName': '睡觉',
    };
    if(lastDayTimeRecord.length > 0) {
      lastRecordCategory['categoryId'] = lastDayTimeRecord[lastDayTimeRecord.length - 1]['categoryId'];
      lastRecordCategory['categoryName'] = lastDayTimeRecord[lastDayTimeRecord.length - 1]['name'];
    }
    return lastRecordCategory;
  }

  @override
  Widget build(BuildContext context) {
    final lastDayLastRecordCategory = getLastDayLastRecordCategory();
    final timeRecord = widget.timeRecord;
    var timeCategoryList = [];
    for(var i = 0; i < widget.timeCategory.length; i++) {
      timeCategoryList.add({
        'id': widget.timeCategory[i]['id'],
        'name': widget.timeCategory[i]['name'],
      });
    }
    var timeDurationData = [];
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
        timeDurationData.add({
          'categoryId': lastDayLastRecordCategory['categoryId'],
          'categoryName': lastDayLastRecordCategory['categoryName'],
          'duration': duration,
        });
      } else {
        final lastRecord = timeRecord[i - 1];
        final lastTime = DateTime.parse(lastRecord['time']);
        final duration = time.difference(lastTime);
        timeDurationData.add({
          'categoryId': lastRecord['categoryId'],
          'categoryName': lastRecord['name'],
          'duration': duration,
        });
      }
      if(i == timeRecord.length - 1) {
        final now = DateTime.now();
        final nextDay = DateTime(
          time.year,
          time.month,
          time.day + 1,
        );
        var duration;
        if(time.year == now.year && time.month == now.month && time.day == now.day) {
          duration = now.difference(time);
          timeDurationData.add({
            'categoryId': 0,
            'categoryName': '未用',
            'duration': nextDay.difference(now),
          });
          timeCategoryList.add({
            'id': 0,
            'name': '未用',
          });
        } else {
          duration = nextDay.difference(time);
        }
        timeDurationData.add({
          'categoryId': record['categoryId'],
          'categoryName': record['name'],
          'duration': duration,
        });
      }
    }
    for(var i = 0; i < timeDurationData.length; i++) {
      final durationData = timeDurationData[i];
      for(var j = 0; j < timeCategoryList.length; j++) {
        final category = timeCategoryList[j];
        if(durationData['categoryId'] == category['id']) {
          if(category['duration'] == null) {
            category['duration'] = durationData['duration'];
          } else {
            Duration duration = category['duration'];
            Duration otherDuration = durationData['duration'];
            category['duration'] = duration + otherDuration;
          }
        }
      }
    }
    for(var i = 0; i < timeCategoryList.length; i++) {
      if(timeCategoryList[i]['duration'] != null) {
        timeCategoryList[i]['time'] = timeCategoryList[i]['duration'].inSeconds;
      } else {
        timeCategoryList[i]['time'] = 0;
      }
    }
    if(timeRecord.length == 0) {
      timeCategoryList.add({
        'id': 0,
        'name': '未用',
        'duration': Duration(hours: 24),
        'time': 1,
      });
    }
    var seriesList = [
      new charts.Series(
        id: 'Sales',
        domainFn: (record, _) => record['name'],
        measureFn: (record, _) => record['time'],
        data: timeCategoryList,
        labelAccessorFn: (row, _) {
          final duration = row['duration'] ?? Duration();
          final hour = duration.inHours.toString().padLeft(2, '0');
          final minute = (duration.inMinutes % 60).toString().padLeft(2, '0');
          return "${row['name']} $hour:$minute";
        }
      )
    ];
    return new charts.PieChart(seriesList,
      animate: true,
      defaultRenderer: new charts.ArcRendererConfig(
        arcWidth: 60,
        arcRendererDecorators: [new charts.ArcLabelDecorator()],
      ),
    );
  }
}
