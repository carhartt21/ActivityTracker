import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:ActivityTracker/constants.dart';
import 'package:provider/provider.dart';
import 'package:ActivityTracker/habits/calendar_column.dart';
import 'package:ActivityTracker/habits/habits_manager.dart';
import 'package:ActivityTracker/settings/settings_manager.dart';
import 'package:ActivityTracker/navigation/navigation.dart';
import 'package:ActivityTracker/health/health.dart';

class HabitsScreen extends StatefulWidget {
  static MaterialPage page() {
    return MaterialPage(
      name: Routes.habitsPath,
      key: ValueKey(Routes.habitsPath),
      child: const HabitsScreen(),
    );
  }

  const HabitsScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 0), () async {
      showNotificationDialog(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateManager>(
      builder: (
        context,
        appStateManager,
        child,
      ) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "ActivityTracker",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            backgroundColor: Colors.transparent,
            actions: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.bar_chart,
                  semanticLabel: 'Statistics',
                ),
                color: Colors.grey[400],
                tooltip: 'Statistics',
                onPressed: () {
                  Provider.of<HabitsManager>(context, listen: false)
                      .hideSnackBar();
                  Provider.of<AppStateManager>(context, listen: false)
                      .goStatistics(true);
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.settings,
                  semanticLabel: 'Settings',
                ),
                color: Colors.grey[400],
                tooltip: 'Settings',
                onPressed: () {
                  Provider.of<AppStateManager>(context, listen: false)
                      .goSettings(true);
                  Provider.of<HabitsManager>(context, listen: false)
                      .hideSnackBar();
                },
              ),
              const HealthApp(),
            ],
          ),
          body: 
          const CalendarColumn(),
          floatingActionButton: FloatingActionButton(
              onPressed: () {
                Provider.of<AppStateManager>(context, listen: false)
                    .goCreateHabit(true);
                Provider.of<HabitsManager>(context, listen: false).hideSnackBar();
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
                semanticLabel: 'Add',
                size: 35.0,
            ),
          ),
        );
      },
    );
  }

  void resetDailyState(){
    
  }

  void showNotificationDialog(BuildContext context) {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        showRestoreDialog(context);
      } else {
        resetNotifications();
      }
    });
  }

  void showRestoreDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: "Notifications",
      desc: "ActivityTracker needs permission to send notifications to work properly.",
      btnOkText: "Allow",
      btnCancelText: "Cancel",
      btnCancelColor: Colors.grey,
      btnOkColor: ActivityTrackerColors.primary,
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        AwesomeNotifications()
            .requestPermissionToSendNotifications()
            .then((value) {
          resetNotifications();
        });
      },
    ).show();
  }

  void resetNotifications() {
    Provider.of<SettingsManager>(context, listen: false).resetAppNotification();
    Provider.of<HabitsManager>(context, listen: false)
        .resetHabitsNotifications();
  }
}
