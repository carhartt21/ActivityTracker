// import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:ActivityTracker/constants.dart';
import 'package:ActivityTracker/habits/habit.dart';
import 'package:ActivityTracker/habits/habits_manager.dart';
import 'package:ActivityTracker/habits/in_button.dart';
import 'package:ActivityTracker/helpers.dart';
import 'package:ActivityTracker/settings/settings_manager.dart';
import 'package:provider/provider.dart';

class OneDayButton extends StatelessWidget {
  OneDayButton(
      {Key? key,
      required date,
      this.color,
      this.child,
      required this.id,
      required this.parent,
      required this.callback,
      required this.event})
      : date = transformDate(date),
        super(key: key);

  final int id;
  final DateTime date;
  final Color? color;
  final Widget? child;
  final HabitState parent;
  final void Function() callback;
  final List? event;

  @override
  Widget build(BuildContext context) {
    List<InButton> icons = [
      InButton(
        key: const Key('Date'),
        text: child ??
            Text(
              date.day.toString(),
              style:
                  TextStyle(color: (date.weekday > 5) ? Colors.red[300] : null),
              textAlign: TextAlign.center,
            ),
      ),
      InButton(
        key: const Key('Check'),
        icon: Icon(
          Icons.check,
          color:
              Provider.of<SettingsManager>(context, listen: false).checkColor,
          semanticLabel: 'Check',
        ),
      ),
      InButton(
        key: const Key('Fail'),
        icon: Icon(
          Icons.close,
          color: Provider.of<SettingsManager>(context, listen: false).failColor,
          semanticLabel: 'Fail',
        ),
      ),
      InButton(
        key: const Key('Skip'),
        icon: Icon(
          Icons.last_page,
          color: Provider.of<SettingsManager>(context, listen: false).skipColor,
          semanticLabel: 'Skip',
        ),
      ),
    ];

    int index = 0;
    int burnedCalories = 0;
    int steps = 0;


    if (event != null) {
      if (event![0] != 0) {
        index = (event![0].index);
      }

      if (event!.length > 1 && event![1] != null && event![1] != 0) {
        burnedCalories = (event![1]);
      }

      if (event!.length > 1 && event![1] != null && event![1] != 0) {
        steps = (event![1]);
      }
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(4.0),
          child: Material(
            color: color,
            borderRadius: BorderRadius.circular(10.0),
            elevation: 2,
            shadowColor: Theme.of(context).shadowColor,
            child: Container(
              alignment: Alignment.center,
              // child: PopupMenuButton<InButton>(
              //   itemBuilder: ,)
              // child: ElevatedButton<InButton>(
              //   onPressed: () {
              //     parent.setSelectedDay(date);
              //   },
              //   onLongPress: () => _showContextMenu(context),)
              child: DropdownButton<InButton>(
                
                iconSize: 0,
                elevation: 3,
                alignment: Alignment.center,
                dropdownColor: Theme.of(context).colorScheme.primaryContainer,
                underline: Container(),
                items: icons.map(
                  (InButton value) {
                    return DropdownMenuItem<InButton>(
                      key: value.key,
                      value: value,
                      child: Center(child: value),
                    );
                  },
                ).toList(),
                value: icons[index],
                onTap: () {
                  parent.setSelectedDay(date);
                },
                onChanged: (value) {
                  if (value != null) {
                    if (value.key == const Key('Check') ||
                        value.key == const Key('Fail') ||
                        value.key == const Key('Skip')) {
                      Provider.of<HabitsManager>(context, listen: false)
                          .addEvent(id, date, [
                        TaskStatus.values[icons
                            .indexWhere((element) => element.key == value.key)],
                        burnedCalories, steps
                      ]);
                      parent.events[date] = [
                        TaskStatus.values[icons
                            .indexWhere((element) => element.key == value.key)],
                        burnedCalories, steps
                      ];
                      // if (value.key == const Key('Check')) {
                      //   Provider.of<SettingsManager>(context, listen: false)
                      //       .playCheckSound();
                      // } else {
                      //   Provider.of<SettingsManager>(context, listen: false)
                      //       .playClickSound();
                      // }
                    // } else if (value.key == const Key('Comment')) {
                    //   showCommentDialog(context, index, comment);
                    }
                    // callback();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // void _showContextMenu(BuildContext context) async {
  //   final RenderObject? overlay =
  //       Overlay.of(context)?.context.findRenderObject();

  //   final result = await showMenu(
  //       context: context,
  //       position: RelativeRect.fromRect(const Rect.fromLTWH(0, 0, 30, 30)),
  //       // Show the context menu at the tap location

  //       // set a list of choices for the context menu
  //       items: [
  //         const PopupMenuItem(
  //           value: 'favorites',
  //           child: Text('Add To Favorites'),
  //         ),
  //         const PopupMenuItem(
  //           value: 'comment',
  //           child: Text('Write Comment'),
  //         ),
  //         const PopupMenuItem(
  //           value: 'hide',
  //           child: Text('Hide'),
  //         ),
  //       ]);

  //   // Implement the logic for each choice here
  //   switch (result) {
  //     case 'favorites':
  //       debugPrint('Add To Favorites');
  //       break;
  //     case 'comment':
  //       debugPrint('Write Comment');
  //       break;
  //     case 'hide':
  //       debugPrint('Hide');
  //       break;
  //   }
  // }

  // showCommentDialog(BuildContext context, int index, String comment) {
  //   TextEditingController commentController =
  //       TextEditingController(text: comment);
  //   AwesomeDialog(
  //     context: context,
  //     dialogType: DialogType.noHeader,
  //     animType: AnimType.bottomSlide,
  //     body: Center(
  //       child: Padding(
  //         padding: const EdgeInsets.symmetric(
  //           vertical: 8.0,
  //           horizontal: 10.0,
  //         ),
  //         child: Column(
  //           children: [
  //             const Text("Comment"),
  //             TextField(
  //               controller: commentController,
  //               autofocus: true,
  //               maxLines: 5,
  //               showCursor: true,
  //               textAlignVertical: TextAlignVertical.bottom,
  //               decoration: const InputDecoration(
  //                 contentPadding: EdgeInsets.all(11),
  //                 border: InputBorder.none,
  //                 hintText: "Your comment here",
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //     btnOkText: "Save",
  //     btnCancelText: "Close",
  //     btnCancelColor: Colors.grey,
  //     btnOkColor: ActivityTrackerColors.primary,
  //     btnCancelOnPress: () {},
  //     btnOkOnPress: () {
  //       Provider.of<HabitsManager>(context, listen: false).addEvent(
  //           id, date, [TaskStatus.values[index], commentController.text]);
  //       parent.events[date] = [TaskStatus.values[index], commentController.text];
  //       callback();
  //     },
  //   ).show();
  // }
}
