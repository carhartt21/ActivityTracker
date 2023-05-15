// import 'dart:collection';

// import 'package:flutter/material.dart';
// import 'package:habo/constants.dart';
// import 'package:habo/habits/habit_header.dart';
// import 'package:habo/habits/one_hour_button.dart';
// import 'package:habo/helpers.dart';
// import 'package:habo/model/habit_data.dart';
// import 'package:habo/navigation/app_state_manager.dart';
// import 'package:habo/settings/settings_manager.dart';
// import 'package:provider/provider.dart';
// import 'package:table_calendar/table_calendar.dart';

// import 'one_day.dart';
// import 'one_day_button.dart';

// class HabitHourly extends StatefulWidget {
//   const HabitHourly({super.key, required this.habitData});

//   final HabitData habitData;

//   set setId(int input) {
//     habitData.id = input;
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       "id": habitData.id,
//       "title": habitData.title,
//       "position": habitData.position,
//       "notification": habitData.notification ? 1 : 0,
//       "hourly": habitData.hourly ? 1 : 0,
//       "notTime": "${habitData.notTime.hour}:${habitData.notTime.minute}",
//       "routine": habitData.routine,
//       "caloriesEnabled": habitData.caloriesEnabled ? 1 : 0,
//       "calories": "${habitData.calories}",
//       "stepsEnabled": habitData.stepsEnabled ? 1 : 0,
//       "steps": "${habitData.steps}",      
//     };
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "id": habitData.id,
//       "title": habitData.title,
//       "position": habitData.position,
//       "notification": habitData.notification ? 1 : 0,
//       "notTime": "${habitData.notTime.hour}:${habitData.notTime.minute}",
//       "hourly": habitData.hourly ? 1 : 0,
//       "routine": habitData.routine,
//       "caloriesEnabled": habitData.caloriesEnabled ? 1 : 0,
//       "calories": "${habitData.calories}",
//       "stepsEnabled": habitData.stepsEnabled ? 1 : 0,      
//       "steps": "${habitData.steps}",
//       "events": habitData.events.map((key, value) {
//         return MapEntry(key.toString(), [value[0].toString(), value[1]]);
//       }),
//     };
//   }

//   HabitHourly.fromJson(Map<String, dynamic> json, {super.key})
//       : habitData = HabitData(
//           id: json['id'],
//           position: json['position'],
//           title: json['title'],
//           routine: json['routine'],
//           notification: json['notification'] != 0 ? true : false,
//           hourly: json['hourly'] != 0 ? true : false,
//           notTime: parseTimeOfDay(json['notTime']),
//           events: doEvents(json['events']),
//           caloriesEnabled: json['caloriesEnabled'] != 0 ? true : false,
//           calories: json['calories'],
//           stepsEnabled: json['stepsEnabled'] != 0 ? true : false,    
//           steps: json['steps'],
//         );

//   static SplayTreeMap<DateTime, List> doEvents(Map<String, dynamic> input) {
//     SplayTreeMap<DateTime, List> result = SplayTreeMap<DateTime, List>();

//     input.forEach((key, value) {
//       result[DateTime.parse(key)] = [
//         TaskStatus.values.firstWhere((e) => e.toString() == reformatOld(value[0])),
//         value[1]
//       ];
//     });
//     return result;
//   }

//   // To be compatible with older version backup
//   static String reformatOld(String value) {
//     var all = value.split('.');
//     return "${all[0]}.${all[1].toLowerCase()}";
//   }

//   void navigateToEditPage(context) {
//     Provider.of<AppStateManager>(context, listen: false).goEditHabit(habitData);
//   }

//   @override
//   State<HabitHourly> createState() => HabitStateHourly();
// }

