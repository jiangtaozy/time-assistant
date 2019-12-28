/*
 * Maintained by jemo from 2019.12.19 to now
 * Created by jemo on 2019.12.19 14:37:19
 * Plan Card
 */

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'time-picker.dart';
import '../db.dart';
import '../colors.dart';
import '../record/time-record-item/time-record-item-category-dropdown-menu.dart';

class PlanCard extends StatefulWidget {

  PlanCard({
    Key key,
    this.plan,
    this.getTimePlan,
    this.timeCategory,
  }) : super(key: key);

  var plan;
  var getTimePlan;
  var timeCategory;

  @override
  PlanCardState createState() => PlanCardState();

}

class PlanCardState extends State<PlanCard> {

  var selectedCategoryId;
  var startTime;
  var endTime;

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

  void onCardTap() {
    final plan = widget.plan;
    setState(() {
      selectedCategoryId = plan['categoryId'];
      startTime = TimeOfDay(
        hour: plan['startTimeHour'],
        minute: plan['startTimeMinute'],
      );
      endTime = TimeOfDay(
        hour: plan['endTimeHour'],
        minute: plan['endTimeMinute'],
      );
    });
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('修改时间规划'),
          children: <Widget>[
            TimeRecordItemCategoryDropdownMenu(
              timeCategory: widget.timeCategory,
              timeRecordCategoryId: selectedCategoryId,
              updateRecordCategoryId: updateSelectedCategoryId,
            ),
            TimePicker(
              time: startTime,
              updateTime: updateStartTime,
              icon: Icons.play_arrow,
            ),
            TimePicker(
              time: endTime,
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
    final plan = widget.plan;
    final planId = plan['id'];
    final db = await database();
    await db.update(
      'time_plan',
      {
        'categoryId': selectedCategoryId,
        'startTimeHour': startTime.hour,
        'startTimeMinute': startTime.minute,
        'endTimeHour': endTime.hour,
        'endTimeMinute': endTime.minute,
      },
      where: 'id = ?',
      whereArgs: [planId],
    );
    widget.getTimePlan();
    Navigator.of(context).pop();
  }

  void onCardLongPress(int planId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('删除这条时间规划吗？'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('取消'),
            ),
            FlatButton(
              onPressed: () {
                deletePlan(planId);
                Navigator.pop(context);
              },
              child: Text('确定'),
            ),
          ],
        );
      }
    );
  }

  void deletePlan(int planId) async {
    final db = await database();
    await db.delete(
      'time_plan',
      where: 'id = ?',
      whereArgs: [planId],
    );
    widget.getTimePlan();
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final startTimeHour = plan['startTimeHour'];
    final startTimeMinute = plan['startTimeMinute'].toString().padLeft(2, '0');
    final endTimeHour = plan['endTimeHour'];
    final endTimeMinute = plan['endTimeMinute'].toString().padLeft(2, '0');
    return Card(
      child: InkWell(
        onTap: onCardTap,
        onLongPress: () {
          onCardLongPress(plan['id']);
        },
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Text(
                plan['categoryName'],
                style: TextStyle(
                  color: Color(int.parse(plan['categoryColor'])),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: Text('开始时间: $startTimeHour:$startTimeMinute'),
              ),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: Text('结束时间: $endTimeHour:$endTimeMinute'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
