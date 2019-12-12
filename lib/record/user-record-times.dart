/*
 * Maintained by jemo from 2019.12.12 to now
 * Created by jemo on 2019.12.12 17:56:34
 * User record times
 */

import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../db.dart';
import '../config.dart';

void userRecordTimes() async {
  final prefs = await SharedPreferences.getInstance();
  var userId = prefs.getString('userId');
  if(userId == null) {
    final uuid = Uuid();
    userId = uuid.v4();
    prefs.setString('userId', userId);
  }
  final Database db = await database();
  final now = DateTime.now();
  final today = DateTime(
    now.year,
    now.month,
    now.day,
  );
  final int count = Sqflite.firstIntValue(
    await db.rawQuery('''
      SELECT COUNT(*)
      FROM time_record
      WHERE DATETIME(time)
      BETWEEN DATETIME('${today}', '-1 day')
      AND DATETIME('${today}')
      ORDER BY DATETIME(time) ASC
    ''')
  );
  final query = r'''
    mutation userRecordTimes(
      $id: String!,
      $lastDayRecordTimes: Int!
    ) {
      userRecordTimes(
        id: $id,
        lastDayRecordTimes: $lastDayRecordTimes
      )
    }
  ''';
  Map<String, dynamic> variables = {
    'id': userId,
    'lastDayRecordTimes': count,
  };
  final data = {
    'query': query,
    'variables': variables,
  };
  final body = json.encode(data);
  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
    },
    body: body,
  );
  if(response.statusCode != 200) {
    print('response: $response');
  }
}
