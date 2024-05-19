import 'package:flutter/material.dart';
import 'package:health/health.dart';

class StepCounter extends StatefulWidget {
  @override
  _StepCounterState createState() => _StepCounterState();
}

class _StepCounterState extends State<StepCounter> {
  HealthFactory health = HealthFactory();
  int steps = 0;

  @override
  void initState() {
    super.initState();
    fetchStepData();
  }

  Future<void> fetchStepData() async {
    // Define the types of data you want to access
    List<HealthDataType> types = [
      HealthDataType.STEPS,
    ];

    // Request authorization to access the data
    bool requested = await health.requestAuthorization(types);

    if (requested) {
      // Fetch the steps data
      DateTime startDate = DateTime.now().subtract(Duration(days: 1));
      DateTime endDate = DateTime.now();

      try {
        List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(startDate, endDate, types);
        int totalSteps = healthData.fold(0, (sum, point) => sum + (point.value as int));

        setState(() {
          steps = totalSteps;
        });
      } catch (e) {
        print("Caught exception in getHealthDataFromTypes: $e");
      }
    } else {
      print("Authorization not granted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step Counter'),
      ),
      body: Center(
        child: Text('Steps: $steps', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
