/*
 * Maintained by jemo from 2019.11.14 to now
 * Created by jemo on 2019.11.14 17:39:20
 * Home
 */

import 'package:flutter/material.dart';
import 'dart:async';
import 'record/record.dart';
import 'analysis/analysis.dart';
import 'plan/plan.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite/sqflite.dart';
import 'db.dart';
import 'setting/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {

  int selectedIndex = 0;
  final widgetOptions = [
    Record(),
    Analysis(),
    Plan(),
    Setting(),
  ];
  Timer timePlanTimer;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initFlutterLocalNotifications();
  }

  void initFlutterLocalNotifications() async {
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification:
        (int id, String title, String body, String payload) async {
        print('id: $id');
        print('title: $title');
        print('body: $body');
        print('payload: $payload');
      }
    );
    var initializationSettings = InitializationSettings(
      initializationSettingsAndroid,
      initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String payload) async {
        print('payload: $payload');
      },
    );
    timePlanTimer = Timer.periodic(Duration(minutes: 10), (timer) async {
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel id', 'channel name', 'channel description',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker',
      );
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics,
        iOSPlatformChannelSpecifics,
      );
      final Database db = await database();
      final timePlan = await db.rawQuery('''
        SELECT time_plan.*,
        time_category.name AS categoryName,
        time_category.color AS categoryColor
        FROM time_plan
        LEFT JOIN time_category
        ON time_plan.categoryId = time_category.id
        ORDER BY time_plan.startTimeHour ASC
      ''');
      final now = TimeOfDay.now();
      final nowHour = now.hour;
      final nowMinute = now.minute;
      final records = await db.rawQuery('''
        SELECT *
        FROM time_record
        ORDER BY datetime(time) DESC
        LIMIT 1
      ''');
      if(records == null || records.length == 0) {
        return;
      }
      final lastRecord = records[0];
      final lastRecordCategoryId = lastRecord['categoryId'];
      for(int i = 0; i < timePlan.length; i++) {
        final plan = timePlan[i];
        final startTimeHour = plan['startTimeHour'];
        final startTimeMinute = plan['startTimeMinute'];
        final endTimeHour = plan['endTimeHour'];
        final endTimeMinute = plan['endTimeMinute'];
        final planCategoryId = plan['categoryId'];
        final planCategoryName = plan['categoryName'];
        final isStartTimeBeforeEndTime = startTimeHour < endTimeHour || (
          startTimeHour == endTimeHour && startTimeMinute <= endTimeMinute
        );
        final isNowTimeAfterStartTime = nowHour > startTimeHour || (
          nowHour == startTimeHour && nowMinute >= startTimeMinute
        );
        final isNowTimeBeforeEndTime = nowHour < endTimeHour || (
          nowHour == endTimeHour && nowMinute <= endTimeMinute
        );
        final isNoRemind = await isTodayNoRemind();
        if((isStartTimeBeforeEndTime &&
            isNowTimeAfterStartTime &&
            isNowTimeBeforeEndTime &&
            lastRecordCategoryId != planCategoryId &&
            !isNoRemind) || (
            !isStartTimeBeforeEndTime &&
            (isNowTimeAfterStartTime || isNowTimeBeforeEndTime) &&
            lastRecordCategoryId != planCategoryId &&
            !isNoRemind)) {
          await flutterLocalNotificationsPlugin.show(
            1,
            '该$planCategoryName了',
            '现在是您规划的$planCategoryName时间',
            platformChannelSpecifics,
            payload: 'payload',
          );
        }
      }
    });
  }

  Future<bool> isTodayNoRemind() async {
    bool todayNoRemind = false;
    final prefs = await SharedPreferences.getInstance();
    String todayNoRemindDate = prefs.getString('todayNoRemindDate');
    if(todayNoRemindDate != null) {
      DateTime date = DateTime.parse(todayNoRemindDate);
      DateTime now = DateTime.now();
      if(now.year == date.year && now.month == date.month && now.day == date.day) {
          todayNoRemind = true;
      }
    }
    return todayNoRemind;
  }

  @override
  void dispose() {
    timePlanTimer.cancel();
    super.dispose();
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('小福时间助手'),
      ),
      body: widgetOptions.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            title: Text('记录'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            title: Text('分析'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_alarm),
            title: Text('规划'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('设置'),
          ),
        ],
        currentIndex: selectedIndex,
        fixedColor: Colors.blue,
        onTap: onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
