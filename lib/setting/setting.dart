/*
 * Maintained by jemo from 2019.12.20 to now
 * Created by jemo on 2019.12.20 10:13:15
 * Setting
 */

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../db.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class Setting extends StatefulWidget {

  @override
  SettingState createState() => SettingState();
}

class SettingState extends State<Setting> {

  void onExportDataCardTap() async {
    final Database db = await database();
    final records = await db.rawQuery('''
      SELECT *
      FROM time_record
    ''');
    var permissionHandler = PermissionHandler();
    PermissionStatus permission = await permissionHandler.checkPermissionStatus(
      PermissionGroup.storage,
    );
    if(permission != PermissionStatus.granted) {
      var requestPermissions = await permissionHandler.requestPermissions(
        [PermissionGroup.storage]
      );
      if(requestPermissions[PermissionGroup.storage] != PermissionStatus.granted) {
        return;
      }
    }
    final directory = await getExternalStorageDirectory();
    final path = directory.path;
    final file = File('$path/data.json');
    final writeFile = await file.writeAsString(jsonEncode(records));
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('保存成功'),
          content: Text('文件路径：${writeFile.path}'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onImportDataCardTap() async {
    try {
      File file = await FilePicker.getFile();
      String data = await file.readAsString();
      final records = jsonDecode(data);
      final db = await database();
      final batch = db.batch();
      for(int i = 0; i < records.length; i++) {
        final record = records[i];
        batch.insert(
          'time_record',
          records[i],
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      await batch.commit();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('导入成功'),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch(error) {
      print('error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Card(
          child: InkWell(
            onTap: onExportDataCardTap,
            child: ListTile(
              leading: Icon(Icons.sd_card),
              title: Text('导出数据'),
            ),
          ),
        ),
        Card(
          child: InkWell(
            onTap: onImportDataCardTap,
            child: ListTile(
              leading: Icon(Icons.folder_open),
              title: Text('导入数据'),
            ),
          ),
        ),
      ],
    );
  }
}
