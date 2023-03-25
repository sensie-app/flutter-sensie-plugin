import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_sensie/plugin_sensie.dart';
import 'package:plugin_sensie/plugin_sensie_platform_interface.dart';
import 'package:plugin_sensie/plugin_sensie_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPluginSensiePlatform
    with MockPlatformInterfaceMixin
    implements PluginSensiePlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PluginSensiePlatform initialPlatform = PluginSensiePlatform.instance;

  test('$MethodChannelPluginSensie is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPluginSensie>());
  });

  test('getPlatformVersion', () async {
    PluginSensie pluginSensiePlugin = PluginSensie();
    MockPluginSensiePlatform fakePlatform = MockPluginSensiePlatform();
    PluginSensiePlatform.instance = fakePlatform;

    expect(await pluginSensiePlugin.getPlatformVersion(), '42');
  });
}
