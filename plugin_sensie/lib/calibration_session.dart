import 'types.dart';

class CalibrationSession {
  String id;
  Map<String, dynamic> currentSensie;
  SensorData sensorData;
  bool canCaptureSensie;
  String accessToken;

  CalibrationSession(this.accessToken, this.id)
      : currentSensie = {},
        sensorData = SensorData(
          [],
          [],
          [],
          [],
          [],
          [],
        ),
        canCaptureSensie = true;
}
