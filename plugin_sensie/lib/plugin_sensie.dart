import 'package:flutter/services.dart';

class PluginSensie {
  static const MethodChannel _channel =
      MethodChannel("com.sensie.plugin_sensie/swift_function");

  static Future<Map<String, dynamic>> whipCounter(List<double> yaw) async {
    final Map<String, dynamic> args = <String, dynamic>{
      'yaw': yaw,
    };
    final Map<String, dynamic> result =
        await _channel.invokeMethod('whipCounter', args);
    return result;
  }

  static Future<int> signalStrength(List<Map<String, dynamic>> sensies) async {
    final Map<String, dynamic> args = <String, dynamic>{
      'sensies': sensies,
    };
    final int result = await _channel.invokeMethod('signalStrength', args);
    return result;
  }

  static Future<int> evaluateSensie(
      Map<String, dynamic> sensie, List<Map<String, dynamic>> sensies) async {
    final Map<String, dynamic> args = <String, dynamic>{
      'sensie': sensie,
      'sensies': sensies,
    };
    final int result = await _channel.invokeMethod('evaluateSensie', args);
    return result;
  }
}
