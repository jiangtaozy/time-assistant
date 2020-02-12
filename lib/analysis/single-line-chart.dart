/*
 * Maintained by jemo from 2020.1.10 to now
 * Created by jemo on 2020.1.10 16:15:40
 * Single line chart
 */

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class SingleLineChart extends StatefulWidget {

  SingleLineChart({
    Key key,
    this.timeCategoryDuration,
    this.timeCategory,
  }) : super(key: key);

  var timeCategoryDuration;
  var timeCategory;

  @override
  SingleLineChartState createState() => SingleLineChartState();

}

class SingleLineChartState extends State<SingleLineChart> {

  var seriesData;
  var selectedDuration = {};

  @override
  void initState() {
    super.initState();
    setSeries();
  }

  setSeries({categoryId}) {
    for(int i = 0; i < widget.timeCategoryDuration.length; i++) {
      final categoryDuration = widget.timeCategoryDuration[i];
      if(categoryId == null || categoryDuration["categoryId"] == categoryId) {
        final chartKey = "key-${categoryDuration['categoryId']}";
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
        setState(() {
          seriesData = {
            'series': series,
            'chartKey': chartKey,
            'categoryName': categoryDuration['categoryName'],
          };
        });
        break;
      }
    }
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

  @override
  void didUpdateWidget(SingleLineChart oldWidget) {
    if (oldWidget.timeCategoryDuration != widget.timeCategoryDuration) {
      setSeries();
    }
  }

  @override
  Widget build(BuildContext context) {
    String selectedTimeDurationString = '';
    String selectedTimeDate = '';
    if(seriesData != null) {
      final selectedTimeNode = selectedDuration[seriesData['chartKey']];
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
    }
    return Column(
      children: <Widget>[
        SizedBox(
          height: 240,
          child: Stack(
            alignment: AlignmentDirectional.topCenter,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: seriesData == null ? null : charts.TimeSeriesChart(
                  seriesData['series'],
                  animate: true,
                  behaviors: [
                    charts.ChartTitle(
                      seriesData['categoryName'],
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
                      month: charts.TimeFormatterSpec(
                        format: 'MM',
                        transitionFormat: 'yy-MM',
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
        ),
        Wrap(
          spacing: 8.0,
          direction: Axis.horizontal,
          children: widget.timeCategory.map<Widget>((category) {
            return RaisedButton(
              color: Color(int.parse(category['color'])),
              onPressed: () {
                setSeries(
                  categoryId: category['id'],
                );
              },
              child: Text(category['name']),
            );
          }).toList(),
        ),
      ],
    );
  }
}
