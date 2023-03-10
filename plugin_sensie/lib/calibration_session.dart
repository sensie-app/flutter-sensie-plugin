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

class SensorData {
  List<double> gyroX;
  List<double> gyroY;
  List<double> gyroZ;
  List<double> accelX;
  List<double> accelY;
  List<double> accelZ;

  SensorData(
    this.gyroX,
    this.gyroY,
    this.gyroZ,
    this.accelX,
    this.accelY,
    this.accelZ,
  );
}
