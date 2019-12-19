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
    onCreate: onCreate,
    onUpgrade: onUpgrade,
    version: 4,
  );
}

onCreate(db, version) async {
  print('onCreate version: ${version}');
  await db.execute(
    '''
    CREATE TABLE time_category(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      color TEXT
    )
    ''',
  );
  await db.execute(
    '''
    CREATE TABLE time_record(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      time TEXT,
      categoryId INTEGER,
      content TEXT
    )
    ''',
  );
  await db.rawInsert(
    '''
    INSERT INTO time_category(name, color)
    VALUES
    ("睡觉", "0xffef342a"),
    ("工作", "0xffffd00d"),
    ("休息", "0xff098ec4"),
    ("吃饭", "0xfff47a25"),
    ("通勤", "0xfff7b1bf"),
    ("运动", "0xffb295c5"),
    ("看书", "0xff79bce7"),
    ("反省", "0xff4ba946")
    '''
  );
  await db.execute(
    '''
    CREATE TABLE time_plan(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      categoryId INTEGER,
      startTimeHour INTEGER,
      startTimeMinute INTEGER,
      endTimeHour INTEGER,
      endTimeMinute INTEGER
    )
    ''',
  );
}

onUpgrade(Database db, int oldVersion, int newVersion) async {
  print('onUpgrade oldVersion: $oldVersion, newVersion: $newVersion');
  if(oldVersion == 1) {
    await db.execute(
      'DROP TABLE time_category'
    );
    await db.execute(
      '''
      CREATE TABLE time_category(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        color TEXT
      )
      ''',
    );
    await db.rawInsert(
      '''
      INSERT INTO time_category(name, color)
      VALUES
      ("睡觉", "0xffef342a"),
      ("工作", "0xffffd00d"),
      ("休息", "0xff098ec4"),
      ("吃饭", "0xfff47a25"),
      ("通勤", "0xfff7b1bf"),
      ("运动", "0xffb295c5"),
      ("看书", "0xff79bce7"),
      ("反省", "0xff4ba946")
      '''
    );
  }
  await db.execute(
    '''
    CREATE TABLE time_plan(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      categoryId INTEGER,
      startTimeHour INTEGER,
      startTimeMinute INTEGER,
      endTimeHour INTEGER,
      endTimeMinute INTEGER
    )
    ''',
  );
}
