/*
 * Maintained by jemo from 2019.12.3 to now
 * Created by jemo on 2019.12.3 15:36:34
 * Time record item
 */

import 'package:flutter/material.dart';
import 'db.dart';
import 'time-record-item-category-dropdown-menu.dart';
import 'time-record-item-time-picker.dart';

class TimeRecordItem extends StatefulWidget {

  TimeRecordItem({
    Key key,
    this.record,
    this.getTimeRecord,
    this.timeCategory,
  }) : super(key: key);

  var record;
  var getTimeRecord;
  var timeCategory;

  @override
  TimeRecordItemState createState() => TimeRecordItemState();
}

class TimeRecordItemState extends State<TimeRecordItem> {

  var recordTime;
  var recordContent;
  var recordCategoryId;

  @override
  initState() {
    super.initState();
    setState(() {
      final record = widget.record;
      final time = DateTime.parse(record['time']);
      recordTime = time;
      recordContent = record['content'];
      recordCategoryId = record['categoryId'];
    });
  }

  updateRecordTime(time) {
    setState(() {
      recordTime = time;
    });
  }

  updateRecordCategoryId(categoryId) {
    setState(() {
      recordCategoryId = categoryId;
    });
  }

  deleteRecord() async {
    final record = widget.record;
    var recordId = record['id'];
    final db = await database();
    await db.delete(
      'time_record',
      where: 'id = ?',
      whereArgs: [recordId],
    );
    widget.getTimeRecord();
  }

  handleTimeRecordLongPressed(context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('删除这条记录吗？'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('取消'),
            ),
            FlatButton(
              onPressed: () {
                deleteRecord();
                Navigator.pop(context);
              },
              child: Text('确定'),
            ),
          ],
        );
      }
    );
  }

  handleTimeRecordPressed(context) async {
    final record = widget.record;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('修改记录'),
          children: <Widget>[
            TimeRecordItemTimePicker(
              recordTime: recordTime,
              updateRecordTime: updateRecordTime,
            ),
            Container(
              margin: EdgeInsets.only(left: 10),
              child: TextFormField(
                initialValue: recordContent,
                decoration: InputDecoration(
                  icon: Icon(Icons.code),
                  hintText: '内容',
                ),
                maxLines: null,
                onChanged: handleRecordContentChanged,
              ),
            ),
            TimeRecordItemCategoryDropdownMenu(
              timeCategory: widget.timeCategory,
              timeRecordCategoryId: record['categoryId'],
              updateRecordCategoryId: updateRecordCategoryId,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('取消'),
                ),
                RaisedButton(
                  onPressed: () {
                    handleEditRecordSubmitButtonPressed(context);
                  },
                  child: Text('确定'),
                ),
              ],
            ),
          ],
        );
      }
    );
  }

  handleEditRecordSubmitButtonPressed(context) async {
    final record = widget.record;
    final recordId = record['id'];
    final db = await database();
    var res = await db.update(
      'time_record',
      {
        'time': recordTime.toIso8601String(),
        'content': recordContent,
        'categoryId': recordCategoryId,
      },
      where: 'id = ?',
      whereArgs: [recordId],
    );
    widget.getTimeRecord();
    Navigator.of(context).pop();
  }

  handleRecordContentChanged(value) {
    setState(() {
      recordContent = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    var time = DateTime.parse(record['time']);
    var timeString = '${time.hour}:${time.minute}';
    var title = timeString;
    if(record['name'] != null) {
      title = title + ' ' + record['name'];
    }
    if(record['content'] != null) {
      title = title + ' ' + record['content'];
    }
    return Card(
      child: InkWell(
        onTap: () {
          handleTimeRecordPressed(context);
        },
        onLongPress: () {
          handleTimeRecordLongPressed(context);
        },
        child: ListTile(
          title: Text(title)
        ),
      ),
    );
  }
}
