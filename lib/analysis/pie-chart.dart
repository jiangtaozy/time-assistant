/*
 * Maintained by jemo from 2020.2.8 to now
 * Created by jemo on 2020.2.8 11:16:07
 * Pie chart
 */

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class PieChart extends StatefulWidget {

  PieChart({
    Key key,
    this.timeCategoryDuration,
    this.selectedTime,
  }) : super(key: key);

  var timeCategoryDuration;
  var selectedTime;

  @override
  PieChartState createState() => PieChartState();

}

class PieChartState extends State<PieChart> {

  @override
  Widget build(BuildContext context) {
    final categoryDuration = widget.timeCategoryDuration;
    final pieData = [];
    for(var i = 0; i < categoryDuration.length; i++) {
      final durationData = categoryDuration[i];
      final durationList = durationData['durationList'];
      var duration = durationList[durationList.length - 1]['duration'];
      for(var j = 0; j < durationList.length; j++) {
        if(durationList[j]['dayTime'].compareTo(widget.selectedTime) == 0) {
          duration = durationList[j]['duration'];
          break;
        }
      }
      pieData.add({
        'id': durationData['categoryId'],
        'name': durationData['categoryName'],
        'duration': duration,
        'time': duration.inSeconds,
        'color': durationData['color'],
      });
    }
    int total = 0;
    for(var i = 0; i < pieData.length; i++) {
      final data = pieData[i];
      final time = data['time'];
      total += time;
    }
    if(total == 0) {
      pieData.add({
        'id': 0,
        'name': '未用',
        'duration': Duration(hours: 24),
        'time': 1,
        'color': '0xfff2f1f6',
      });
    }
    final seriesList = [
      new charts.Series(
        id: 'pieChart',
        domainFn: (record, _) => record['name'],
        measureFn: (record, _) => record['time'],
        colorFn: (record, _) => charts.ColorUtil.fromDartColor(Color(int.parse(record['color']))),
        data: pieData,
        labelAccessorFn: (row, _) {
          final duration = row['duration'] ?? Duration();
          final hour = duration.inHours.toString().padLeft(2, '0');
          final minute = (duration.inMinutes % 60).toString().padLeft(2, '0');
          return "${row['name']} $hour:$minute";
        }
      )
    ];
    final selectedTime = widget.selectedTime;
    final timeString = '${selectedTime.year}.${selectedTime.month}.${selectedTime.day}';
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(10),
              child: Text(timeString),
            ),
          ],
        ),
        SizedBox(
          height: 240,
          child: Container(
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: charts.PieChart(seriesList,
              animate: true,
              defaultRenderer: new charts.ArcRendererConfig(
                arcWidth: 60,
                arcRendererDecorators: [new charts.ArcLabelDecorator()],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
