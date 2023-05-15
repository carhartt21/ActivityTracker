import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:ActivityTracker/constants.dart';
import 'package:ActivityTracker/habits/habit.dart';
import 'package:ActivityTracker/model/backup.dart';
import 'package:ActivityTracker/model/habit_data.dart';
import 'package:ActivityTracker/model/activity_tracker_model.dart';
import 'package:ActivityTracker/notifications.dart';
import 'package:ActivityTracker/statistics/statistics.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HabitsManager extends ChangeNotifier {
  final ActivityTrackerModel _activityTrackerModel = ActivityTrackerModel();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  late List<Habit> allHabits = [];
  bool _isInitialized = false;
  int _selectedHour = (-1);
  int _dailyTarget = 0;
  final HealthFactory _health = HealthFactory();
  List<HealthDataPoint> healthData = [];
  static final List<HealthDataType> healthTypes = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED
  ];
  final permissions = healthTypes.map((e) => HealthDataAccess.READ_WRITE).toList();




  Habit? deletedHabit;
  Queue<Habit> toDelete = Queue();

  void initialize() async {
    await initModel();
    await Future.delayed(const Duration(seconds: 5));
    notifyListeners();
  }

  resetHabitsNotifications() {
    resetNotifications(allHabits);
  }

  initModel() async {
    await _activityTrackerModel.initDatabase();
    allHabits = await _activityTrackerModel.getAllHabits();
    _isInitialized = true;
    notifyListeners();
  }

  GlobalKey<ScaffoldMessengerState> get getScaffoldKey {
    return _scaffoldKey;
  }

  void hideSnackBar() {
    _scaffoldKey.currentState!.hideCurrentSnackBar();
  }

  createBackup() async {
    try {
      var file = await Backup.writeBackup(allHabits);
      final params = SaveFileDialogParams(
        sourceFilePath: file.path,
        mimeTypesFilter: ['application/json'],
      );
      await FlutterFileDialog.saveFile(params: params);
    } catch (e) {
      showErrorMessage('ERROR: Creating backup failed.');
    }
  }

  loadBackup() async {
    try {
      const params = OpenFileDialogParams(
        fileExtensionsFilter: ['json'],
        mimeTypesFilter: ['application/json'],
      );
      final filePath = await FlutterFileDialog.pickFile(params: params);
      if (filePath == null) {
        return;
      }
      final json = await Backup.readBackup(filePath);
      List<Habit> habits = [];
      jsonDecode(json).forEach((element) {
        habits.add(Habit.fromJson(element));
      });
      await _activityTrackerModel.useBackup(habits);
      removeNotifications(allHabits);
      allHabits = habits;
      resetNotifications(allHabits);
      notifyListeners();
    } catch (e) {
      showErrorMessage('ERROR: Restoring backup failed.');
    }
  }

  authorizeHealthAccess() async{
    await Permission.activityRecognition.request();
    await Permission.location.request();

    // Check if we have permission
    bool? hasPermissions =
        await _health.hasPermissions(healthTypes, permissions: permissions);

    // hasPermissions = false because the hasPermission cannot disclose if WRITE access exists.
    // Hence, we have to request with WRITE as well.
    hasPermissions = false;

    bool authorized = false;
    if (!hasPermissions) {
      // requesting access to the data types before reading them
      try {
        authorized =
            await _health.requestAuthorization(healthTypes, permissions: permissions);
      } catch (error) {
        debugPrint("Exception in authorize: $error");
      }
    }
  }

  loadHealthData() async {
    try{
      List<HealthDataPoint> _dataPoints = [];
      _dataPoints = await _health.getHealthDataFromTypes(DateTime.now().subtract(const Duration(days: 7)), 
      DateTime.now(), healthTypes);
      healthData.addAll(_dataPoints);
      notifyListeners();
    }
    catch (e) {
      showErrorMessage('ERROR: Loading HealthData failed: $e');
    }
  }

  void selectHour(int idx) {
    _selectedHour = idx;
    notifyListeners();
  }

  void resetSelectedHour() {
    _selectedHour = -1;
    notifyListeners();
  }

  void resetDailyTarget(int target) {
    _dailyTarget = target;
    notifyListeners();
  }

  resetNotifications(List<Habit> habits) {
    for (var element in habits) {
      if (element.habitData.notification) {
        var data = element.habitData;
        setHabitNotifications(data.id!, data.notTimes, 'ActivityTracker', data.title);
      }
    }
  }

  removeNotifications(List<Habit> habits) {
    for (var element in habits) {
      disableHabitNotification(element.habitData.id!);
    }
  }

  showErrorMessage(String message) {
    _scaffoldKey.currentState!.hideCurrentSnackBar();
    _scaffoldKey.currentState!.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: ActivityTrackerColors.red,
      ),
    );
  }

  List<Habit> get getAllHabits {
    return allHabits;
  }

  List<HealthDataPoint> get getHealthData {
    return healthData;
  }

  bool get isInitialized {
    return _isInitialized;
  }

  reorderList(oldIndex, newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    Habit moved = allHabits.removeAt(oldIndex);
    allHabits.insert(newIndex, moved);
    updateOrder();
    _activityTrackerModel.updateOrder(allHabits);
    notifyListeners();
  }

  addEvent(int id, DateTime dateTime, List event) {
    _activityTrackerModel.insertEvent(id, dateTime, event);
  }

  deleteEvent(int id, DateTime dateTime) {
    _activityTrackerModel.deleteEvent(id, dateTime);
  }

  addEventBatch(int id, Map<DateTime, List> events) {
    _activityTrackerModel.insertEventBatch(id, events);
  }


  addHabit(
      String title,
      bool hourly,
      bool calEnabled,
      int calTarget,
      bool stepsEnabled,
      int stepsTarget,
      int targetGoal,
      String routine,
      bool notification,
      List<TimeOfDay> notTimes) 
      {
    Habit newHabit = Habit(
      habitData: HabitData(
        position: allHabits.length,
        title: title,
        hourly: hourly,
        calTarget: calTarget,
        routine: routine,
        stepsTarget: stepsTarget,
        stepsEnabled: stepsEnabled,
        calEnabled: calEnabled,
        targetGoal: targetGoal,
        events: SplayTreeMap<DateTime, List>(),
        notification: notification,
        notTimes: notTimes,
      ),
    );
    _activityTrackerModel.insertHabit(newHabit).then(
      (id) {
        newHabit.setId = id;
        allHabits.add(newHabit);
        if (notification) {
          setHabitNotifications(id, notTimes, 'ActivityTracker', title);
        } else {
          disableHabitNotifications(id, notTimes);
        }
        notifyListeners();
      },
    );
    updateOrder();
  }

  editHabit(HabitData habitData) {
    Habit? hab = findHabitById(habitData.id!);
    if (hab == null) return;
    hab.habitData.title = habitData.title;
    hab.habitData.hourly = habitData.hourly;
    hab.habitData.stepsTarget = habitData.stepsTarget;
    hab.habitData.routine = habitData.routine;
    hab.habitData.calTarget = habitData.calTarget;
    hab.habitData.calEnabled = habitData.calEnabled;
    hab.habitData.stepsEnabled = habitData.stepsEnabled;
    hab.habitData.targetGoal = habitData.targetGoal;
    hab.habitData.notification = habitData.notification;    
    hab.habitData.notTimes = habitData.notTimes;
    _activityTrackerModel.editHabit(hab);
    if (habitData.notification) {
      setHabitNotifications(
          habitData.id!, habitData.notTimes, 'ActivityTracker', habitData.title);
    } else {
      disableHabitNotifications(habitData.id!, habitData.notTimes);
    }
    notifyListeners();
  }

  String getNameOfHabit(int id) {
    Habit? hab = findHabitById(id);
    return (hab != null) ? hab.habitData.title : "";
  }

  Habit? findHabitById(int id) {
    Habit? result;
    for (var hab in allHabits) {
      if (hab.habitData.id == id) {
        result = hab;
      }
    }
    return result;
  }

  deleteHabit(int id) {
    deletedHabit = findHabitById(id);
    allHabits.remove(deletedHabit);
    toDelete.addLast(deletedHabit!);
    Future.delayed(const Duration(seconds: 4), () => deleteFromDB());
    _scaffoldKey.currentState!.hideCurrentSnackBar();
    _scaffoldKey.currentState!.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text("Habit deleted."),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            undoDeleteHabit(deletedHabit!);
          },
        ),
      ),
    );
    updateOrder();
    notifyListeners();
  }

  undoDeleteHabit(Habit del) {
    toDelete.remove(del);
    if (deletedHabit != null) {
      if (deletedHabit!.habitData.position < allHabits.length) {
        allHabits.insert(deletedHabit!.habitData.position, deletedHabit!);
      } else {
        allHabits.add(deletedHabit!);
      }
    }

    updateOrder();
    notifyListeners();
  }

  Future<void> deleteFromDB() async {
    if (toDelete.isNotEmpty) {
      disableHabitNotification(toDelete.first.habitData.id!);
      _activityTrackerModel.deleteHabit(toDelete.first.habitData.id!);
      toDelete.removeFirst();
    }
    if (toDelete.isNotEmpty) {
      Future.delayed(const Duration(seconds: 1), () => deleteFromDB());
    }
  }

  updateOrder() {
    int iterator = 0;
    for (var habit in allHabits) {
      habit.habitData.position = iterator++;
    }
  }

  Future<AllStatistics> getFutureStatsData() async {
    return await Statistics.calculateStatistics(allHabits);
  }
}
