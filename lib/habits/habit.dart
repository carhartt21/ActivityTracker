import 'dart:collection';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:activity_tracker/constants.dart';
import 'package:activity_tracker/habits/habit_header.dart';
import 'package:activity_tracker/habits/habits_manager.dart';
import 'package:activity_tracker/habits/one_hour_button.dart';
import 'package:activity_tracker/helpers.dart';
import 'package:activity_tracker/model/habit_data.dart';
import 'package:activity_tracker/navigation/app_state_manager.dart';
import 'package:activity_tracker/settings/settings_manager.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:health/health.dart';

import 'one_day.dart';
import 'one_day_button_hourly.dart';
import 'one_day_button.dart';

class Habit extends StatefulWidget {
  const Habit({super.key, required this.habitData});

  final HabitData habitData;

  set setId(int id) {
    habitData.id = id;
  }

  String notificationTimesToString(List<TimeOfDay> notTimes) {
    if (notTimes != null) {
      String notTimeString = "";
      for (var time in notTimes) {
        notTimeString += "${time.hour}:${time.minute};";
      }
      return notTimeString;
    }
    return "";
  }

  Map<String, dynamic> toMap() {
    return {
      "id": habitData.id,
      "title": habitData.title,
      "position": habitData.position,
      "notification": habitData.notification ? 1 : 0,
      "hourly": habitData.hourly ? 1 : 0,
      "notTimes": notificationTimesToString(habitData.notTimes),
      "routine": habitData.routine,
      "calEnabled": habitData.calEnabled ? 1 : 0,
      "calTarget": "${habitData.calTarget}",
      "targetGoal": "${habitData.targetGoal}",
      "stepsEnabled": habitData.stepsEnabled ? 1 : 0,
      "stepsTarget": "${habitData.stepsTarget}",
    };
  }

  Map<String, dynamic> toJson() {
    return {
      "id": habitData.id,
      "title": habitData.title,
      "position": habitData.position,
      "notification": habitData.notification ? 1 : 0,
      "notTime": notificationTimesToString(habitData.notTimes),
      "hourly": habitData.hourly ? 1 : 0,
      "routine": habitData.routine,
      "calEnabled": habitData.calEnabled ? 1 : 0,
      "calTarget": "${habitData.calTarget}",
      "targetGoal": "${habitData.targetGoal}",
      "stepsEnabled": habitData.stepsEnabled ? 1 : 0,
      "stepsTarget": "${habitData.stepsTarget}",
      "events": habitData.events.map((key, value) {
        return MapEntry(key.toString(), [value[0].toString(), value[1]]);
      }),
    };
  }

  Habit.fromJson(Map<String, dynamic> json, {super.key})
      : habitData = HabitData(
          id: json['id'],
          position: json['position'],
          title: json['title'],
          routine: json['routine'],
          notification: json['notification'] != 0 ? true : false,
          hourly: json['hourly'] != 0 ? true : false,
          notTimes: parseNotificationTimes(json['notTimes']),
          events: doEvents(json['events']),
          calEnabled: json['caloriesEnabled'] != 0 ? true : false,
          calTarget: json['calTarget'],
          targetGoal: json['targetGoal'],
          stepsEnabled: json['stepsEnabled'] != 0 ? true : false,
          stepsTarget: json['stepsTarget'],
        );

  static SplayTreeMap<DateTime, List> doEvents(SplayTreeMap<String, dynamic> input) {
    SplayTreeMap<DateTime, List> result = SplayTreeMap<DateTime, List>();
    input.forEach((key, value) {
      result[DateTime.parse(key)] = [
        TaskStatus.values
            .firstWhere((e) => e.toString() == reformatOld(value[0])),
        value[1]
      ];
    });
    return result;
  }

  // To be compatible with older version backup
  static String reformatOld(String value) {
    var all = value.split('.');
    return "${all[0]}.${all[1].toLowerCase()}";
  }

