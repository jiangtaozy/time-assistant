/*
 * Maintained by jemo from 2020.1.10 to now
 * Created by jemo on 2020.1.10 13:59:44
 * Calculation
 */

import 'package:quiver/time.dart';

getTimeCategoryDuration(timeRecord, timeCategory) {
  var now = DateTime.now();
  var timeRecordDuration = [];
  // 每条记录时长
  for(var i = 0; i < timeRecord.length; i++) {
    final record = timeRecord[i];
    final time = DateTime.parse(record['time']);
    if(i == 0) {
      final dayStart = DateTime(
        time.year,
        time.month,
        time.day,
      );
      final duration = time.difference(dayStart);
      timeRecordDuration.add({
        'time': dayStart,
        'duration': duration,
        'categoryId': 1,
      });
    } else {
      final lastRecord = timeRecord[i - 1];
      final lastTime = DateTime.parse(lastRecord['time']);
      if(lastTime.year == time.year && lastTime.month == time.month && lastTime.day == time.day) {
        final duration = time.difference(lastTime);
        timeRecordDuration.add({
          'time': lastTime,
          'duration': duration,
          'categoryId': lastRecord['categoryId'],
        });
      } else {
        final nextDay = DateTime(
          lastTime.year,
          lastTime.month,
          lastTime.day + 1,
        );
        final duration = nextDay.difference(lastTime);
        timeRecordDuration.add({
          'time': lastTime,
          'duration': duration,
          'categoryId': lastRecord['categoryId'],
        });
        final today = DateTime(
          time.year,
          time.month,
          time.day,
        );
        final todayDuration = time.difference(today);
        timeRecordDuration.add({
          'time': today,
          'duration': todayDuration,
          'categoryId': lastRecord['categoryId'],
        });
      }
      if(i == timeRecord.length - 1) {
        var duration;
        if(time.year == now.year && time.month == now.month && time.day == now.day) {
          duration = now.difference(time);
        } else {
          final nextDay = DateTime(
            time.year,
            time.month,
            time.day + 1,
          );
          duration = nextDay.difference(time);
        }
        timeRecordDuration.add({
          'time': time,
          'duration': duration,
          'categoryId': record['categoryId'],
        });
      }
    }
  }
  var timeCategoryDuration = [];
  for(var i = 0; i < timeCategory.length; i++) {
    final category = timeCategory[i];
    timeCategoryDuration.add({
      'categoryId': category['id'],
      'categoryName': category['name'],
      'color': category['color'],
      'durationList': [],
    });
  }
  // 每项类型每天时长
  for(var i = 0; i < timeRecordDuration.length; i++) {
    final recordDuration = timeRecordDuration[i];
    final time = recordDuration['time'];
    for(var j = 0; j < timeCategoryDuration.length; j++) {
      final categoryDuration = timeCategoryDuration[j];
      if(categoryDuration['categoryId'] == recordDuration['categoryId']) {
        final durationList = categoryDuration['durationList'];
        var ifAlreadyInCategoryDurationList = false;
        for(var k = 0; k < durationList.length; k++) {
          final durationListData = durationList[k];
          final durationListDataDayTime = durationListData['dayTime'];
          if(durationListDataDayTime.year == time.year &&
            durationListDataDayTime.month == time.month &&
            durationListDataDayTime.day == time.day) {
            durationListData['duration'] += recordDuration['duration'];
            ifAlreadyInCategoryDurationList = true;
            break;
          }
        }
        if(!ifAlreadyInCategoryDurationList) {
          durationList.add({
            'dayTime': DateTime(
              time.year,
              time.month,
              time.day,
            ),
            'duration': recordDuration['duration'],
          });
        }
      }
    }
  }
  // 增加零数据
  for(var i = 0; i < timeCategoryDuration.length; i++) {
    final categoryDuration = timeCategoryDuration[i];
    final durationList = categoryDuration['durationList'];
    final newDurationList = [];
    for(var j = 0; j < durationList.length; j++) {
      final durationListData = durationList[j];
      final time = durationListData['dayTime'];
      newDurationList.add(durationListData);
      if(j < durationList.length - 1) {
        final nextData = durationList[j + 1];
        final nextTime = nextData['dayTime'];
        final differenceDuration = nextTime.difference(time);
        final differenceInDays = differenceDuration.inDays;
        if(differenceInDays > 1) {
          for(var k = 0; k < differenceInDays - 1; k++) {
            newDurationList.add({
              'dayTime': time.add(
                Duration(days: (k + 1)),
              ),
              'duration': Duration(),
            });
          }
        }
      } else {
        final now = DateTime.now();
        final differenceDuration = now.difference(time);
        final differenceInDays = differenceDuration.inDays;
        if(differenceInDays > 0) {
          for(var l = 0; l < differenceInDays; l++) {
            newDurationList.add({
              'dayTime': time.add(
                Duration(days: (l + 1)),
              ),
              'duration': Duration(),
            });
          }
        }
      }
    }
    categoryDuration['durationList'] = newDurationList;
  }
  return timeCategoryDuration;
}

