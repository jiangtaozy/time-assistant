/*
 * Maintained by jemo from 2019.12.7 to now
 * Created by jemo on 2019.12.7 10:27:59
 * Analysis
 */

import 'package:flutter/material.dart';
import '../colors.dart';
import 'analysis-chart.dart';

class Analysis extends StatefulWidget {

  @override
  AnalysisState createState() => AnalysisState();

}

class AnalysisState extends State<Analysis> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: TabBar(
          labelColor: Color(TaiWaiBlue),
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Color(UniversityBlue),
          tabs: [
            Tab(
                text: '每天',
            ),
            Tab(
                text: '每周',
            ),
            Tab(
                text: '每月',
            ),
          ],
        ),
        body: TabBarView(
          children: [
            AnalysisChart(
              type: 'day',
            ),
            AnalysisChart(
              type: 'week',
            ),
            Icon(Icons.directions_bike),
          ],
        ),
      ),
    );
  }

}
