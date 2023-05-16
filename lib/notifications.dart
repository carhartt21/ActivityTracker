import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:ActivityTracker/constants.dart';

void initializeNotifications() {
  AwesomeNotifications().initialize(
    'resource://raw/res_app_icon',
    [
      NotificationChannel(
          channelKey: 'app_notifications_ActivityTracker',
          channelName: 'App notifications',
          channelDescription:
              'Notification channel for application notifications',
          defaultColor: ActivityTrackerColors.primary,
          importance: NotificationImportance.Max,
          criticalAlerts: true),
      NotificationChannel(
          channelKey: 'habit_notifications_ActivityTracker',
          channelName: 'Habit notifications',
          channelDescription: 'Notification channel for habit notifications',
          defaultColor: ActivityTrackerColors.primary,
          importance: NotificationImportance.Max,
          criticalAlerts: true)
    ],
  );
}

void resetAppNotificationIfMissing(TimeOfDay timeOfDay) async {
  AwesomeNotifications().listScheduledNotifications().then((notifications) {
    for (var not in notifications) {
      if (not.content?.id == 0) {
        return;
      }
    }
    setAppNotification(timeOfDay);
  });
}

void setAppNotification(TimeOfDay timeOfDay) async {
  _setupDailyNotification(0, timeOfDay, 'ActivityTracker',
      'Do not forget to check your habits.', 'app_notifications_ActivityTracker');
}

void setHabitNotification(
    int id, TimeOfDay timeOfDay, String title, String desc) {
  _setupDailyNotification(
      id, timeOfDay, title, desc, 'habit_notifications_ActivityTracker');
}

void setHabitNotifications(
    int id, List<TimeOfDay> notTimes, title, String desc) {
  for (TimeOfDay notTime in notTimes){
    _setupDailyNotification(
      id*100+notTime.hour, notTime, title, desc, 'habit_notifications_ActivityTracker');
  }
}

void disableHabitNotification(int id) {
    AwesomeNotifications().cancel(id);
}

void disableHabitNotifications(int id, List<TimeOfDay> notTimes) {
  for (TimeOfDay notTime in notTimes){
    AwesomeNotifications().cancel(id * 100 + notTime.hour);
  }
}

void disableAppNotification() {
  AwesomeNotifications().cancel(0);
}

Future<void> _setupDailyNotification(int id, TimeOfDay timeOfDay, String title,
    String desc, String channel) async {
  String localTimeZone =
      await AwesomeNotifications().getLocalTimeZoneIdentifier();
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: id,
      channelKey: channel,
      title: title,
      body: desc,
      wakeUpScreen: true,
      criticalAlert: true,
      category: NotificationCategory.Reminder,
    ),
    schedule: NotificationCalendar(
        hour: timeOfDay.hour,
        minute: timeOfDay.minute,
        second: 0,
        millisecond: 0,
        repeats: true,
        preciseAlarm: true,
        timeZone: localTimeZone),
  );
}
