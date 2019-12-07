/*
 * Maintained by jemo from 2019.12.4 to now
 * Created by jemo on 2019.12.4 10:32:49
 * Time record item time picker
 */

import 'package:flutter/material.dart';

class TimeRecordItemTimePicker extends StatefulWidget {

  TimeRecordItemTimePicker({
    Key key,
    this.recordTime,
    this.updateRecordTime,
  }) : super(key: key);

  var recordTime;
  var updateRecordTime;

  @override
  TimeRecordItemTimePickerState createState() => TimeRecordItemTimePickerState();
}

class TimeRecordItemTimePickerState extends State<TimeRecordItemTimePicker> {

  var recordTime;

  @override
  initState() {
    super.initState();
    setState(() {
      recordTime = widget.recordTime;
    });
  }

  handleEditTimePressed(context) async {
    TimeOfDay selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: recordTime.hour,
        minute: recordTime.minute,
      ),
    );
    if(selectedTime != null) {
      var newTime = DateTime(
        recordTime.year,
        recordTime.month,
        recordTime.day,
        selectedTime.hour,
        selectedTime.minute,
        recordTime.second,
        recordTime.millisecond,
        recordTime.microsecond,
      );
      widget.updateRecordTime(newTime);
      setState(() {
        recordTime = newTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hour = recordTime.hour.toString().padLeft(2, '0');
    final minute = recordTime.minute.toString().padLeft(2, '0');
    var timeString = '${hour}:${minute}';
    return InkWell(
      onTap: () {
        handleEditTimePressed(context);
      },
      child: Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10),
              child: Icon(Icons.access_time),
            ),
            Container(
              margin: EdgeInsets.only(left: 15),
              child: Text(timeString),
            ),
          ],
        ),
      ),
    );
  }
}
