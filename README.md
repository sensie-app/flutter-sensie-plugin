# Flutter-sensie-plugin
Flutter plugin for integrating Sensie

## Installation
...To be updated

# Usage
## Import
Import SensieEngine and CalibrationSession class.
```dart
import 'package:plugin_sensie/plugin_sensie.dart';
import 'package:plugin_sensie/sensie_engine.dart';
import 'package:plugin_sensie/sensie.dart';
import 'package:plugin_sensie/calibration_session.dart';
```

## Initiation
Pass the generated token for Sensie SDK
```dart
_se = new SensieEngine(initAccessToken: '[Token]');
```
## Connection
 A method to establish a connection. It should return a promise that will tell us if the connection was successful.
```dart
await _se.connect()
```
Also, canRecalibrate property will be set depending on stored sensies in storage.

## Calibration
```dart
_cs = await _se.startCalibration(CalibrationInput(
          userId: 'userId',
          onEnds: (res) {
            print(res);
          }));
```
 result will be an object with a single property contains calibration strength.

## Capturing Sensie
```dart
Map<String, dynamic> sensie = await _cs.captureSensie(CaptureSensieInput(
        flow: true,
        onSensorData: (data) {
          print(data);
        }));
```
sensie will be an object with the following properties:
- id: the id of the sensie
- whips: the number of whips
- valid: true if whips == 3

flow is boolean value(true or false)

onSensorData is a callback function that will be called every time we have new values from the sensors (optional)

data will be an object with the following properties:

- gyroX: the gyroscope X axis value
- gyroY: the gyroscope Y axis value
- gyroZ: the gyroscope Z axis value
- accelX: the accelerometer X axis value
- accelY: the accelerometer Y axis value
- accelZ: the accelerometer Z axis value

## Evaluation
```dart
 _se.startEvaluation('userId');
 
 _sensie = await _se.captureSensie(CaptureEvaluateSensieInput(
      userId: 'userId',
      onSensorData: (data) {
        print(data);
      },
    ));
```
sensie object will be an object with the following properties:

- id: the id of the sensie but undefied yet.
- whips: the number of whips
- flowing: the result of the evaluation (true or false)
- setAgreement: Method for setting agreement. Sensie id will be set as soon as the agrement value is set. Agreement enum is included in the index.tsx.

## Setting agreement
```dart
_sensie.setAgreement(Agreement.agree);
```

## Reference App

Go to plugin_sensie/example and run 'flutter run'
