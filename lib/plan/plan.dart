/*
 * Maintained by jemo from 2019.12.19 to now
 * Created by jemo on 2019.12.19 10:06:46
 * Plan
 */

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:permission_handler/permission_handler.dart';
import '../db.dart';
import '../colors.dart';
import '../record/time-record-item/time-record-item-category-dropdown-menu.dart';
import 'plan-card.dart';
import 'time-picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Plan extends StatefulWidget {

  @override
  PlanState createState() => PlanState();

}

class PlanState extends State<Plan> {

  var timeCategory = [];
  var timePlan = [];
  var selectedCategoryId;
  var startTime;
  var endTime;
  bool todayNoRemind = false;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    getTimeCategory();
    getTimePlan();
    getTodayNoRemindDate();
  }

  void getTodayNoRemindDate() async {
    prefs = await SharedPreferences.getInstance();
    String todayNoRemindDate = prefs.getString('todayNoRemindDate');
    if(todayNoRemindDate != null) {
      DateTime date = DateTime.parse(todayNoRemindDate);
      DateTime now = DateTime.now();
      if(now.year == date.year && now.month == date.month && now.day == date.day) {
        setState(() {
          todayNoRemind = true;
        });
      }
    }
  }

  void onTodayNoRemindSwitch(bool value) {
    if(value) {
      DateTime now = DateTime.now();
      prefs.setString('todayNoRemindDate', now.toIso8601String());
    } else {
      prefs.remove('todayNoRemindDate');
    }
    setState(() {
      todayNoRemind = value;
    });
  }

  void updateSelectedCategoryId(int categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
    });
  }

  void updateStartTime(time) {
    setState(() {
      startTime = time;
    });
  }

  void updateEndTime(time) {
    setState(() {
      endTime = time;
    });
  }

  void getTimeCategory() async {
    final Database db = await database();
    final List<Map<String, dynamic>> category = await db.query('time_category');
    setState(() {
      timeCategory = category;
    });
  }

  void getTimePlan() async {
    final Database db = await database();
    final plan = await db.rawQuery('''
      SELECT time_plan.*,
      time_category.name AS categoryName,
      time_category.color AS categoryColor
      FROM time_plan
      LEFT JOIN time_category
      ON time_plan.categoryId = time_category.id
      ORDER BY time_plan.startTimeHour, time_plan.startTimeMinute ASC
    ''');
    if(plan.length > 0) {
      checkNotificationPermission();
    }
    setState(() {
      timePlan = plan;
    });
  }

  void onFloatingAddButtonPressed() {
    setState(() {
      selectedCategoryId = 1;
      startTime = TimeOfDay(hour: 0, minute: 0);
      endTime = TimeOfDay(hour: 0, minute: 0);
    });
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('添加规划'),
          children: <Widget>[
            TimeRecordItemCategoryDropdownMenu(
              timeCategory: timeCategory,
              timeRecordCategoryId: selectedCategoryId,
              updateRecordCategoryId: updateSelectedCategoryId,
            ),
            TimePicker(
              updateTime: updateStartTime,
              icon: Icons.play_arrow,
            ),
            TimePicker(
              updateTime: updateEndTime,
              icon: Icons.stop,
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
                  onPressed: onPlanDialogSubmitButtonPressed,
                  child: Text('确定'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void onPlanDialogSubmitButtonPressed() async {
    final db = await database();
    await db.insert(
      'time_plan',
      {
        'categoryId': selectedCategoryId,
        'startTimeHour': startTime.hour,
        'startTimeMinute': startTime.minute,
        'endTimeHour': endTime.hour,
        'endTimeMinute': endTime.minute,
      }
    );
    getTimePlan();
    Navigator.of(context).pop();
  }

  void checkNotificationPermission() async {
    var permissionHandler = PermissionHandler();
    PermissionStatus permissionStatus = await permissionHandler.checkPermissionStatus(
      PermissionGroup.notification,
    );
    if(permissionStatus != PermissionStatus.granted) {
      var result = await permissionHandler.requestPermissions(
        [PermissionGroup.notification]
      );
      if(result[PermissionGroup.notification] == PermissionStatus.unknown) {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('需要您将通知设置为允许通知'),
              actions: <Widget>[
                FlatButton(
                  child: Text('取消'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('去设置'),
                  onPressed: () async {
                    await PermissionHandler().openAppSettings();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var planWidgetList = timePlan.map((plan) {
      return PlanCard(
        plan: plan,
        getTimePlan: getTimePlan,
        timeCategory: timeCategory,
      );
    }).toList();
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: [
                ...planWidgetList,
                planWidgetList.length == 0 ? Container() : Card(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('今日不再提醒'),
                        Switch(
                          value: todayNoRemind,
                          onChanged: onTodayNoRemindSwitch,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onFloatingAddButtonPressed,
        child: Icon(Icons.add),
      ),
    );
  }

}
