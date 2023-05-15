import 'dart:collection';

import 'package:ActivityTracker/constants.dart';
import 'package:ActivityTracker/habits/habit.dart';

class StatisticsData {
  String title = "";
  int topStreak = 0;
  int actualStreak = 0;
  int checks = 0;
  int skips = 0;
  int fails = 0;
  SplayTreeMap<int, Map<TaskStatus, List<int>>> monthlyCheck = SplayTreeMap();
}

class OverallStatisticsData {
  int checks = 0;
  int skips = 0;
  int fails = 0;
}

class AllStatistics {
  OverallStatisticsData total = OverallStatisticsData();
  List<StatisticsData> habitsData = [];
}

class Statistics {
  static Future<AllStatistics> calculateStatistics(List<Habit>? habits) async {
    AllStatistics stats = AllStatistics();

    if (habits == null) return stats;

    for (var habit in habits) {
      var stat = StatisticsData();
      stat.title = habit.habitData.title;

      bool hourly = false;

      SplayTreeMap treeMap = SplayTreeMap.from(habit.habitData.events);

      var lastDay = treeMap.firstKey();

      habit.habitData.events.forEach(
        (key, value) {
          if (value[0] != null && value[0] != TaskStatus.clear) {
            if (key.difference(lastDay!).inDays > 1) {
              stat.actualStreak = 0;
            }

            switch (value[0]) {
              case TaskStatus.check:
                stat.checks++;
                stat.actualStreak++;
                if (stat.actualStreak > stat.topStreak) {
                  stat.topStreak = stat.actualStreak;
                }
                break;
              case TaskStatus.skip:
                stat.skips++;
                break;
              case TaskStatus.fail:
                stat.fails++;
                stat.actualStreak = 0;
                break;
            }

            generateYearIfNull(stat, key.year);

            if (value[0] != TaskStatus.clear) {
              stat.monthlyCheck[key.year]![value[0]]![key.month - 1]++;
            }

            lastDay = key;
          }
        },
      );

      generateYearIfNull(stat, DateTime.now().year);
      stats.habitsData.add(stat);
      stats.total.checks += stat.checks;
      stats.total.fails += stat.fails;
      stats.total.skips += stat.skips;
    }
    return stats;
  }

  static generateYearIfNull(StatisticsData stat, int year) {
    if (stat.monthlyCheck[year] == null) {
      stat.monthlyCheck[year] = {
        TaskStatus.check: List.filled(12, 0),
        TaskStatus.skip: List.filled(12, 0),
        TaskStatus.fail: List.filled(12, 0),
      };
    }
  }
}
