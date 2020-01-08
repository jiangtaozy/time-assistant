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
  var selectedDuration = {};
  var seriesList = [];
  var multiLineSeriesList = [];
  var weekSeriesList = [];
  var weekMultiLineSeriesList = [];

  @override
  void initState() {
    super.initState();
    init();
  }
  void init() async {
    await getTimeCategory();
    final records = await getTimeRecord();
    final timeCategoryDuration = getTimeCategoryDuration(records);
    final series = getSeriesList(timeCategoryDuration);
    final List<charts.Series<dynamic, DateTime>> multiLineSeries = getMultiLineSeriesList(timeCategoryDuration);
    final weekTimeCategoryDuration = getWeekTimeCategoryDuration(timeCategoryDuration);
    final weekSeries = getWeekSeriesList(weekTimeCategoryDuration);
    final List<charts.Series<dynamic, DateTime>> weekMultiLineSeries = getWeekMultiLineSeriesList(weekTimeCategoryDuration);
    setState(() {
      seriesList = series;
      multiLineSeriesList = multiLineSeries;
      weekSeriesList = weekSeries;
      weekMultiLineSeriesList = weekMultiLineSeries;
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
      SELECT time_record.time, time_record.categoryId
      FROM time_record
      ORDER BY datetime(time_record.time) ASC
    ''');
    return records;
  }

  getTimeCategoryDuration(timeRecord) {
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
          final today = DateTime(
            time.year,
            time.month,
            time.day,
          );
          final todayDuration = time.difference(today);
          timeRecordDuration.add({
            'time': today,
            'duration': todayDuration,
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
    return timeCategoryDuration;
  }

  getSeriesList(timeCategoryDuration) {
    final seriesList = timeCategoryDuration.map((categoryDuration) {
      final chartKey = "day-${categoryDuration['categoryId']}";
      final series = [
        charts.Series<dynamic, DateTime>(
          id: chartKey,
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
      return {
        'series': series,
        'chartKey': chartKey,
        'categoryName': categoryDuration['categoryName'],
      };
    }).toList();
    return seriesList;
  }

  getWeekTimeCategoryDuration(timeCategoryDuration) {
    final weekTimeCategoryDuration = timeCategoryDuration.map((categoryDuration) {
      final durationList = categoryDuration['durationList'];
      var weekDurationList = [];
      for(int j = 0; j < durationList.length; j++) {
        final durationData = durationList[j];
        final dayTime = durationData['dayTime'];
        final duration = durationData['duration'];
        final weekTime = dayTime.add(
          Duration(
            days: -(dayTime.weekday - 1),
          ),
        );
        bool hasInList = false;
        for(int k = 0; k < weekDurationList.length; k++) {
          final weekDuration = weekDurationList[k];
          final listWeekTime = weekDuration['weekTime'];
          if(weekTime.year == listWeekTime.year &&
            weekTime.month == listWeekTime.month &&
            weekTime.day == listWeekTime.day) {
            weekDuration['durationList'].add(duration);
            weekDuration['totalDuration'] += duration;
            hasInList = true;
            break;
          }
        }
        if(!hasInList) {
          weekDurationList.add({
            'weekTime': weekTime,
            'durationList': [duration],
            'totalDuration': duration,
          });
        }
      }
      for(int l = 0; l < weekDurationList.length; l++) {
        final weekDuration = weekDurationList[l];
        weekDurationList[l]['averageDuration'] = weekDuration['totalDuration'] ~/ 7;
      }
      return {
        'categoryId': categoryDuration['categoryId'],
        'categoryName': categoryDuration['categoryName'],
        'color': categoryDuration['color'],
        'durationList': weekDurationList,
      };
    }).toList();
    return weekTimeCategoryDuration;
  }

  getWeekSeriesList(weekTimeCategoryDuration) {
    final weekSeriesList = weekTimeCategoryDuration.map((categoryDuration) {
      final chartKey = "week-${categoryDuration['categoryId']}";
      final series = [
        charts.Series<dynamic, DateTime>(
          id: chartKey,
          colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color(int.parse(categoryDuration['color']))),
          domainFn: (record, _) => record['weekTime'],
          measureFn: (record, _) {
            final hours = record['averageDuration'].inHours;
            final minutes = record['averageDuration'].inMinutes % 60;
            final duration = hours + minutes / 60;
            return duration;
          },
          data: categoryDuration['durationList'],
        ),
      ];
      return {
        'series': series,
        'chartKey': chartKey,
        'categoryName': categoryDuration['categoryName'],
      };
    }).toList();
    return weekSeriesList;
  }

  getMultiLineSeriesList(timeCategoryDuration) {
    List<charts.Series<dynamic, DateTime>> multiLineSeriesList = timeCategoryDuration.map((categoryDuration) {
      return charts.Series<dynamic, DateTime>(
        id: categoryDuration['categoryName'].toString(),
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color(int.parse(categoryDuration['color']))),
        domainFn: (record, _) => record['dayTime'],
        measureFn: (record, _) {
          final hours = record['duration'].inHours;
          final minutes = record['duration'].inMinutes % 60;
          final duration = hours + minutes / 60;
          return duration;
        },
        data: categoryDuration['durationList'],
      );
    }).toList().cast<charts.Series<dynamic, DateTime>>();
    return multiLineSeriesList;
  }

  getWeekMultiLineSeriesList(timeCategoryDuration) {
    List<charts.Series<dynamic, DateTime>> multiLineSeriesList = timeCategoryDuration.map((categoryDuration) {
      return charts.Series<dynamic, DateTime>(
        id: categoryDuration['categoryName'].toString(),
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color(int.parse(categoryDuration['color']))),
        domainFn: (record, _) => record['weekTime'],
        measureFn: (record, _) {
          final hours = record['averageDuration'].inHours;
          final minutes = record['averageDuration'].inMinutes % 60;
          final duration = hours + minutes / 60;
          return duration;
        },
        data: categoryDuration['durationList'],
      );
    }).toList().cast<charts.Series<dynamic, DateTime>>();
    return multiLineSeriesList;
  }

  onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;
    if(selectedDatum.isNotEmpty) {
      final series = selectedDatum.first.series;
      final datum = selectedDatum.first.datum;
      final chartKey = selectedDatum.first.series.id;
      final dayTime = datum['dayTime'] ?? datum['weekTime'];
      final duration = datum['duration'] ?? datum['averageDuration'];
      setState(() {
        selectedDuration[chartKey] = {
          'duration': duration,
          'dayTime': dayTime,
        };
      });
    }
  }

  getSeriesChartList(seriesList) {
    return seriesList.map((series) {
      final selectedTimeNode = selectedDuration[series['chartKey']];
      var selectedTimeDurationString = '';
      var selectedTimeDate = '';
      if(selectedTimeNode != null) {
        final selectedDayTime = selectedTimeNode['dayTime'];
        final selectedTimeDuration = selectedTimeNode['duration'];
        final year = selectedDayTime.year;
        final month = selectedDayTime.month;
        final day = selectedDayTime.day;
        final hours = selectedTimeDuration.inHours;
        final minutes = (selectedTimeDuration.inMinutes % 60).toString().padLeft(2, '0');
        selectedTimeDurationString = '$hours:$minutes';
        selectedTimeDate = '$year.$month.$day';
      }
      return SizedBox(
        height: 240,
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: charts.TimeSeriesChart(
                series['series'],
                animate: true,
                behaviors: [
                  charts.ChartTitle(
                    series['categoryName'],
                    behaviorPosition: charts.BehaviorPosition.top,
                    titleOutsideJustification: charts.OutsideJustification.start,
                    innerPadding: 18,
                  ),
                ],
                selectionModels: [
                  charts.SelectionModelConfig(
                    type: charts.SelectionModelType.info,
                    changedListener: onSelectionChanged,
                  ),
                ],
                domainAxis: charts.DateTimeAxisSpec(
                  tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
                    day: charts.TimeFormatterSpec(
                      format: 'd',
                      transitionFormat: 'MM-dd',
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(''),
                  Text(selectedTimeDurationString),
                  Text(selectedTimeDate),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  getMultiLineSeriesChart(multiLineSeriesList) {
    Widget multiLineSeriesChart = SizedBox(
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
        child: multiLineSeriesList.length == 0 ? null : charts.TimeSeriesChart(
          multiLineSeriesList,
          animate: true,
          behaviors: [
            charts.ChartTitle(
              '时长',
              behaviorPosition: charts.BehaviorPosition.top,
              titleOutsideJustification: charts.OutsideJustification.start,
              innerPadding: 18,
            ),
          ],
          domainAxis: charts.DateTimeAxisSpec(
            tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
              day: charts.TimeFormatterSpec(
                format: 'd',
                transitionFormat: 'MM-dd',
              ),
            ),
          ),
        ),
      ),
    );
    return multiLineSeriesChart;
  }

  @override
  Widget build(BuildContext context) {
    final seriesChartList = getSeriesChartList(seriesList);
    final weekSeriesChartList = getSeriesChartList(weekSeriesList);
    Widget multiLineSeriesChart = getMultiLineSeriesChart(multiLineSeriesList);
    Widget weekMultiLineSeriesChart = getMultiLineSeriesChart(weekMultiLineSeriesList);
    return ListView(
      children: [
        Container(
          padding: EdgeInsets.only(
            top: 15,
          ),
          child: Center(
            child: Text(
              '每天',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          )
        ),
        multiLineSeriesChart,
        ...seriesChartList,
        Container(
          child: Center(
            child: Text(
              '每周',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          )
        ),
        weekMultiLineSeriesChart,
        ...weekSeriesChartList,
      ],
    );
  }
}
