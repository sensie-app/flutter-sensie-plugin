class SensieEngineInit {
  String accessToken;

  SensieEngineInit({required this.accessToken});
}

class CalibrationInput {
  String userId;
  void Function(Object) onEnds;

  CalibrationInput({required this.userId, required this.onEnds});
}

class WhipCounterReturn {
  List<double> avgFlatCrest;
  int whipCount;

  WhipCounterReturn({required this.avgFlatCrest, required this.whipCount});
}

class SensorData {
  List<double> gyroX;
  List<double> gyroY;
  List<double> gyroZ;
  List<double> accelX;
  List<double> accelY;
  List<double> accelZ;

  SensorData({
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    required this.accelX,
    required this.accelY,
    required this.accelZ,
  });

  Map<String, dynamic> toJson() {
    return {
      'gyroX': gyroX,
      'gyroY': gyroY,
      'gyroZ': gyroZ,
      'accelX': accelX,
      'accelY': accelY,
      'accelZ': accelZ,
    };
  }
}

class EvaluateSensieReturn {
  int flowing;
  double ratio;

  EvaluateSensieReturn({required this.flowing, required this.ratio});
}

class CaptureSensieInput {
  bool flow;
  void Function(dynamic)? onSensorData;

  CaptureSensieInput({required this.flow, this.onSensorData});
}

class CaptureEvaluateSensieInput {
  String userId;
  void Function(dynamic)? onSensorData;

  CaptureEvaluateSensieInput({required this.userId, this.onSensorData});
}

enum Agreement {
  agree,
  disagree,
  agreeAfterReflecting,
}

extension AgreementExtension on Agreement {
  int get value {
    switch (this) {
      case Agreement.agree:
        return 1;
      case Agreement.disagree:
        return -1;
      case Agreement.agreeAfterReflecting:
        return 2;
      default:
        return 0;
    }
  }
}
