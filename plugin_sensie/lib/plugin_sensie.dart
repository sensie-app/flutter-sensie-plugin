import 'package:flutter/services.dart';
// import 'plugin_sensie_platform_interface.dart';

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

  static Future<int> signalStrength(List<Object> sensies) async {
    final Map<String, dynamic> args = <String, dynamic>{
      'sensies': sensies,
    };
    final int result = await _channel.invokeMethod('signalStrength', args);
    return result;
  }

  static Future<int> evaluateSensie(Object sensie, List<Object> sensies) async {
    final Map<String, dynamic> args = <String, dynamic>{
      'sensie': sensie,
      'sensies': sensies,
    };
    final int result = await _channel.invokeMethod('evaluateSensie', args);
    return result;
  }
}
