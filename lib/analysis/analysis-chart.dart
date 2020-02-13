/*
 * Maintained by jemo from 2020.1.10 to now
 * Created by jemo on 2020.1.10 13:45:28
 * AnalysisChart
 */

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:sqflite/sqflite.dart';
import '../db.dart';
import 'calculation.dart';
import 'multi-line-chart.dart';
import 'single-line-chart.dart';
import 'pie-chart.dart';

class AnalysisChart extends StatefulWidget {

  AnalysisChart({
    Key key,
    this.type,
  }) : super(key: key);

  String type;

  @override
  AnalysisChartState createState() => AnalysisChartState();

}

class AnalysisChartState extends State<AnalysisChart> {

  var timeCategoryDuration = [];
  var timeCategory = [];
  var selectedTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await getTimeCategory();
    final records = await getTimeRecord();
    var categoryDuration = getTimeCategoryDuration(records, timeCategory);
    if(widget.type == 'week') {
      categoryDuration = getWeekTimeCategoryDuration(categoryDuration);
    }
    if(widget.type == 'month') {
      categoryDuration = getMonthTimeCategoryDuration(categoryDuration);
    }
    if(mounted) {
      setState(() {
        timeCategoryDuration = categoryDuration;
      });
    }
  }

  getTimeCategory() async {
    final Database db = await database();
    final List<Map<String, dynamic>> category = await db.query('time_category');
    if(mounted) {
      setState(() {
        timeCategory = category;
      });
    }
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

  onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;
    if(selectedDatum.isNotEmpty) {
      final series = selectedDatum.first.series;
      final datum = selectedDatum.first.datum;
      final dayTime = datum['dayTime'];
      setState(() {
        selectedTime = dayTime;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        PieChart(
          timeCategoryDuration: timeCategoryDuration,
          selectedTime: selectedTime,
        ),
        MultiLineChart(
          timeCategoryDuration: timeCategoryDuration,
          onSelectionChanged: onSelectionChanged,
        ),
        SingleLineChart(
          timeCategoryDuration: timeCategoryDuration,
          timeCategory: timeCategory,
        ),
      ],
    );
  }

}
