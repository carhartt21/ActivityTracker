// import 'dart:ffi';

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ActivityTracker/constants.dart';
import 'package:ActivityTracker/habits/habits_manager.dart';
import 'package:ActivityTracker/model/habit_data.dart';
import 'package:ActivityTracker/navigation/routes.dart';
import 'package:ActivityTracker/widgets/text_container.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';


class EditHabitScreen extends StatefulWidget {
  static MaterialPage page(HabitData? data) {
    return MaterialPage(
      name: (data != null) ? Routes.editHabitPath : Routes.createHabitPath,
      key: (data != null)
          ? ValueKey(Routes.editHabitPath)
          : ValueKey(Routes.createHabitPath),
      child: EditHabitScreen(habitData: data),
    );
  }

  const EditHabitScreen({Key? key, required this.habitData}) : super(key: key);

  final HabitData? habitData;

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  TextEditingController title = TextEditingController();
  TextEditingController calories = TextEditingController(text: "0");
  TextEditingController hour = TextEditingController(text: "12");
  TextEditingController minute = TextEditingController(text: "0");
  TextEditingController routine = TextEditingController();
  TextEditingController steps = TextEditingController(text: "0");
  List<TimeOfDay> notTimes = List.generate(1, (index) => const TimeOfDay(hour: 12, minute: 00));
  bool stepsEnabled= false;
  bool calEnabled= false;
  bool hourly = false;
  bool notification = false;
  int targetGoal = 0;


  List<TimeOfDay> _allHoursOfDay = [];
  List<TimeOfDay> get allHoursOfDay => _allHoursOfDay;

