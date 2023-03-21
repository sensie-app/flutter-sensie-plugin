import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'sensie.dart';
import 'types.dart';
import 'calibration_session.dart';
import 'package:http/http.dart' as http;
import 'package:sensors/sensors.dart';
import 'plugin_sensie.dart';

class SensieEngine {
  late String accessToken;
  late bool canRecalibrate;
  late Function(Object)? onEnds;
  late bool canEvaluate;
  late SensorData sensorData;
  late String userId;
  late String sessionId;
  late bool isConnecting;

  SensieEngine({required String initAccessToken}) {
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
    List<dynamic>? sensies = await getDataFromAsyncStorage(SENSIES);
    int flow = 0, block = 0;
    if (sensies == null) {
      canEvaluate = false;
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
      canEvaluate = true;
      return true;
    }
    canEvaluate = false;
    return false;
  }

  Future<Map<String, dynamic>> connect() async {
    if (accessToken.isNotEmpty) {
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

    final Map<String, dynamic> body = {'userId': this.userId, 'type': type};

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-api-key': accessToken,
    };

    final response = await http.post(
      Uri.parse(baseUrl + path),
      body: json.encode(body),
      headers: headers,
    );

    return json.decode(response.body);
  }

  Future<CalibrationSession> startCalibration(
      CalibrationInput calibrationInput) async {
    try {
      if (!canRecalibrate) {
        throw Exception(
            "Can't recalibrate sensie. Please check async storage.");
      }

      userId = calibrationInput.userId;
      onEnds = calibrationInput.onEnds;
      final resJSON = await startSessionRequest('calibration');
      final sessionId = resJSON.data.session.id;
      this.sessionId = sessionId;
      return CalibrationSession(accessToken, sessionId);
    } catch (e) {
      throw Exception('Failed to start calibration session.');
    }
  }

  Map<String, StreamSubscription> startSensors(
      {Function(SensorData)? callback}) {
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

  void stopSensors({
    required StreamSubscription gyroSubscription,
    required StreamSubscription accelSubscription,
  }) {
    gyroSubscription.cancel();
    accelSubscription.cancel();
  }

  void roundSensorData() {
    sensorData.gyroX =
        sensorData.gyroX.map((x) => (x * 100).round() / 100).toList();
    sensorData.gyroY =
        sensorData.gyroY.map((x) => (x * 100).round() / 100).toList();
    sensorData.gyroZ =
        sensorData.gyroZ.map((x) => (x * 100).round() / 100).toList();
    sensorData.accelX =
        sensorData.accelX.map((x) => (x * 100).round() / 100).toList();
    sensorData.accelY =
        sensorData.accelY.map((x) => (x * 100).round() / 100).toList();
    sensorData.accelZ =
        sensorData.accelZ.map((x) => (x * 100).round() / 100).toList();
  }

  resetSensorData() {
    sensorData = SensorData(
      gyroX: [],
      gyroY: [],
      gyroZ: [],
      accelX: [],
      accelY: [],
      accelZ: [],
    );
  }

  Future<dynamic> captureSensie(
      CaptureEvaluateSensieInput captureSensieInput) async {
    if (captureSensieInput.userId != userId) {
      return {'message': 'User id is not valid.'};
    }

    final Map<String, dynamic> sensors =
        startSensors(callback: captureSensieInput.onSensorData);
    final StreamSubscription subGyro = sensors['subGyro'];
    final StreamSubscription subAcc = sensors['subAcc'];

    final completer = Completer();

    Timer(Duration(milliseconds: 3000), () async {
      stopSensors(gyroSubscription: subGyro, accelSubscription: subAcc);
      roundSensorData();

      final dynamic whipData = await PluginSensie.whipCounter(sensorData.gyroZ);
      final int whipCount = whipData['whipCount'];
      final List<double> avgFlatCrest = whipData['avgFlatCrest'];

      if (whipCount == 3) {
        final dynamic sensiesData = await getDataFromAsyncStorage(SENSIES);
        final dynamic sensie = {
          'whipCount': whipCount,
          'signal': avgFlatCrest,
          'sensorData': sensorData,
        };
        final dynamic evaluation =
            await PluginSensie.evaluateSensie(sensie, sensiesData);
        final int flowing = evaluation['flowing'];

        final retSensie = Sensie(
          sensieInfo: SensieInfo(
            whips: whipCount,
            flowing: flowing,
            signal: avgFlatCrest,
            sensorData: SensorData(
              gyroX: [],
              gyroY: [],
              gyroZ: [],
              accelX: [],
              accelY: [],
              accelZ: [],
            ),
          ),
          sessionInfo: SessionInfo(
            sessionId: sessionId,
            accessToken: accessToken,
          ),
        );

        final dynamic calibrationStrength =
            await PluginSensie.signalStrength(sensiesData);
        if (onEnds != null) {
          onEnds!({'calibration_strength': calibrationStrength});
        }

        resetSensorData();

        completer.complete(retSensie);
      } else {
        resetSensorData();

        completer.complete({
          'id': 'Invalid sensie',
          'whips': whipCount,
          'flowing': null,
        });
      }
    });

    return completer.future;
  }
}