  void navigateToEditPage(context) {
    Provider.of<AppStateManager>(context, listen: false).goEditHabit(habitData);
  }

  @override
  State<Habit> createState() => HabitState();
}

class HabitState extends State<Habit> {
  final bool _orangeStreak = false;
  bool _streakVisible = false;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  // bool _showMonth = false;
  String _actualMonth = "";
  // bool hourly = false;
  // DateTime _focusedHour = DateTime.now();
  DateTime _selectedHour = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  DateTime _firstVisibleDay = DateTime.now();
  DateTime _lastVisibleDay = DateTime.now();

  List<TimeOfDay> _allHoursOfDay = [];
  List<TimeOfDay> get allHoursOfDay => _allHoursOfDay;

  void refresh() {
    setState(() {
      _updateLastStreak();
    });
  }

  void update() {
    setState(() {});
  }

  // void refreshDailyState(date) {
  //   setState(() {
  //     _checkDailyState(date);
  //   });
  // }

  @override
  void initState() {
    super.initState();
    _getEvents(_firstVisibleDay, _lastVisibleDay);
    _generateHoursOfDay();
    _updateLastStreak();
    reloadMonth(_selectedDay);
    reloadRange(_selectedDay, CalendarFormat.week);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Map<DateTime, List> get events {
    return widget.habitData.events;
  }

  void _generateHoursOfDay() {
    allHoursOfDay.clear();
    _allHoursOfDay =
        List.generate(24, (index) => TimeOfDay(hour: index, minute: 0));
  }

  List _getEventsForDay(DateTime day) {
    return widget.habitData.events[transformDate(day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setSelectedDay(selectedDay);
  }

  setSelectedDay(DateTime selectedDay) async{
    await _getEvents(_firstVisibleDay, _lastVisibleDay);
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = selectedDay;
        reloadMonth(selectedDay);
      });
    }
  }

  // void _onHourSelected(DateTime selectedHour, DateTime focusedHour) {
  //   setSelectedHour(selectedHour);
  // }

  setSelectedHour(DateTime selectedHour) {
    if (!isSameHour(_selectedHour, selectedHour)) {
      setState(() {
        _selectedHour = selectedHour;
        // _focusedHour = selectedHour;
      });
    }
  }

  reloadMonth(DateTime selectedDay) {
    // _sfhowMonth = (_calendarFormat == CalendarFormat.month);
    _actualMonth = "${months[selectedDay.month]} ${selectedDay.year}";
  }

  _onFormatChanged(CalendarFormat format) {
    if (_calendarFormat != format) {
      setState(() {
        _calendarFormat = format;
        reloadMonth(_selectedDay);
        reloadRange(_selectedDay, format);
      });
    }
  }

  reloadRange(DateTime selectedDay, CalendarFormat format) {
    selectedDay =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    if (format == CalendarFormat.month) {
      final first = _firstDayOfMonth(selectedDay);
      final daysBefore = _getDaysBefore(first);
      _firstVisibleDay = first.subtract(Duration(days: daysBefore));

      final last = _lastDayOfMonth(selectedDay);
      final daysAfter = _getDaysAfter(last);
      _lastVisibleDay = last.add(Duration(days: daysAfter));
      return;
    }

    if (format == CalendarFormat.week) {
      final daysBefore = _getDaysBefore(selectedDay);
      _firstVisibleDay = selectedDay.subtract(Duration(days: daysBefore));
      _lastVisibleDay = _firstVisibleDay.add(const Duration(days: 7));
      return;
    }
  }

  DateTime _firstDayOfMonth(DateTime month) {
    return DateTime.utc(month.year, month.month, 1);
  }

  DateTime _lastDayOfMonth(DateTime month) {
    final date = month.month < 12
        ? DateTime.utc(month.year, month.month + 1, 1)
        : DateTime.utc(month.year + 1, 1, 1);
    return date.subtract(const Duration(days: 1));
  }

