import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'plugin_sensie_method_channel.dart';

abstract class PluginSensiePlatform extends PlatformInterface {
  /// Constructs a PluginSensiePlatform.
  PluginSensiePlatform() : super(token: _token);

  static final Object _token = Object();

  static PluginSensiePlatform _instance = MethodChannelPluginSensie();

  /// The default instance of [PluginSensiePlatform] to use.
  ///
  /// Defaults to [MethodChannelPluginSensie].
  static PluginSensiePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PluginSensiePlatform] when
  /// they register themselves.
  static set instance(PluginSensiePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
