import 'package:flutter/material.dart';
import 'package:ActivityTracker/constants.dart';
import 'package:ActivityTracker/helpers.dart';
import 'package:table_calendar/table_calendar.dart';

class SettingsData {
  final List<String> themeList = ["Device", "Light", "Dark"];
  final List<String> weekStartList = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"];
  Themes theme = Themes.dark;
  StartingDayOfWeek weekStart = StartingDayOfWeek.monday;
  TimeOfDay dailyNotTime = const TimeOfDay(hour: 20, minute: 0);
  bool showDailyNot = true;
  bool showMonthName = true;
  bool seenOnboarding = true;
  Color checkColor = ActivityTrackerColors.primary;
  Color failColor = ActivityTrackerColors.red;
  Color skipColor = ActivityTrackerColors.skip;

  SettingsData();

  SettingsData.fromJson(Map<String, dynamic> json)
      : theme = Themes.values[json['theme']],
        weekStart = StartingDayOfWeek.values[json['weekStart']],
        showDailyNot =
            (json['showDailyNot'] != null) ? json['showDailyNot'] : true,
        showMonthName =
            (json['showMonthName'] != null) ? json['showMonthName'] : true,
        dailyNotTime = (json['notTime'] != null)
            ? parseTimeOfDay(json['notTime'])
            : const TimeOfDay(hour: 20, minute: 0),
        seenOnboarding =
            (json['seenOnboarding'] != null) ? json['seenOnboarding'] : false,
        checkColor = (json['checkColor'] != null)
            ? Color(json['checkColor'])
            : ActivityTrackerColors.primary,
        failColor = (json['failColor'] != null)
            ? Color(json['failColor'])
            : ActivityTrackerColors.red,
        skipColor = (json['skipColor'] != null)
            ? Color(json['skipColor'])
            : ActivityTrackerColors.skip;

  Map<String, dynamic> toJson() => {
        'theme': theme.index,
        'weekStart': weekStart.index,
        'notTime':
            '${dailyNotTime.hour.toString().padLeft(2, '0')}:${dailyNotTime.minute.toString().padLeft(2, '0')}',
        'showDailyNot': showDailyNot,
        'showMonthName': showMonthName,
        'seenOnboarding': seenOnboarding,
        'checkColor': checkColor.value,
        'failColor': failColor.value,
        'skipColor': skipColor.value,
      };
}
