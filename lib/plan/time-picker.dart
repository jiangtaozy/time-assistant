/*
 * Maintained by jemo from 2019.12.19 to now
 * Created by jemo on 2019.12.19 12:03:55
 * time picker
 */

import 'package:flutter/material.dart';

class TimePicker extends StatefulWidget {

  TimePicker({
    Key key,
    this.time,
    this.updateTime,
    this.icon,
  }) : super(key: key);

  var time;
  var updateTime;
  var icon;

  @override
  TimePickerState createState() => TimePickerState();

}

class TimePickerState extends State<TimePicker> {

  var time;

  @override
  initState() {
    super.initState();
    setState(() {
      time = widget.time ?? TimeOfDay(hour: 0, minute: 0);
    });
  }

  handleEditTimePressed(context) async {
    TimeOfDay selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: time.hour,
        minute: time.minute,
      ),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child,
        );
      },
    );
    if(selectedTime != null) {
      widget.updateTime(selectedTime);
      setState(() {
        time = selectedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
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
              child: Icon(
                widget.icon ?? Icons.access_time,
              ),
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
