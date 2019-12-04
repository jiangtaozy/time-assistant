/*
 * Maintained by jemo from 2019.12.3 to now
 * Created by jemo on 2019.12.3 16:49:56
 * Time record item category dropdown menu
 */

import 'package:flutter/material.dart';

class TimeRecordItemCategoryDropdownMenu extends StatefulWidget {

  TimeRecordItemCategoryDropdownMenu({
    Key key,
    this.timeCategory,
    this.timeRecordCategoryId,
    this.updateRecordCategoryId,
  }) : super(key: key);

  var timeCategory;
  int timeRecordCategoryId;
  var updateRecordCategoryId;

  @override
  TimeRecordItemCategoryDropdownMenuState createState() => TimeRecordItemCategoryDropdownMenuState();
}

class TimeRecordItemCategoryDropdownMenuState extends State<TimeRecordItemCategoryDropdownMenu> {

  var timeRecordCategoryId;

  @override
  initState() {
    super.initState();
    setState(() {
      timeRecordCategoryId = widget.timeRecordCategoryId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 10),
          child: Icon(Icons.bookmark_border),
        ),
        Container(
          margin: EdgeInsets.only(left: 15),
          child: DropdownButton<int>(
            value: timeRecordCategoryId,
            onChanged: (newValue) {
              setState(() {
                timeRecordCategoryId = newValue;
              });
              widget.updateRecordCategoryId(newValue);
            },
            items: widget.timeCategory
            .map<DropdownMenuItem<int>>((Map<String, dynamic> value) {
              return DropdownMenuItem<int>(
                value: value['id'],
                child: Text(value['name']),
              );
            })
            .toList(),
          ),
        ),
      ],
    );
  }
}