  Future<void> setNotificationTime(context) async {
    TimeOfDay? selectedTime;
    TimeOfDay initialTime = notTimes[0];
    selectedTime =
        await showTimePicker(context: context, initialTime: initialTime, initialEntryMode: TimePickerEntryMode.inputOnly, builder: (context, childWidget) {
          return MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), 
              child: childWidget ?? Container()
              );
             },
          );
    if (selectedTime != null) {
      setState(() {
        notTimes[0] = selectedTime!;
        if (notTimes.length > 1){
          for (int i = 0; i < notTimes.length; i++){
            notTimes[i] = TimeOfDay(hour: notTimes[i].hour, minute: selectedTime.minute);
          }
        }
      });
    }
  }

  // void setNotificationTime(context) {
  //   TimeOfDay? selectedTime;
  //   TimeOfDay initialTime = notTime;
  //   selectedTime =  showTimePicker(
  //     context: context,
  //     initialTime: initialTime,
  //     initialEntryMode: TimePickerEntryMode.inputOnly,
  //     builder: (context, childWidget) {
  //       return MediaQuery(
  //           data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
  //           child: childWidget ?? Container());
  //     },
  //   );
    // if (selectedTime != null) {
    //   setState(() {
    //     notTime = selectedTime!;
    //   });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    if (widget.habitData != null) {
      title.text = widget.habitData!.title;
      calories.text = widget.habitData!.calTarget.toString();
      routine.text = widget.habitData!.routine;
      steps.text = widget.habitData!.stepsTarget.toString();
      hour.text = widget.habitData!.notTimes[0].hour.toString();
      minute.text = widget.habitData!.notTimes[0].minute.toString();
      stepsEnabled = widget.habitData!.stepsEnabled;
      hourly = widget.habitData!.hourly;
      calEnabled = widget.habitData!.calEnabled;
      targetGoal = widget.habitData!.targetGoal;
      notification = widget.habitData!.notification;
      notTimes = widget.habitData!.notTimes;
      _generateHoursOfDay();
    }
  }

  @override
  void dispose() {
    title.dispose();
    steps.dispose();
    hour.dispose();
    minute.dispose();
    calories.dispose();
    routine.dispose();
    super.dispose();
  }

  void _generateHoursOfDay() {
    allHoursOfDay.clear();
    _allHoursOfDay =
        List.generate(24, (index) => TimeOfDay(hour: index, minute: 0));
  }

  // List<int> notHours = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          (widget.habitData != null) ? 'Edit Habit' : 'Create Habit',
        ),
        backgroundColor: Colors.transparent,
        iconTheme: Theme.of(context).iconTheme,
        actions: <Widget>[
          if (widget.habitData != null)
            IconButton(
              icon: const Icon(
                Icons.delete,
                semanticLabel: 'Delete',
              ),
              color: ActivityTrackerColors.red,
              tooltip: 'Delete',
              onPressed: () {
                Navigator.of(context).pop();
                if (widget.habitData != null) {
                  Provider.of<HabitsManager>(context, listen: false)
                      .deleteHabit(widget.habitData!.id!);
                }
              },
            ),
        ],
      ),
      floatingActionButton: Builder(builder: (BuildContext context) {
        return FloatingActionButton(
          onPressed: () {
            if (title.text.isNotEmpty) {
              if (widget.habitData != null) {
                Provider.of<HabitsManager>(context, listen: false).editHabit(
                  HabitData(
                    id: widget.habitData!.id,
                    title: title.text.toString(),
                    hourly: hourly,
                    stepsTarget: int.parse(steps.text),
                    routine: routine.text.toString(),
                    calTarget: int.parse(calories.text),
                    stepsEnabled: stepsEnabled,
                    calEnabled: calEnabled,
                    targetGoal: targetGoal,
                    notification: notification,
                    notTimes: notTimes,
                    position: widget.habitData!.position,
                    events: widget.habitData!.events,
                  ),
                );
              } else {
                Provider.of<HabitsManager>(context, listen: false).addHabit(
                  title.text.toString(),
                  hourly,
                  calEnabled,
                  int.parse(calories.text),
                  stepsEnabled,
                  int.parse(steps.text),
                  targetGoal,
                  routine.text.toString(),                
                  notification,
                  notTimes,
                );
              }
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  behavior: SnackBarBehavior.floating,
                  content: const Text("The habit title can not be empty."),
                ),
              );
            }
          },
          child: const Icon(
            Icons.check,
            semanticLabel: 'Save',
            color: Colors.white,
            size: 35.0,
          ),
        );
      }),
      body: Builder(builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                TextContainer(
                  title: title,
                  hint: 'Task title',
                  label: 'Task',
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  child: Row(
                    children: <Widget>[
                      Checkbox(
                        onChanged: (bool? value) {
                          setState(() {
                            hourly = value!;
                          });
                        },
                        value: hourly,
                      ),
                      const Text("Hourly goal"),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Tooltip(
                          message:
                              "Will check task completion hourly and send reminders (when enabled)",
                          child: Icon(
                            Icons.info,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                hourly ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  child: SpinBox(
                    value: targetGoal.toDouble(),
                    min: 0,
                    max: 23,
                    // digits: 2,
                    decoration: const InputDecoration(labelText: 'Daily target'),
                    onChanged: (value) => targetGoal = value.toInt(),
                  ),
                ):Container(),
                ExpansionTile(
                  title: const Padding(
                    padding: EdgeInsets.all(7.0),
                    child: Text(
                      "Notification Settings",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  initiallyExpanded: notification,
                  children: <Widget>[
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 25),
                      title: const Text("Notifications"),
                      trailing: Switch(
                          value: notification,
                          onChanged: (value) {                      
                            setState(() {
                              notification = value;
                            });
                          }),
                    ),
                    notification ? 
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                        enabled: notification,
                        title: const Text("Notification time"),
                      ), 
                        Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                          !hourly ?
                            Container(
                            width: 75,
                            // margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4,
                                  offset: Offset.fromDirection(1, 3),
                                  color: const Color(0x21000000),
                                )
                              ],
                              borderRadius: const BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            child: TextField(
                              controller: hour,
                              autofocus: false,
                              maxLines: 1,
                              maxLength: 2,
                              onChanged: ((value) {
                                setState(() {
                                  notTimes[0] = TimeOfDay(hour: int.parse(value), minute: notTimes[0].minute);
                                });
                              }),
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly, CustomMaxInputFormatter(maxInputValue: 24)],
                              keyboardType: TextInputType.number,
                              textAlignVertical: TextAlignVertical.bottom,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(10),
                                border: InputBorder.none,
                                hintText: "Hour",
                                labelText: "Hour",
                                counterText: "",
                              ),
                            )
                            ): Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(25, 0, 0, 5),
                                  child: Text("Select Hours:", style: TextStyle(fontSize: 16),textAlign: TextAlign.left), 
                                ),
                            Container(
                                padding: const EdgeInsets.fromLTRB(25, 0, 0, 0),
                                height: 100,
                                width: 100,
                                child: GridView.builder(
                                  // shrinkWrap: true,
                                  physics:
                                      const BouncingScrollPhysics(),
                                  itemCount: allHoursOfDay.length,
                                  itemBuilder: (context, index) {
                                    // return Container(child: Text("$index"));
                                    return 
                                    InkWell(
                                      onTap: () {
                                        if ((notTimes.indexWhere(
                                                (element) =>
                                                    element.hour ==
                                                    index)) >
                                            -1) {
                                          if (notTimes.length > 1) {
                                            notTimes.removeWhere(
                                                (element) =>
                                                    element.hour ==
                                                    index);
                                          }
                                        } else {
                                          notTimes.add(TimeOfDay(
                                              hour: index,
                                              minute: notTimes[0]
                                                  .minute));
                                        }
                                        setState(() {});
                                        debugPrint("$notTimes");
                                      },
                                      child: Padding(
                                          padding: const EdgeInsets
                                                  .symmetric(
                                              vertical: 0.5),
                                          child: Center(
                                            child: AspectRatio(
                                              aspectRatio: 1,
                                              child: Container(
                                                  // width: 40,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape
                                                          .rectangle,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7),
                                                      color: ((notTimes.indexWhere((element) => element.hour == index)) > -1)
                                                          ? Colors
                                                              .green
                                                          : Colors.grey[
                                                              700]),
                                                  // color: ((notTimes.indexWhere((element) => element.hour == index)) > -1) ? Colors.green : Colors.red,
                                                  child: Align(
                                                      alignment:
                                                          Alignment
                                                              .center,
                                                      child: Text("$index".padLeft(2, "0"),
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 14)))),
                                            ),
                                          )),
                                    );
                                  },
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 8,
                                    childAspectRatio: 1.5,
                                    mainAxisSpacing: 5
                                  ),
                                ),
                              ),                 
                              ],
                            ),         
                            Container(
                              width: 75,
                              // height: 20,
                              margin: const EdgeInsets.fromLTRB(10, 15, 25, 15),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 4,
                                    offset: Offset.fromDirection(1, 3),
                                    color: const Color(0x21000000),
                                  )
                                ],
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                              child: 
                              TextField(
                                controller: minute,
                                autofocus: false,
                                maxLines: 1,
                                maxLength: 100,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly, CustomMaxInputFormatter(maxInputValue: 60)],
                                onChanged: ((value) {
                                setState(() {
                                  int minute = int.parse(value);
                                  notTimes[0] = TimeOfDay(hour: notTimes[0].hour, minute: minute);
                                  if (notTimes.length > 1){
                                    for (int i = 0; i < notTimes.length; i++){
                                    notTimes[i] = TimeOfDay(hour: notTimes[i].hour, minute: minute);
                                    }
                                  }                                  
                                });
                              }),                                
                                keyboardType: TextInputType.number,
                                textAlignVertical:
                                    TextAlignVertical.bottom,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  border: InputBorder.none,
                                  hintText: "Minute",
                                  labelText: "Minute",
                                  counterText: "",
                                ),
                              )
                              )                        
                        ],
                      )
                    ]):Container(),
                 ],
                ),                             
                ExpansionTile(
                  title: const Padding(
                    padding: EdgeInsets.all(7.0),
                    child: Text(
                      "Activity Calories",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  initiallyExpanded: calEnabled,
                  children: <Widget>[
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 25),
                      title: const Text("Track activity calories"),
                      trailing: Switch(
                          value: calEnabled,
                          onChanged: (value) {
                            calEnabled = value;
                            setState(() {});
                          }),
                    ),
                    // ListTile(
                    //   contentPadding:
                    //       const EdgeInsets.symmetric(horizontal: 25),
                    //   enabled: notification,
                    //   title: const Text("Calorie target"),
                    //   trailing: TextContainer(
                    //     onTap: () {
                    //       if (notification) {
                    //         calories = value;
                    //       }
                    //     },
                    //     child: Text("$calories.padLeft(2, '0')}",
                    //       style: TextStyle(
                    //           color: (caloriesEnabled)
                    //               ? null
                    //               : Theme.of(context).disabledColor),
                    //     ),
                    //   ),
                    calEnabled ? TextContainer(

                      title: calories,
                      hint: 'Activity calory goal in kcal',
                      label: 'Goal' ,
                      numbersOnly: true,
                    ) : Container(),
                    
                    // ),
                  ],
                ),
                ExpansionTile(
                  title: const Padding(
                    padding: EdgeInsets.all(7.0),
                    child: Text(
                      "Steps",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  initiallyExpanded: stepsEnabled,
                  children: <Widget>[
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 25),
                      title: const Text("Track steps"),
                      trailing: Switch(
                          value: stepsEnabled,
                          onChanged: (value) {
                            stepsEnabled = value;
                            setState(() {});
                          }),
                    ),
                    stepsEnabled
                        ? TextContainer(
                            title: steps,
                            hint: 'Steps goal',
                            label: 'Goal',
                            numbersOnly: true,
                          )
                        : Container(),
                  ],
                ),                   
              ],
            ),
          ),
        );
      }),
    );
  }
}

class CustomMaxInputFormatter extends TextInputFormatter{
  final double maxInputValue;
  CustomMaxInputFormatter({required this.maxInputValue});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue){
    final TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    final double? value = double.tryParse(newValue.text);
    if (value == null ){
      return TextEditingValue(text: truncated, selection: newSelection);
    }
    if (value > maxInputValue){
      truncated = maxInputValue.toString();
    }
    return TextEditingValue(text: truncated, selection: newSelection);
  }
}

