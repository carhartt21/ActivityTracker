import 'package:flutter/material.dart';

TimeOfDay parseTimeOfDay(String? value) {
  if (value != null) {
    var times = value.split(":");
    if (times.length == 2) {
      return TimeOfDay(hour: int.parse(times[0]), minute: int.parse(times[1]));
    }
  }

  return const TimeOfDay(hour: 12, minute: 0);
}

List<TimeOfDay> parseNotificationTimes (String? input) {
  List <TimeOfDay> notificationTimes = [];
  if (input != null) {
    List<String> times = input.split(";");
      for (String time in times){
        var timeSplit = time.split(":");
        if (timeSplit.length == 2) {
          notificationTimes.add(TimeOfDay(hour: int.parse(timeSplit[0]), minute: int.parse(timeSplit[1])));
        }
      }
  }
  else{
    notificationTimes.add(const TimeOfDay(hour: 12, minute: 0));
  }
  return notificationTimes;
}

DateTime transformDate(DateTime date) {
  return DateTime.utc(
    date.year,
    date.month,
    date.day,
    0,
  );
}

DateTime transformDateWithHour(DateTime date) {
  return DateTime.utc(
    date.year,
    date.month,
    date.day,
    date.hour,
    30
  );
}
