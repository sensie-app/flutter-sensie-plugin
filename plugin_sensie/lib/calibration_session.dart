import 'dart:async';
import 'package:plugin_sensie/plugin_sensie.dart';
import 'types.dart';
import 'package:sensors/sensors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sensie.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CalibrationSession {
  late String id;
  late Map<String, dynamic> currentSensie;
  late SensorData sensorData;
  late bool canCaptureSensie;
  late String accessToken;

  CalibrationSession(this.accessToken, String sessionId) {
    id = sessionId;
    currentSensie = {};
    sensorData = SensorData(
      gyroX: [],
      gyroY: [],
      gyroZ: [],
      accelX: [],
      accelY: [],
      accelZ: [],
    );
    canCaptureSensie = false;
  }

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

  void stopSensors(
      StreamSubscription<dynamic> subGyro, StreamSubscription<dynamic> subAcc) {
    subGyro.cancel();
    subAcc.cancel();
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

  Future<bool> checkCanCaptureSensie() async {
    return true;
  }

  Future<void> addSensie({required dynamic sensie}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sensiesJson = prefs.getString(SENSIES);

      List<dynamic> sensies =
          sensiesJson != null ? jsonDecode(sensiesJson) : [];
      sensies.add(sensie);

      await prefs.setString(SENSIES, jsonEncode(sensies));
    } catch (e) {
      debugPrint('Error: $e');
    }
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

  Future<Map<String, dynamic>> storeSensieRequest({
    required int whipCount,
    required bool flow,
  }) async {
    final path = '/session/$id/sensie';

    final body = {
      'accelerometerX': sensorData.accelX,
      'accelerometerY': sensorData.accelY,
      'accelerometerZ': sensorData.accelZ,
      'gyroscopeX': sensorData.gyroX,
      'gyroscopeY': sensorData.gyroY,
      'gyroscopeZ': sensorData.gyroZ,
      'whips': whipCount,
      'flowing': flow ? 1 : -1,
      'agreement': 1,
    };

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-api-key': accessToken,
    };

    final response = await http.post(
      Uri.parse(BASE_URL + path),
      body: json.encode(body),
      headers: headers,
    );

    return json.decode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> captureSensie(
      CaptureSensieInput captureSensieInput) async {
    canCaptureSensie = await checkCanCaptureSensie();
    if (!canCaptureSensie) {
      return {'message': "Can't capture sensie anymore"};
    }

    Map<String, StreamSubscription> sensorsSubscriptions =
        startSensors(callback: captureSensieInput.onSensorData);

    Completer<Map<String, dynamic>> completer = Completer();

    Timer(const Duration(milliseconds: 3000), () async {
      stopSensors(
        sensorsSubscriptions['gyroSubscription']!,
        sensorsSubscriptions['accelSubscription']!,
      );
      roundSensorData();

      Map<String, dynamic> whipCounterRes =
          await PluginSensie.whipCounter(sensorData.gyroZ);
      int whipCount = whipCounterRes['whipCount'];
      List<double> avgFlatCrest = whipCounterRes['avgFlatCrest'];

      currentSensie = {
        'whipCount': whipCount,
        'signal': avgFlatCrest,
        'sensorData': sensorData,
        'flow': captureSensieInput.flow ? 1 : -1,
      };

      canCaptureSensie = await checkCanCaptureSensie();

      if (whipCount == 3) await addSensie(sensie: currentSensie);
      if (whipCount != 0) {
        final resJson = await storeSensieRequest(
            whipCount: whipCount, flow: captureSensieInput.flow);
        final sensieId = resJson['data']['sensie']['id'];

        Map<String, dynamic> retSensie = {
          'id': sensieId,
          'whips': whipCount,
          'valid': whipCount == 3,
        };
        resetSensorData();
        completer.complete(retSensie);
      } else {
        resetSensorData();
        completer.complete({
          'id': 'Invalid Sensie with 0 whip count',
          'whips': whipCount,
          'valid': false,
        });
      }
    });

    return completer.future;
  }
}
