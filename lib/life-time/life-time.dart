/*
 * Maintained by jemo from 2020.3.8 to now
 * Created by jemo on 2020.3.8 15:58:09
 * Life time
 */

import 'package:flutter/material.dart';
import 'package:flutter_annual_task/flutter_annual_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LifeTime extends StatefulWidget {

  @override
  LifeTimeState createState() => LifeTimeState();

}

class LifeTimeState extends State<LifeTime> {

  var birthday;

  @override
  void initState() {
    super.initState();
    getBirthday();
  }

  getBirthday() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String birthdayStr = sharedPreferences.getString('birthday');
    if(birthdayStr != null) {
      DateTime date = DateTime.parse(birthdayStr);
      setState(() {
        birthday = date;
      });
    }
  }

  handleDateButtonPressed() async {
    final date = await showDatePicker(
      context: context,
      initialDate: birthday ?? DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if(date != null) {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('birthday', date.toIso8601String());
      setState(() {
        birthday = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime firstDate = DateTime(now.year, 1, 1);
    DateTime startDate = firstDate.add(Duration(days: - firstDate.weekday));
    DateTime lastDate = DateTime(now.year, 12, 31);
    DateTime endDate = lastDate.add(Duration(days: 6 - lastDate.weekday));
    Duration duration = endDate.difference(startDate);
    int days = duration.inDays;
    List<AnnualTaskView> taskViews = [];
    if(birthday != null) {
      int year = now.year - birthday.year;
      if(now.month < birthday.month || (now.month == birthday.month && now.day < birthday.day)) {
        year -= 1;
      }
      int number = year ~/ 8;
      for(int i = 0; i < 10; i++) {
        List<AnnualTaskItem> taskItems = [];
        if(i < number) {
          for(int j = 0; j <= days; j++) {
            DateTime date = startDate.add(Duration(days: j));
            taskItems.add(AnnualTaskItem(
              date,
              1,
            ));
          }
        } else if(i == number) {
          DateTime nextBirthday = DateTime(birthday.year + number * 8, birthday.month, birthday.day);
          Duration lastDuration = now.difference(nextBirthday);
          int lastDays = lastDuration.inDays;
          int gridNumber = lastDays ~/ 8;
          int remainDays = lastDays % 8;
          for(int j = 0; j < gridNumber; j++) {
            DateTime date = startDate.add(Duration(days: j));
            taskItems.add(AnnualTaskItem(
              date,
              1,
            ));
          }
          if(remainDays > 0) {
            DateTime date = startDate.add(Duration(days: gridNumber));
            taskItems.add(AnnualTaskItem(
              date,
              remainDays / 8,
            ));
          }
        }
        taskViews.add(AnnualTaskView(
          taskItems,
          showMonthLabel: false,
          showWeekDayLabel: false,
        ));
      }
    }
    String birthdayStr = '点击设置';
    if(birthday != null) {
      birthdayStr = '${birthday.year}.${birthday.month}.${birthday.day}';
    }
    List<Widget> listItems = [
      ...taskViews,
      RaisedButton(
        onPressed: handleDateButtonPressed,
        child: Text("出生日期：${birthdayStr}"),
      ),
    ];
    return ListView(
      children: listItems,
    );
  }

}
