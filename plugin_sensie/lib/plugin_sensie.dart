import 'plugin_sensie_platform_interface.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'sensie.dart';
import 'types.dart';
import 'calibration_session.dart';
import 'package:http/http.dart' as http;

const String SENSIES = 'sensies';

class PluginSensie {
  static const MethodChannel _channel = const MethodChannel('plugin_sensie');

  static late String accessToken;
  static late bool canRecalibrate;
  static late Function(Object) onEnds;
  static late bool canEvaluate;
  static late SensorData sensorData;
  static late String userId;
  static late String sessionId;
  static late bool isConnecting;

  PluginSensie({required String initAccessToken}) {
    accessToken = initAccessToken;
    canRecalibrate = false;
    onEnds = (result) {};
    canEvaluate = false;
    sensorData = SensorData(
      gyroX: [],
      gyroY: [],
      gyroZ: [],
      accelX: [],
      accelY: [],
      accelZ: [],
    );
    userId = '';
    sessionId = '';
    isConnecting = false;
  }
}

Future<bool> checkCanRecalibrate() async {
  return true;
}

Future<dynamic> getDataFromAsyncStorage(String key) async {
  try {
    final jsonValue = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString(key));
    return jsonValue != null ? json.decode(jsonValue) : null;
  } catch (e) {
    debugPrint(e.toString());
  }
}

Future<bool> checkCanEvaluate() async {
  List<dynamic> sensies = await getDataFromAsyncStorage(SENSIES);
  int flow = 0, block = 0;
  if (sensies == null) {
    PluginSensie.canEvaluate = false;
    return false;
  }
  for (int i = 0; i < sensies.length; i++) {
    if (sensies[i].flow == 1) {
      flow++;
    } else {
      block++;
    }
  }
  if (flow >= 3 && block >= 3) {
    PluginSensie.canEvaluate = true;
    return true;
  }
  PluginSensie.canEvaluate = false;
  return false;
}

Future<Map<String, dynamic>> connect() async {
  if (PluginSensie.accessToken.isNotEmpty) {
    bool canRecalibrate = await checkCanRecalibrate();
    bool canEvaluate = await checkCanEvaluate();

    return {
      'message':
          'Successfully connected. Recalibrate : $canRecalibrate, Evaluate : $canEvaluate'
    };
  } else {
    return Future.error('Connection failed : Empty accessToken');
  }
}

Future<dynamic> startSessionRequest(String type) async {
  const String path = '/session';
  const String baseUrl = 'BASE_URL';

  final Map<String, dynamic> body = {
    'userId': PluginSensie.userId,
    'type': type
  };

  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-api-key': PluginSensie.accessToken,
  };

  final response = await http.post(
    Uri.parse(baseUrl + path),
    body: json.encode(body),
    headers: headers,
  );

  return json.decode(response.body);
}

Future<CalibrationSession> startCalibrationSession(
    CalibrationInput calibrationInput) async {
  try {
    if (!PluginSensie.canRecalibrate) {
      throw Exception("Can't recalibrate sensie. Please check async storage.");
    }

    PluginSensie.userId = calibrationInput.userId;
    PluginSensie.onEnds = calibrationInput.onEnds;
    final resJSON = await startSessionRequest('calibration');
    final sessionId = resJSON.data.session.id;
    PluginSensie.sessionId = sessionId;
    return CalibrationSession(PluginSensie.accessToken, sessionId);
  } catch (e) {
    print(e);
    throw Exception('Failed to start calibration session.');
  }
}

Future<dynamic> captureSensie(
    CaptureEvaluateSensieInput captureSensieInput) async {
  if (captureSensieInput.userId != PluginSensie.userId) {
    return {'message': 'User id is not valid.'};
  }

  final Map<String, dynamic> sensors =
      startSensors(captureSensieInput.onSensorData);
  final dynamic subGyro = sensors['subGyro'];
  final dynamic subAcc = sensors['subAcc'];

  final completer = Completer();

  Timer(Duration(milliseconds: 3000), () async {
    stopSensors(subGyro, subAcc);
    roundSensorData();

    final dynamic whipData = await whipCounter!();
    final int whipCount = whipData['whipCount'];
    final List<double> avgFlatCrest = whipData['avgFlatCrest'];

    if (whipCount == 3) {
      final dynamic sensiesData = await getDataFromAsyncStorage!(SENSIES);
      final dynamic sensie = {
        'whipCount': whipCount,
        'signal': avgFlatCrest,
        'sensorData': {}, // Replace with the appropriate sensorData
      };
      final dynamic evaluation = await evaluateSensie!(sensie, sensiesData);
      final int flowing = evaluation['flowing'];

      // Replace Sensie with the appropriate Dart class.
      final retSensie = Sensie(
        sensieInfo: SensieInfo(
          whips: whipCount,
          flowing: flowing,
          signal: avgFlatCrest,
          sensorData: {}, // Replace with the appropriate sensorData
        ),
        sessionInfo: SessionInfo(
          sessionId: PluginSensie.sessionId,
          accessToken: PluginSensie.accessToken,
        ),
      );

      final dynamic calibrationStrength = await signalStrength!(sensiesData);
      if (onEnds != null) {
        onEnds({'calibration_strength': calibrationStrength});
      }

      resetSensorData!();

      completer.complete(retSensie);
    } else {
      resetSensorData!();

      completer.complete({
        'id': 'Invalid sensie',
        'whips': whipCount,
        'flowing': null,
      });
    }
  });

  return completer.future;
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
}