getWeekTimeCategoryDuration(timeCategoryDuration) {
  final weekTimeCategoryDuration = timeCategoryDuration.map((categoryDuration) {
    final durationList = categoryDuration['durationList'];
    var weekDurationList = [];
    for(int j = 0; j < durationList.length; j++) {
      final durationData = durationList[j];
      final dayTime = durationData['dayTime'];
      final duration = durationData['duration'];
      final weekTime = dayTime.add(
        Duration(
          days: -(dayTime.weekday - 1),
        ),
      );
      bool hasInList = false;
      for(int k = 0; k < weekDurationList.length; k++) {
        final weekDuration = weekDurationList[k];
        final listWeekTime = weekDuration['weekTime'];
        if(weekTime.year == listWeekTime.year &&
          weekTime.month == listWeekTime.month &&
          weekTime.day == listWeekTime.day) {
          //weekDuration['durationList'].add(duration);
          weekDuration['totalDuration'] += duration;
          hasInList = true;
          break;
        }
      }
      if(!hasInList) {
        weekDurationList.add({
          'weekTime': weekTime,
          //'durationList': [duration],
          'totalDuration': duration,
        });
      }
    }
    final finalDurationList = [];
    final now = DateTime.now();
    for(int l = 0; l < weekDurationList.length; l++) {
      final weekDuration = weekDurationList[l];
      final weekTime = weekDuration['weekTime'];
      int days = 7;
      if(now.difference(weekTime).inDays < 7) {
        days = now.weekday;
      }
      finalDurationList.add({
        'dayTime': weekDuration['weekTime'],
        'duration': weekDuration['totalDuration'] ~/ days,
      });
    }
    return {
      'categoryId': categoryDuration['categoryId'],
      'categoryName': categoryDuration['categoryName'],
      'color': categoryDuration['color'],
      'durationList': finalDurationList,
    };
  }).toList();
  return weekTimeCategoryDuration;
}

getMonthTimeCategoryDuration(timeCategoryDuration) {
  final monthTimeCategoryDuration = timeCategoryDuration.map((categoryDuration) {
    final durationList = categoryDuration['durationList'];
    var monthDurationList = [];
    for(int j = 0; j < durationList.length; j++) {
      final durationData = durationList[j];
      final dayTime = durationData['dayTime'];
      final duration = durationData['duration'];
      final monthTime = dayTime.add(
        Duration(
          days: -(dayTime.day - 1),
        ),
      );
      bool hasInList = false;
      for(int k = 0; k < monthDurationList.length; k++) {
        final monthDuration = monthDurationList[k];
        final listMonthTime = monthDuration['monthTime'];
        if(monthTime.year == listMonthTime.year &&
          monthTime.month == listMonthTime.month &&
          monthTime.day == listMonthTime.day) {
          monthDuration['totalDuration'] += duration;
          hasInList = true;
          break;
        }
      }
      if(!hasInList) {
        monthDurationList.add({
          'monthTime': monthTime,
          'totalDuration': duration,
        });
      }
    }
    final finalDurationList = [];
    final now = DateTime.now();
    for(int l = 0; l < monthDurationList.length; l++) {
      final monthDuration = monthDurationList[l];
      final monthTime = monthDuration['monthTime'];
      int days = daysInMonth(
        monthTime.year,
        monthTime.month,
      );
      if(now.year == monthTime.year &&
        now.month == monthTime.month) {
        days = now.day;
      }
      finalDurationList.add({
        'dayTime': monthDuration['monthTime'],
        'duration': monthDuration['totalDuration'] ~/ days,
      });
    }
    return {
      'categoryId': categoryDuration['categoryId'],
      'categoryName': categoryDuration['categoryName'],
      'color': categoryDuration['color'],
      'durationList': finalDurationList,
    };
  }).toList();
  return monthTimeCategoryDuration;
}
