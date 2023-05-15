import 'dart:collection';

import 'package:flutter/material.dart';

class HabitData {
  HabitData({
    this.id,
    required this.position,
    required this.title,
    required this.notification,
    required this.notTimes,
    required this.routine,
    required this.events,
    required this.hourly,
    required this.calEnabled,
    required this.calTarget,
    required this.targetGoal,
    required this.stepsEnabled,
    required this.stepsTarget,
  });

  SplayTreeMap<DateTime, List> events;
  int streak = 0;
  int? id;
  int position;
  String title;
  bool calEnabled;
  int calTarget;
  int targetGoal;
  bool stepsEnabled;
  int stepsTarget;
  String routine;
  bool hourly;
  bool notification;
  List<TimeOfDay> notTimes;
}
