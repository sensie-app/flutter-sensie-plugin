import 'dart:async';
import 'types.dart';
import 'package:sensors/sensors.dart';

class CalibrationSession {
  String id;
  Map<String, dynamic> currentSensie;
  SensorData sensorData;
  bool canCaptureSensie;
  String accessToken;

  CalibrationSession({
    required this.id,
    required this.currentSensie,
    required this.sensorData,
    required this.canCaptureSensie,
    required this.accessToken,
  });

  Map<String, StreamSubscription> startSensors(
      {void Function(SensorData)? callback}) {
    StreamSubscription<GyroscopeEvent>? gyroSubscription;
    StreamSubscription<AccelerometerEvent>? accelSubscription;

    SensorData sensorData = SensorData(
      gyroX: [],
      gyroY: [],
      gyroZ: [],
      accelX: [],
      accelY: [],
      accelZ: [],
    );

    gyroSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      sensorData.gyroX.add(event.x);
      sensorData.gyroY.add(event.y);
      sensorData.gyroZ.add(event.z);
      if (callback != null) callback(sensorData);
    });

    accelSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      sensorData.accelX.add(event.x);
      sensorData.accelY.add(event.y);
      sensorData.accelZ.add(event.z);
      if (callback != null) callback(sensorData);
    });

    return {
      'gyroSubscription': gyroSubscription,
      'accelSubscription': accelSubscription
    };
  }
}
