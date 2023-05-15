import 'package:flutter/material.dart';
// import 'package:ActivityTracker/habits/calendar_header.dart';
import 'package:ActivityTracker/habits/empty_list_image.dart';
import 'package:ActivityTracker/habits/habit.dart';
import 'package:ActivityTracker/habits/habits_manager.dart';
import 'package:ActivityTracker/habits/one_hour_button.dart';
import 'package:provider/provider.dart';

class CalendarColumn extends StatelessWidget {
  const CalendarColumn({super.key});

  @override
  Widget build(BuildContext context) {
    List<Habit> calendars = Provider.of<HabitsManager>(context).getAllHabits;
    // List<DateTime> hoursAM = List<DateTime>.generate(12, (index) => DateTime.now());

    return Column(
      children: <Widget>[
        // SizedBox(
        //   height: 50,
        //   child: GridView.builder(
        //     physics: gridScrollPhysics ?? const BouncingScrollPhysics(),
        //     itemCount: controller.allBookingSlots.length,
        //     itemBuilder: (context, index) {
        //       TextStyle? getTextStyle() {
        //         if (controller.isSlotBooked(index)) {
        //           return widget.bookedSlotTextStyle;
        //         } else if (index == controller.selectedSlot) {
        //           return widget.selectedSlotTextStyle;
        //         } else {
        //           return widget.availableSlotTextStyle;
        //         }
        //       }

        //       return Container(child: Text('Test'));
                // hideBreakSlot: widget.hideBreakTime,
                // pauseSlotColor: widget.pauseSlotColor,
                // availableSlotColor: widget.availableSlotColor,
                // bookedSlotColor: widget.bookedSlotColor,
                // selectedSlotColor: widget.selectedSlotColor,
                // isPauseTime: controller.isSlotInPauseTime(slot),
                // isBooked: controller.isSlotBooked(index),
                // isSelected: index == controller.selectedSlot,
                // onTap: () => controller.selectSlot(index),
                // child: Center(
                //   child: Text(
                //     widget.formatDateTime?.call(slot) ??
                //         BookingUtil.formatDateTime(slot),
                //     style: getTextStyle(),
                //   ),
                // ),
              // );
        //     },
        //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //       crossAxisCount: widget.bookingGridCrossAxisCount ?? 3,
        //       childAspectRatio: widget.bookingGridChildAspectRatio ?? 1.5,
        //     ),
        //   ),
        // ),
        Expanded(
          child: (calendars.isNotEmpty)
              ? ReorderableListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
                  children: calendars
                      .map(
                        (index) => Container(
                          key: ObjectKey(index),
                          child: index,
                        ),
                      )
                      .toList(),
                  onReorder: (oldIndex, newIndex) {
                    Provider.of<HabitsManager>(context, listen: false)
                        .reorderList(oldIndex, newIndex);
                  },
                )
              : const EmptyListImage(),
        ),
      ],
    );
  }
}
