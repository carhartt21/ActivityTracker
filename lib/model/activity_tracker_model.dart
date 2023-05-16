import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:ActivityTracker/constants.dart';
import 'package:ActivityTracker/habits/habit.dart';
import 'package:ActivityTracker/helpers.dart';
import 'package:ActivityTracker/model/habit_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ActivityTrackerModel {
  late Database db;

  Future<void> deleteEvent(int id, DateTime dateTime) async {
    try {
      await db.delete("events",
          where: "id = ? AND dateTime = ?",
          whereArgs: [id, dateTime.toString()]);
    } catch (_) {
      if (kDebugMode) {
        print(_);
      }
    }
  }

  Future<void> deleteHabit(int id) async {
    try {
      await db.delete("habits", where: "id = ?", whereArgs: [id]);
      await db.delete("events", where: "id = ?", whereArgs: [id]);
    } catch (_) {
      if (kDebugMode) {
        print(_);
      }
    }
  }

  Future<void> emptyTables() async {
    try {
      await db.delete("habits");
      await db.delete("events");
    } catch (_) {
      if (kDebugMode) {
        print(_);
      }
    }
  }

  Future<void> useBackup(List<Habit> habits) async {
    try {
      await emptyTables();
      for (var element in habits) {
        insertHabit(element);
        element.habitData.events.forEach(
          (key, value) {
            insertEvent(element.habitData.id!, key, value);
          },
        );
      }
    } catch (_) {
      if (kDebugMode) {
        print(_);
      }
    }
  }

  Future<void> editHabit(Habit habit) async {
    try {
      await db.update(
        "habits",
        habit.toMap(),
        where: "id = ?",
        whereArgs: [habit.habitData.id],
      );
    } catch (_) {
      if (kDebugMode) {
        print(_);
      }
    }
  }

  Future<List<Habit>> getAllHabits() async {
    final List<Map<String, dynamic>> habits =
        await db.query("habits", orderBy: "position");
    List<Habit> result = [];

    await Future.forEach(
      habits,
      (hab) async {
        int id = hab["id"];
        SplayTreeMap<DateTime, List> eventsMap = SplayTreeMap<DateTime, List>();
        await db.query("events", where: "id = $id").then(
          (events) {
            for (var event in events) {
              eventsMap[DateTime.parse(event["dateTime"] as String)] = [
                TaskStatus.values[event["taskStatus"] as int],
                event["burnedCalories"] as int,
                event["steps"] as int 
              ];
            }
            result.add(
              Habit(
                habitData: HabitData(
                  id: id,
                  position: hab["position"],
                  title: hab["title"],
                  hourly: hab["hourly"] == 0 ? false : true,               
                  calTarget: hab["calories"] ?? 0,
                  routine: hab["routine"] ?? "",
                  stepsTarget: hab["steps"] ?? 0,
                  stepsEnabled: hab["stepsEnabled"] == 0 ? false : true,
                  calEnabled: hab["caloriesEnabled"] == 0 ? false : true,
                  targetGoal: hab["targetGoal"] ?? 0,
                  notification: hab["notification"] == 0 ? false : true,
                  notTimes: parseNotificationTimes(hab["notTimes"]),
                  events: eventsMap,
                ),
              ),
            );
          },
        );
      },
    );
    return result;
  }

  // void _updateTableEventsV1toV2(Batch batch) {
  //   batch.execute('ALTER TABLE Events ADD comment TEXT DEFAULT ""');
  // }

  // void _updateTableHabitsV2toV3(Batch batch) {
  //   batch.execute('ALTER TABLE habits ADD sanction TEXT DEFAULT "" NOT NULL');
  //   batch.execute('ALTER TABLE habits ADD showSanction INTEGER DEFAULT 0 NOT NULL');
  //   batch.execute('ALTER TABLE habits ADD accountant TEXT DEFAULT "" NOT NULL');
  // }

  void _createTableEventsV3(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS events');
    batch.execute('''CREATE TABLE events (
    id INTEGER,
    dateTime TEXT,
    taskStatus INTEGER,
    burnedCalories INTEGER,
    steps INTEGER,
    PRIMARY KEY(id, dateTime),
    FOREIGN KEY (id) REFERENCES habits(id) ON DELETE CASCADE
    )''');
  }

  void _createTableHabitsV3(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS habits');
    batch.execute('''CREATE TABLE habits (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    position INTEGER,
    title TEXT,
    hourly INTEGER,
    routine TEXT, 
    calEnabled INTEGER,
    calTarget INTEGER,
    stepsEnabled INTEGER,
    stepsTarget INTEGER,
    targetGoal INTEGER,
    notification INTEGER,
    notTimes TEXT
    )''');
  }

  Future onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> initDatabase() async {
    var databasesPath = await getDatabasesPath();
    if (kDebugMode) {
      print(databasesPath);
    }
    db = await openDatabase(
      join(await getDatabasesPath(), 'ActivityTracker_db3.db'),
      version: 2,
      onCreate: (db, version) {
        var batch = db.batch();
        _createTableHabitsV3(batch);
        _createTableEventsV3(batch);
        batch.commit();
      },
      // onUpgrade: (db, oldVersion, newVersion) {
      //   var batch = db.batch();
      //   if (oldVersion == 1) {
      //     _updateTableEventsV1toV2(batch);
      //     _updateTableHabitsV2toV3(batch);
      //   }
      //   if (oldVersion == 2) {
      //     _updateTableHabitsV2toV3(batch);
      //   }
      //   batch.commit();
      // },
    );
  }

  Future<void> insertEvent(int id, DateTime date, List event) async {
    try {
      db.insert(
          "events",
          {
            "id": id,
            "dateTime": date.toString(),
            "taskStatus": event[0].index,
            "burnedCalories": event[1],
            "steps": event[2],
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {
      if (kDebugMode) {
        print(_);
      }
    }
  }


  Future<void> insertEventBatch(int id, Map<DateTime, List> events) async {
    try {
      Batch batch = db.batch();
      for (DateTime date in events.keys){
        batch.insert(
          "events",
          {
            "id": id,
            "dateTime": date.toString(),
            "taskStatus": events[date]![0].index,
            "burnedCalories": events[date]![1],
            "steps": events[date]![2],
          },
          conflictAlgorithm: ConflictAlgorithm.replace
        );
      }
      batch.commit(noResult: true);
    } catch (_) {
      if (kDebugMode) {
        print(_);
      }
    }
  }

  Future<int> insertHabit(Habit habit) async {
    try {
      var id = await db.insert("habits", habit.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return id;
    } catch (_) {
      if (kDebugMode) {
        print(_);
      }
    }
    return 0;
  }

  Future<void> updateOrder(List<Habit> habits) async {
    try {
      for (var habit in habits) {
        db.update(
          "habits",
          habit.toMap(),
          where: "id = ?",
          whereArgs: [habit.habitData.id],
        );
      }
    } catch (_) {
      if (kDebugMode) {
        print(_);
      }
    }
  }
}

