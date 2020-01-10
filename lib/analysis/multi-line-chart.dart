/*
 * Maintained by jemo from 2020.1.10 to now
 * Created by jemo on 2020.1.10 16:15:40
 * Multi line chart
 */

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class MultiLineChart extends StatefulWidget {

  MultiLineChart({
    Key key,
    this.timeCategoryDuration,
  }) : super(key: key);

  var timeCategoryDuration;

  @override
  MultiLineChartState createState() => MultiLineChartState();

}

class MultiLineChartState extends State<MultiLineChart> {

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

  @override
  Widget build(BuildContext context) {
    final List<charts.Series<dynamic, DateTime>> multiLineSeriesList = getMultiLineSeriesList(widget.timeCategoryDuration);
    return SizedBox(
      height: 240,
      child: Container(
        margin: EdgeInsets.all(5),
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
  }
}
