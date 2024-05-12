
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;

  String _steps = '0';
  String _pedestrianStatus = 'stopped';
  String _unit = 'Steps';
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void onStepCount(StepCount event) async {
    print('Event occurred: $event.toString()');
    setState(() {
      _steps = event.steps.toString();
    });
    // Save the step count when it changes
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('stepCount', int.parse(_steps));
  }

  void onStepCountError(err) {
    print('Error occurred');
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print('Event occurred: $event.toString()');
    setState(() {
      _pedestrianStatus = event.status.toString();
    });
  }

  void onPedestrianStatusError(err) {
    print('Error occurred: $err');
    setState(() {
      _pedestrianStatus = 'unknown';
    });
  }

  Future<bool> checkPermission() async {
    if (await Permission.activityRecognition.request().isGranted) {
      return true;
    } else {
      return false;
    }
  }

  void initPlatformState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Retrieve the saved step count when the app is opened
    int savedStepCount = prefs.getInt('stepCount') ?? 0;
    setState(() {
      _steps = savedStepCount.toString();
    });

    if (await checkPermission()) {
      setState(() {
        _permissionGranted = true;
      });

      setState(() {
        _stepCountStream = Pedometer.stepCountStream;
        _stepCountStream.listen(onStepCount).onError(onStepCountError);

        _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
        _pedestrianStatusStream
            .listen(onPedestrianStatusChanged)
            .onError(onPedestrianStatusError);
      });
    }

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Step counter'),
          actions: [IconButton(onPressed: (){
            setState(() {
               _steps = 0 as String;
            });
          }, icon: Icon(Icons.refresh))],
        ),
        body: Container(
          alignment: Alignment.center,
          child: _permissionGranted
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Steps',
                  style: TextStyle(
                      fontSize: _unit.length > 8 ? 32 : 48)),
              Text(_steps,
                  style: TextStyle(
                      fontSize: _steps.length > 5 ? 64 : 128)),
              const Divider(height: 32, color: Colors.white),
            ],
          )
              : const AlertDialog(
            title: Text('Permission Denied'),
            content: Text(
                'You must grant activity recognition permission to use this app'),
          ),
        ),
      ),
    );
  }
}