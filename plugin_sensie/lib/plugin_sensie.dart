import 'plugin_sensie_platform_interface.dart';

class PluginSensie {
  Future<String?> getPlatformVersion() {
    return PluginSensiePlatform.instance.getPlatformVersion();
  }
}
