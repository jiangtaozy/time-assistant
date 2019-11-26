/*
 * Maintained by jemo from 2019.11.20 to now
 * Created by jemo on 2019.11.20 12:04
 * db
 */

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> database() async {
  return openDatabase(
    join(await getDatabasesPath(), 'time_assistant.db'),
    onCreate: (db, version) async {
      print('version: ${version}');
      await db.execute(
        'CREATE TABLE time_category(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)',
      );
      await db.execute(
        'CREATE TABLE time_record(id INTEGER PRIMARY KEY AUTOINCREMENT, time TEXT, categoryId INTEGER, content TEXT)',
      );
    },
    version: 1,
  );
}

void init() async {
  final Database db = await database();
  final int count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM time_category'));
  if(count == 0) {
    await db.rawInsert('INSERT INTO time_category(name) VALUES ("睡觉"), ("工作"), ("休息"), ("吃饭"), ("通勤"), ("运动"), ("看书"), ("反省")');
  }
}
