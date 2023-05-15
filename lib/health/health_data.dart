import 'dart:async';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthData {
  final HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);
  static final types = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    // Uncomment these lines on iOS - only available on iOS
    // HealthDataType.AUDIOGRAM
  ];

  final permissions = types.map((e) => HealthDataAccess.READ_WRITE).toList();

  Future authorize() async {
    // If we are trying to read Step Count, Workout, Sleep or other data that requires
    // the ACTIVITY_RECOGNITION permission, we need to request the permission first.
    // This requires a special request authorization call.
    //
    // The location permission is requested for Workouts using the Distance information.
    await Permission.activityRecognition.request();
    // await Permission.location.request();

    // Check if we have permission
    bool? hasPermissions =
        await health.hasPermissions(types, permissions: permissions);

    // hasPermissions = false because the hasPermission cannot disclose if WRITE access exists.
    // Hence, we have to request with WRITE as well.
    hasPermissions = false;

    bool authorized = false;
    if (!hasPermissions) {
      // requesting access to the data types before reading them
      try {
        authorized =
            await health.requestAuthorization(types, permissions: permissions);
      } catch (error) {
        print("Exception in authorize: $error");
      }
    }
  }

  /// Fetch data points from the health plugin and show them in the app.
  Future fetchData(DateTime start, DateTime end, HealthDataType type) async {
    List<HealthDataPoint> _healthDataList = [];

    // Clear old data points
    // _healthDataList.clear();

    try {
      // fetch health data
      List<HealthDataPoint> healthData =
          await health.getHealthDataFromTypes(start, end, [type]);
      // save all the new data points (only the first 100)
      _healthDataList.addAll(
          (healthData.length < 100) ? healthData : healthData.sublist(0, 100));
    } catch (error) {
      print("Exception in getHealthDataFromTypes: $error");
    }

    // filter out duplicates
    // int? steps = await HealthFactory.getTotalStepsInInterval(start, end);
    // _healthDataList = HealthFactory.removeDuplicates(_healthDataList);
    // _healthDataList.addAll(iterable)

    // print the results
    _healthDataList.forEach((x) => print(x));
  }
}
