import 'package:flutter/material.dart';
import 'package:activity_tracker/constants.dart';
import 'package:provider/provider.dart';
import 'package:activity_tracker/settings/settings_manager.dart';


class EventsMarker extends StatelessWidget {
  const EventsMarker({
    Key? key,
    required this.date,
    required this.selectedDay,
    required this.events,
    this.child,
  }) : super(key: key);

  final DateTime date;
  final DateTime selectedDay;
  final List<dynamic> events;
  // final Color color;
  final Widget? child;

  @override
  Widget build(context) {
    return AspectRatio(
      aspectRatio: 1,
      child: IgnorePointer(
        // child: Stack(children: [
        child: (events[0] != TaskStatus.clear)
            ? Container(
                margin: const EdgeInsets.all(4.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: events[0] == TaskStatus.check
                      ? Provider.of<SettingsManager>(context, listen: false)
                          .checkColor
                      : events[0] == TaskStatus.fail &&
                              !isSameDay(date, DateTime.now())
                          ? Provider.of<SettingsManager>(context, listen: false)
                              .failColor
                          : events[0] == TaskStatus.skip &&
                                  !isSameDay(date, DateTime.now())
                              ? Provider.of<SettingsManager>(context,
                                      listen: false)
                                  .skipColor
                              : Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  "${date.day}",
                  style: isSameDay(date, selectedDay)
                      ? const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)
                      : const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.normal),
                ),
              )
            : Container(),
      ),
    );
  }
}

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }

  return a.year == b.year && a.month == b.month && a.day == b.day;
}