// class HabitStateHourly extends State<HabitHourly> {
//   final bool _orangeStreak = false;
//   bool _streakVisible = false;
//   CalendarFormat _calendarFormat = CalendarFormat.week;
//   bool _showMonth = false;
//   String _actualMonth = "";
//   bool hourly = false;
//   DateTime _focusedHour = DateTime.now();
//   DateTime _selectedHour = DateTime.now();
//   DateTime _focusedDay = DateTime.now();
//   DateTime _selectedDay = DateTime.now();

//   void refresh() {
//     setState(() {
//       _updateLastStreak();
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _updateLastStreak();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   SplayTreeMap<DateTime, List> get events {
//     return widget.habitData.events;
//   }


//   List _getEventsForDay(DateTime day) {
//     return widget.habitData.events[transformDateWithHour(day)] ?? [];
//   }

//   void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
//     setSelectedDay(selectedDay);
//   }

//   setSelectedDay(DateTime selectedDay) {
//     if (!isSameDay(_selectedDay, selectedDay)) {
//       setState(() {
//         _selectedDay = selectedDay;
//         _focusedDay = selectedDay;
//         reloadMonth(selectedDay);
//       });
//     }
//   }

//   void _onHourSelected(DateTime selectedHour, DateTime focusedHour) {
//     setSelectedHour(selectedHour);
//   }

//   setSelectedHour(DateTime selectedHour) {
//     if (!isSameHour(_selectedHour, selectedHour)) {
//       setState(() {
//         _selectedHour = selectedHour;
//         _focusedHour = selectedHour;
//       });
//     }
//   }

//   reloadMonth(DateTime selectedDay) {
//     _showMonth = (_calendarFormat == CalendarFormat.month);
//     _actualMonth = "${months[selectedDay.month]} ${selectedDay.year}";
//   }

//   _onFormatChanged(CalendarFormat format) {
//     if (_calendarFormat != format) {
//       setState(() {
//         _calendarFormat = format;
//         reloadMonth(_selectedDay);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             HabitHeader(
//               widget: widget,
//               streakVisible: _streakVisible,
//               orangeStreak: _orangeStreak,
//               streak: widget.habitData.streak,
//             ),
//             // if (_showMonth &&
//             //     Provider.of<SettingsManager>(context).getShowMonthName)
//             //   Padding(
//             //     padding: const EdgeInsets.symmetric(horizontal: 4.0),
//             //     child: Text(_actualMonth),
//             //   ),
//             // Center(
//             //   child: SizedBox(
//             //     height: 100,
//             //     child: GridView.builder(
//             //       physics: const BouncingScrollPhysics(),
//             //       itemCount: 24,
//             //       itemBuilder: (context, index) {
//             //         return OneHourButton(
//             //           date: DateTime.now, 
//             //           id: widget.habitData.id!, 
//             //           parent: this, 
//             //           callback: refresh, 
//             //           event: null,
//             //           );
//             //       },
//             //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             //         crossAxisCount: 8,
//             //         childAspectRatio: 1.5,
//             //       ),
//             //     ),
//             //   ),  
//             // ),
//             TableCalendar(
//               focusedDay: _focusedDay,
//               firstDay: DateTime(2000),
//               lastDay: DateTime.now(),
//               headerVisible: false,
//               currentDay: DateTime.now(),
//               availableCalendarFormats: const {
//                 CalendarFormat.month: 'Month',
//                 CalendarFormat.week: 'Week'
//               },
//               eventLoader: _getEventsForDay,
//               calendarFormat: _calendarFormat,
//               daysOfWeekVisible: false,
//               onFormatChanged: _onFormatChanged,
//               onPageChanged: setSelectedDay,
//               onDaySelected: _onDaySelected,
//               startingDayOfWeek: StartingDayOfWeek.monday,
//               calendarBuilders: CalendarBuilders(
//                 defaultBuilder: (context, date, _) {
//                   return OneDayButton(
//                     callback: refresh,
//                     parent: this,
//                     id: widget.habitData.id!,
//                     date: date,
//                     color: Theme.of(context).colorScheme.primaryContainer,
//                     event: widget.habitData.events[transformDate(date)],
//                   );
//                 },
//                 todayBuilder: (context, date, _) {
//                   return OneDayButton(
//                     callback: refresh,
//                     parent: this,
//                     id: widget.habitData.id!,
//                     date: date,
//                     color: Theme.of(context).colorScheme.primaryContainer,
//                     event: widget.habitData.events[transformDate(date)],
//                   );
//                 },
//                 disabledBuilder: (context, date, _) {
//                   return OneDay(
//                     date: date,
//                     color: Theme.of(context).colorScheme.secondaryContainer,
//                     child: Text(
//                       date.day.toString(),
//                       style: TextStyle(
//                           color: (date.weekday > 5) ? Colors.red[300] : null),
//                     ),
//                   );
//                 },
//                 outsideBuilder: (context, date, _) {
//                   return OneDay(
//                     date: date,
//                     color: Theme.of(context).colorScheme.secondaryContainer,
//                     child: Text(
//                       date.day.toString(),
//                       style: TextStyle(
//                           color: (date.weekday > 5) ? Colors.red[300] : null),
//                     ),
//                   );
//                 },
//                 markerBuilder: (context, date, events) {
//                   if (events.isNotEmpty) {
//                     return _buildEventsMarker(date, events);
//                   } else {
//                     return null;
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEventsMarker(DateTime date, List events) {
//     return AspectRatio(
//       aspectRatio: 1,
//       child: IgnorePointer(
//         child: Stack(children: [
//           (events[0] != TaskStatus.clear)
//               ? Container(
//                   margin: const EdgeInsets.all(4.0),
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     color: events[0] == TaskStatus.check
//                         ? Provider.of<SettingsManager>(context, listen: false)
//                             .checkColor
//                         : events[0] == TaskStatus.fail
//                             ? Provider.of<SettingsManager>(context,
//                                     listen: false)
//                                 .failColor
//                             : Provider.of<SettingsManager>(context,
//                                     listen: false)
//                                 .skipColor,
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   child: events[0] == TaskStatus.check
//                       ? const Icon(
//                           Icons.check,
//                           color: Colors.white,
//                         )
//                       : events[0] == TaskStatus.fail
//                           ? const Icon(
//                               Icons.close,
//                               color: Colors.white,
//                             )
//                           : const Icon(
//                               Icons.last_page,
//                               color: Colors.white,
//                             ),
//                 )
//               : Container(),
//           (events[1] != null && events[1] != "")
//               ? Container(
//                   alignment: const Alignment(1.0, 1.0),
//                   padding: const EdgeInsets.fromLTRB(0, 0, 5.0, 2.0),
//                   child: Material(
//                     borderRadius: BorderRadius.circular(15.0),
//                     elevation: 1,
//                     child: Container(
//                       width: 8,
//                       height: 8,
//                       decoration: const BoxDecoration(
//                         color: HaboColors.orange,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   ),
//                 )
//               : Container(),
//         ]),
//       ),
//     );
//   }


//   _updateLastStreak() {
//     int inStreak = 0;
//     var checkDayKey = widget.habitData.events.lastKey();
//     var lastDayKey = widget.habitData.events.lastKey();

//     while (widget.habitData.events[checkDayKey] != null &&
//         widget.habitData.events[checkDayKey]![0] != TaskStatus.fail) {
//       if (widget.habitData.events[checkDayKey]![0] != TaskStatus.clear) {
//         if (widget.habitData.events[lastDayKey]![0] != null &&
//             widget.habitData.events[lastDayKey]![0] != TaskStatus.clear &&
//             lastDayKey!.difference(checkDayKey!).inDays > 1) break;
//         lastDayKey = checkDayKey;
//       }

//       if (widget.habitData.events[checkDayKey]![0] == TaskStatus.check) inStreak++;
//       checkDayKey = widget.habitData.events.lastKeyBefore(checkDayKey!);
//     }

//     _streakVisible = (inStreak >= 2);

//     widget.habitData.streak = inStreak;
//   }
// }
