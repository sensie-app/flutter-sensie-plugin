import 'plugin_sensie_platform_interface.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'sensie.dart';
import 'types.dart';

const String SENSIES = 'sensies';

class PluginSensie {
  static const MethodChannel _channel = const MethodChannel('plugin_sensie');

  static late String accessToken;
  late bool canRecalibrate;
  late Function(Object) onEnds;
  static late bool canEvaluate;
  late SensorData sensorData;
  late String userId;
  late String sessionId;
  late bool isConnecting;

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
