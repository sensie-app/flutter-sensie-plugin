import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'plugin_sensie_platform_interface.dart';

/// An implementation of [PluginSensiePlatform] that uses method channels.
class MethodChannelPluginSensie extends PluginSensiePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('plugin_sensie');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