  int _getDaysBefore(DateTime firstDay) {
    return (firstDay.weekday + 7 - getWeekdayNumber(StartingDayOfWeek.monday)) %
        7;
  }

  int _getDaysAfter(DateTime lastDay) {
    int invertedStartingWeekday =
        8 - getWeekdayNumber(StartingDayOfWeek.monday);

    int daysAfter = 7 - ((lastDay.weekday + invertedStartingWeekday) % 7);
    if (daysAfter == 7) {
      daysAfter = 0;
    }
    return daysAfter;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            HabitHeader(
              widget: widget,
              streakVisible: _streakVisible,
              orangeStreak: _orangeStreak,
              streak: widget.habitData.streak,
            ),
            if (Provider.of<SettingsManager>(context).getShowMonthName)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(_actualMonth),
              ),
            widget.habitData.hourly
                ? Center(
                    child: SizedBox(
                      height: 100,
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: allHoursOfDay.length,
                        itemBuilder: (context, index) {
                          // return Container(child: Text("$index"));
                          var currentHour = transformDateWithHour(DateTime(
                              _selectedDay.year,
                              _selectedDay.month,
                              _selectedDay.day,
                              index,
                              30));
                          var event = events[currentHour];
                          return OneHourButton(
                            date: DateTime(
                                _selectedDay.year,
                                _selectedDay.month,
                                _selectedDay.day,
                                index,
                                30),
                            id: widget.habitData.id!,
                            parent: this,
                            callback: _checkDailyStateRefresh,
                            event: events[transformDateWithHour(DateTime(
                                _selectedDay.year,
                                _selectedDay.month,
                                _selectedDay.day,
                                index,
                                30))],
                            // changeController: _controller,
                          );
                        },
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                          childAspectRatio: 1.5,
                        ),
                      ),
                    ),
                  )
                : Container(),
            FutureBuilder<void>(
                // future: _getEvents(_firstVisibleDay, _lastVisibleDay),
                builder: (context, snapshot) {
                  // if (!snapshot.) {
                  //   return const
                  //   Center(
                  //     child: SizedBox(
                  //     height: 100.0,
                  //     width: 100.0,
                  //     child: Center(child: CircularProgressIndicator()),
                  //     )
                  //   );
                  // }
                  // var events = snapshot.data!;
                  return TableCalendar(
                      focusedDay: _focusedDay,
                      // selectedColor: Colors.red,
                      firstDay: DateTime(2000),
                      lastDay: DateTime.now(),
                      headerVisible: false,
                      currentDay: DateTime.now(),
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Month',
                        CalendarFormat.week: 'Week'
                      },
                      selectedDayPredicate: (date) =>
                          isSameDay(date, _selectedDay),
                      // calendarStyle: CalendarStyle(
                      //     todayDecoration: BoxDecoration(
                      //         borderRadius: BorderRadius.circular(10),
                      //         border: Border.all(
                      //             strokeAlign: BorderSide.strokeAlignCenter,
                      //             width: 8,
                      //             color: Colors.blue.shade900)
                      //         // )
                      //         ), selectedDecoration:
                      //           BoxDecoration(
                      //             shape: BoxShape.rectangle,
                      //             borderRadius: BorderRadius.circular(10),
                      //             color: Theme.of(context).colorScheme.primaryContainer
                      //           ),
                      //           selectedTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),

                      //       ),
                      // selectedDayPredicate: ((day) => isSameDay(day, _selectedDay)),
                      eventLoader: _getEventsForDay,
                      calendarFormat: _calendarFormat,
                      daysOfWeekVisible: false,
                      onFormatChanged: _onFormatChanged,
                      onPageChanged: setSelectedDay,
                      onDaySelected: _onDaySelected,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      calendarBuilders: (widget.habitData.hourly)
                          ? hourlyCalendarBuilder(context)
                          : dailyCalendarBuilder(context));
                })
          ],
        ),
      ),
    );
  }

  CalendarBuilders dailyCalendarBuilder(context) {
    return CalendarBuilders(
      defaultBuilder: (context, date, _) {
        return OneDayButton(
          callback: refresh,
          parent: this,
          id: widget.habitData.id!,
          date: date,
          color: Theme.of(context).colorScheme.primaryContainer,
          event: widget.habitData.events[transformDate(date)],
        );
      },
      todayBuilder: (context, date, _) {
        return OneDayButton(
          callback: refresh,
          parent: this,
          id: widget.habitData.id!,
          date: date,
          color: Theme.of(context).colorScheme.primaryContainer,
          event: widget.habitData.events[transformDate(date)],
        );
      },
      disabledBuilder: (context, date, _) {
        return OneDay(
          date: date,
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Text(
            date.day.toString(),
            style:
                TextStyle(color: (date.weekday > 5) ? Colors.red[300] : null),
          ),
        );
      },
      outsideBuilder: (context, date, _) {
        return OneDay(
          date: date,
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Text(
            date.day.toString(),
            style:
                TextStyle(color: (date.weekday > 5) ? Colors.red[300] : null),
          ),
        );
      },
      markerBuilder: (context, date, events) {
        if (events.isNotEmpty) {
          return _buildEventsMarkerHourly(date, events);
        } else {
          return null;
        }
      },
    );
  }

  CalendarBuilders hourlyCalendarBuilder(context) {
    return CalendarBuilders(
      defaultBuilder: (context, date, _) {
        // _checkDailyState(date);
        return OneDayButtonHourly(
          callback: refresh,
          parent: this,
          // status: _numberOfCompletions(date) > 5
          //     ? TaskStatus.clear
          //     : TaskStatus.fail,
          id: widget.habitData.id!,
          date: date,
          event: widget.habitData.events[transformDate(date)],
        );
      },
      todayBuilder: (context, date, _) {
        return OneDayButtonHourly(
          callback: refresh,
          // status: _numberOfCompletions(date) > 5
          //     ? TaskStatus.clear
          //     : TaskStatus.clear,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              strokeAlign: BorderSide.strokeAlignOutside,
              width: 2,
              color: Colors.grey.shade100,
            ),
            // )
          ),
          parent: this,
          id: widget.habitData.id!,
          date: date,
          event: widget.habitData.events[transformDate(date)],
        );
      },
      disabledBuilder: (context, date, _) {
        return OneDay(
          date: date,
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Text(
            date.day.toString(),
            style:
                TextStyle(color: (date.weekday > 5) ? Colors.red[300] : null),
          ),
        );
      },
      outsideBuilder: (context, date, _) {
        return OneDay(
          date: date,
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Text(
            date.day.toString(),
            style:
                TextStyle(color: (date.weekday > 5) ? Colors.red[300] : null),
          ),
        );
      },
      // singleMarkerBuilder: (context, date, _) {
      //   return isSameDay(date, DateTime.now()) ? Container(
      //     decoration: BoxDecoration(
      //         shape: BoxShape.circle,
      //         color: Colors.red), //Change color
      //     width: 5.0,
      //     height: 5.0,
      //     margin: const EdgeInsets.symmetric(horizontal: 1.5),
      //   ):Container();
      // },
      markerBuilder: (context, date, events) {
        return _buildEventsMarkerHourly(date, events);
      },
    );
  }

  Widget _buildEventsMarkerHourly(DateTime date, List events) {
    _checkDailyState(date);
    int completed = _numberOfCompletions(date);
    return AspectRatio(
        aspectRatio: 1,
        // child: IgnorePointer(
        child: Stack(
            // clipBehavior: Clip.hardEdge,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                margin: const EdgeInsets.all(2.0),
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  // (isSameDay(_selectedDay, transformDate(DateTime.now())) ?
                  // BoxDecoration(
                  //   borderRadius: BorderRadius.circular(10),
                  //   border: Border.all(
                  //   strokeAlign: BorderSide.strokeAlignOutside,
                  //   width: 2,
                  //   color: Colors.grey.shade100,
                  // ),
                  color: (events != null && events.isNotEmpty)
                      ? events[0] == TaskStatus.check
                          ? Provider.of<SettingsManager>(context, listen: false)
                              .checkColor
                          : events[0] == TaskStatus.fail &&
                                  !isSameDay(date, DateTime.now())
                              ? Provider.of<SettingsManager>(context,
                                      listen: false)
                                  .failColor
                              : events[0] == TaskStatus.skip &&
                                      !isSameDay(date, DateTime.now())
                                  ? Provider.of<SettingsManager>(context,
                                          listen: false)
                                      .skipColor
                                  : Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                      : Provider.of<SettingsManager>(context, listen: false)
                          .failColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  "${date.day}",
                  style: isSameDay(date, _selectedDay)
                      ? const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)
                      : const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.normal),
                ),
              ),
              (completed < widget.habitData.targetGoal)
                  ? Container(
                      padding: EdgeInsets.fromLTRB(10, 13, 10, 0),
                      alignment: Alignment.center,
                      child: LinearProgressIndicator(
                        value: completed / widget.habitData.targetGoal,
                        color: Colors.green.shade600,
                        backgroundColor: Colors.grey.shade800,
                      ))
                  : const Padding(
                      padding: EdgeInsets.only(bottom: 14),
                      child: Icon(
                        Icons.check,
                        size: 16,
                      )),
              Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    "$completed/${widget.habitData.targetGoal}",
                    style: const TextStyle(fontSize: 10),
                  )),
            ])
        // ),
        );
  }

  _updateLastStreak() {
    int inStreak = 0;
    DateTime lastDay = transformDate(DateTime.now());
    DateTime checkDay = lastDay;
    // var checkDayKey = widget.habitData.events[today.subtract(const Duration(days: 1))];
    // var lastDayKey = widget.habitData.events[today.subtract(const Duration(days: 1))];
    // bool test = widget.habitData.events.containsKey(transformDate(DateTime.now()));

    while (widget.habitData.events[checkDay] != null &&
        widget.habitData.events[checkDay]![0] != TaskStatus.fail) {
      if (widget.habitData.events[checkDay]![0] != TaskStatus.clear) {
        if (widget.habitData.events[lastDay]![0] != null &&
            widget.habitData.events[lastDay]![0] != TaskStatus.clear &&
            lastDay.difference(checkDay) >= const Duration(days: 1)) break;
        lastDay = checkDay;
      }

      if (widget.habitData.events[checkDay]![0] == TaskStatus.check) {
        inStreak++;
      }
      checkDay = lastDay.subtract(const Duration(days: 1));
    }

    _streakVisible = (inStreak >= 2);

    widget.habitData.streak = inStreak;
  }

  int _numberOfCompletions(DateTime date) {
    int completed = 0;
    // int failed;
    // int skipped;
    for (int i = 0; i < 24; i++) {
      var event = events[transformDateWithHour(
          DateTime(date.year, date.month, date.day, i, 30))];
      if (event != null) {
        if (event[0] == TaskStatus.check) {
          completed += 1;
        }
      }
    }
    debugPrint("date: $date completed: $completed)");
    return completed;
  }

  Future<void> _getEvents(DateTime startDate, DateTime endDate) async {
    if (endDate.isAfter(DateTime.now())) {
      endDate = DateTime.now();
    }
    final hoursToGenerate = endDate.difference(startDate).inHours;
    Map<DateTime, List> eventMap = {};
    int id = widget.habitData.id!;
    List<DateTime> hours = List.generate(
        hoursToGenerate,
        (i) => DateTime(startDate.year, startDate.month, startDate.day,
            startDate.hour + (i), 30));
    for (DateTime hour in hours) {
      if (widget.habitData.events[hour] != null) {
        if (widget.habitData.events[hour]![0] != TaskStatus.fail) {
          continue;
        }
      }
      if (widget.habitData.calEnabled) {
        int cal =
            await _getHealthData(hour, HealthDataType.ACTIVE_ENERGY_BURNED);
        if (cal >= widget.habitData.calTarget) {
          eventMap[hour] = [TaskStatus.fail, cal, 0];
        } else {
          eventMap[hour] = [TaskStatus.fail, cal, 0];
        }
      } else if (widget.habitData.stepsEnabled) {
        int steps = await _getHealthData(hour, HealthDataType.STEPS);
        if (steps >= widget.habitData.stepsTarget) {
          eventMap[hour] = [TaskStatus.check, 0, steps];
        } else {
          eventMap[hour] = [TaskStatus.fail, 0, steps];
        }
      }
      if (context.mounted) {
        Provider.of<HabitsManager>(context, listen: false)
            .addEventBatch(id, eventMap);
      }
    }
  }
  

  Future<int> _getHealthData(DateTime date, HealthDataType type) async {
    HealthFactory health = HealthFactory();
    int sum = 0;
    try {
      List<HealthDataPoint> healthDataPoints = await health
          .getHealthDataFromTypes(
              DateTime(date.year, date.month, date.day, date.hour, 0),
              DateTime(date.year, date.month, date.day, date.hour, 59),
              [type]);
      healthDataPoints = HealthFactory.removeDuplicates(healthDataPoints);
      if (healthDataPoints.isNotEmpty) {
        healthDataPoints.forEach((element) {
          debugPrint("element: ${element.toString()}");
          sum += (element.value as NumericHealthValue).numericValue.toInt();
        });
      }
    } catch (e) {
      debugPrint('ERROR: Loading HealthData failed: $e');
      return 0;
    }
    debugPrint("HealthValues: $sum");
    return sum;
  }

  void _checkDailyState(DateTime date) {
    // DateTime date = _selectedDay;
    TaskStatus selectedDayState = TaskStatus.clear;
    if (widget.habitData.events[date] != null) {
      selectedDayState = widget.habitData.events[date]![0];
    }
    if (_numberOfCompletions(date) >= widget.habitData.targetGoal &&
        selectedDayState != TaskStatus.check) {
      Provider.of<HabitsManager>(context, listen: false)
          .addEvent(widget.habitData.id!, date, [TaskStatus.check, -1, -1]);
      widget.habitData.events[date] = [TaskStatus.check, -1, -1];
    } else if (_numberOfCompletions(date) < widget.habitData.targetGoal &&
        selectedDayState != TaskStatus.fail) {
      Provider.of<HabitsManager>(context, listen: false)
          .addEvent(widget.habitData.id!, date, [TaskStatus.fail, -1, -1]);
      widget.habitData.events[date] = [TaskStatus.fail, -1, -1];
    }
  }

  void _checkDailyStateRefresh(DateTime date) {
    // DateTime date = _selectedDay;
    TaskStatus selectedDayState = TaskStatus.clear;
    if (widget.habitData.events[date] != null) {
      selectedDayState = widget.habitData.events[date]![0];
    }
    if (_numberOfCompletions(date) >= widget.habitData.targetGoal &&
        selectedDayState != TaskStatus.check) {
      Provider.of<HabitsManager>(context, listen: false)
          .addEvent(widget.habitData.id!, date, [TaskStatus.check, -1, -1]);
      widget.habitData.events[date] = [TaskStatus.check, -1, -1];
    } else if (_numberOfCompletions(date) < widget.habitData.targetGoal &&
        selectedDayState != TaskStatus.fail) {
      Provider.of<HabitsManager>(context, listen: false)
          .addEvent(widget.habitData.id!, date, [TaskStatus.fail, -1, -1]);
      widget.habitData.events[date] = [TaskStatus.fail, -1, -1];
    }
    refresh();
  }
}
