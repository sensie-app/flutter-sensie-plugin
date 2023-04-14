import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'types.dart';

const String SENSIES = 'sensies';

const String BASE_URL =
    'https://0x7xrifn76.execute-api.us-east-1.amazonaws.com/dev';

class SessionInfo {
  String sessionId;
  String accessToken;

  SessionInfo({required this.sessionId, required this.accessToken});
}

class SensieInfo {
  int whips;
  int flowing;
  List<dynamic> signal;
  SensorData sensorData;

  SensieInfo({
    required this.whips,
    required this.flowing,
    required this.signal,
    required this.sensorData,
  });
}

class Sensie {
  late String id;
  late int whips;
  late int flowing;
  late List<dynamic> signal;
  late Agreement agreement;
  late SensorData sensorData;
  late SessionInfo sessionInfo;

  Sensie({required SensieInfo sensieInfo, required SessionInfo sessionInfo}) {
    id = 'Sensie id will be availabe after the agreement';
    whips = sensieInfo.whips;
    flowing = sensieInfo.flowing;
    signal = sensieInfo.signal;
    agreement = Agreement.disagree;
    sensorData = sensieInfo.sensorData;
    sessionInfo = sessionInfo;
  }

  Future<Map<String, dynamic>> storeSensieRequest(
      int whipCount, int flowing, Agreement agreement) async {
    final path = '/session/${sessionInfo.sessionId}/sensie';

    final body = {
      'accelerometerX': sensorData.accelX,
      'accelerometerY': sensorData.accelY,
      'accelerometerZ': sensorData.accelZ,
      'gyroscopeX': sensorData.gyroX,
      'gyroscopeY': sensorData.gyroY,
      'gyroscopeZ': sensorData.gyroZ,
      'whips': whipCount,
      'flowing': flowing == 1 ? 1 : -1,
      'agreement': agreement,
    };

    final header = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-api-key': sessionInfo.accessToken,
    };

    final res = await http.post(
      Uri.parse(BASE_URL + path),
      headers: header,
      body: json.encode(body),
    );
    return json.decode(res.body);
  }

  Future<void> storeDataToAsyncStorage(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonValue = json.encode(value);
    await prefs.setString(key, jsonValue);
  }

  Future<void> addSensie(dynamic sensie) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sensies = prefs.getStringList(SENSIES);
      await storeDataToAsyncStorage(
        SENSIES,
        sensies != null ? [...sensies, sensie] : [sensie],
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<dynamic> getDataFromAsyncStorage(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonValue = prefs.getString(key);
    return jsonValue != null ? json.decode(jsonValue) : null;
  }

  Future<void> setAgreement(Agreement agreement) async {
    this.agreement = agreement;
    if (agreement == Agreement.agree) {
      await addSensie({
        'whipCount': whips,
        'signal': signal,
        'sensorData': sensorData,
        'flow': flowing,
      });
    }
    final resJSON = await storeSensieRequest(
      whips,
      flowing,
      agreement,
    );
    id = resJSON['data']['sensie']['id'];
  }
}
