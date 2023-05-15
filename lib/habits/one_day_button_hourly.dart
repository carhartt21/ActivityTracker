// import 'package:awesome_dialog/awesome_dialog.dart';
// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:activity_tracker/constants.dart';
import 'package:activity_tracker/habits/habit.dart';
import 'package:activity_tracker/habits/habits_manager.dart';
import 'package:activity_tracker/habits/in_button.dart';
import 'package:activity_tracker/helpers.dart';
import 'package:activity_tracker/settings/settings_manager.dart';
import 'package:provider/provider.dart';

class OneDayButtonHourly extends StatefulWidget {
  OneDayButtonHourly(
      {Key? key,
      required date,
      this.child,
      this.decoration,
      required this.id,
      required this.parent,
      required this.callback,
      required this.event})
      : date = transformDate(date),
        super(key: key);

  final int id;
  final DateTime date;
  final Widget? child;
  final BoxDecoration? decoration;
  final HabitState parent;
  final Function() callback;
  final List? event;

  @override
  State<OneDayButtonHourly> createState() => _OneDayButtonHourlyState();
}

class _OneDayButtonHourlyState extends State<OneDayButtonHourly> {
  @override
  Widget build(BuildContext context) {
    // setState(() {
    //   _checkDailyState(context);
    // });
    return AspectRatio(
      aspectRatio: 1,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(4.0),
          child: Container(
            alignment: Alignment.center,
            decoration: widget.decoration,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  // colo
                  // surfaceTintColor: Colors.red,
                  // foregroundColor: Colors.red,
                  // shadowColor: Theme.of(context).shadowColor,
                  alignment: Alignment.center,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  padding: const EdgeInsets.all(4.0)),
              onPressed: () {
                widget.parent.setSelectedDay(widget.date);
              },
              onLongPress: () {
                // if (status != TaskStatus.clear && status != TaskStatus.fail){
                final RenderBox overlay =
                    Overlay.of(context).context.findRenderObject() as RenderBox;

                final RenderBox button =
                    context.findRenderObject() as RenderBox;

                final RelativeRect position = RelativeRect.fromRect(
                  Rect.fromPoints(
                    button.localToGlobal(const Offset(0, 50),
                        ancestor: overlay),
                    button.localToGlobal(
                        button.size.bottomRight(Offset.zero) +
                            const Offset(0, 0),
                        ancestor: overlay),
                  ),
                  Offset.zero & overlay.size,
                );
                _showContextMenu(context, position, widget.event, widget.callback);                
                widget.callback();
                // }
              },
              child: InButton(
                key: const Key('Date'),
                text: widget.child ??
                    Text(
                      widget.date.day.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            (widget.date.weekday > 5) ? Colors.red[300] : Colors.white,
                        fontSize: 15,
                      ),
                    ),
                ),
            ),
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, position, event, callback) async {
    // final offset = details.globalPosition;
    var result = await showMenu(
        context: context,
        position: position,
        constraints: BoxConstraints.loose(const Size(60, 150)),
        items: [
          PopupMenuItem(
            value: 1,
            key: const Key('Check'),
            child: Icon(
              Icons.check,
              color: Provider.of<SettingsManager>(context, listen: false)
                  .checkColor,
              semanticLabel: 'Check',
            ),
          ),
          PopupMenuItem(
            value: 2,
            key: const Key('Fail'),
            child: Icon(
              Icons.close,
              color: Provider.of<SettingsManager>(context, listen: false)
                  .failColor,
              semanticLabel: 'Fail',
            ),
          ),
          PopupMenuItem(
            value: 3,
            key: const Key('Skip'),
            child: Icon(
              Icons.skip_next,
              color: Provider.of<SettingsManager>(context, listen: false)
                  .skipColor,
              semanticLabel: 'Skip',
            ),
          )
        ]);
    if (result != null) {
      int burnedCalories = 0;
      int steps = 0;

      if (event != null) {
        if (event!.length > 1 && event![1] != null && event![1] != 0) {
          burnedCalories = (event![1]);
        }

        if (event!.length > 1 && event![1] != null && event![1] != 0) {
          steps = (event![1]);
        }
      }
      if (context.mounted) {
        Provider.of<HabitsManager>(context, listen: false).addEvent(
            widget.id, widget.date, [TaskStatus.values[result], burnedCalories, steps]);
      }
      widget.parent.events[widget.date] = [TaskStatus.values[result], burnedCalories, steps];
      // callback();
    }
  }

  // int _numberOfCompletions() {
  //   int completed = 0;
  //   // int failed;
  //   // int skipped;
  //   for (int i = 0; i < 24; i++) {
  //     var event = widget.parent.events[transformDateWithHour(
  //         DateTime(widget.date.year, widget.date.month, widget.date.day, i, 30))];
  //     if (event != null) {
  //       if (event[0] == TaskStatus.check) {
  //         completed += 1;
  //       }
  //     }
  //   }
  //   debugPrint("date: ${widget.date} completed: $completed)");
  //   return completed;
  // }

  // void _checkDailyState(BuildContext context) {
  //   if (_numberOfCompletions() >= widget.targetGoal) {
  //     Provider.of<HabitsManager>(context)
  //         .addEvent(widget.id, widget.date, [TaskStatus.check, -1, -1]);
  //     widget.parent.events[widget.date] = [TaskStatus.check, -1, -1];
  //     debugPrint('check');
  //   }
  //   else if (_numberOfCompletions() < widget.targetGoal) {
  //     Provider.of<HabitsManager>(context)
  //         .addEvent(widget.id, widget.date, [TaskStatus.fail, -1, -1]);
  //     widget.parent.events[widget.date] = [TaskStatus.fail, -1, -1];
  //     debugPrint('fail');
  //   }
  // }
}
