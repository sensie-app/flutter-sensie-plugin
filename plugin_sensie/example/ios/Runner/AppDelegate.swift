import UIKit
import Flutter
import plugin_sensie

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        if let pluginRegistrar = registrar(forPlugin: "com.sensie.plugin_sensie/swift_function") {
            PluginSensiePlugin.register(with: pluginRegistrar)
        } else {
            print("Failed to register PluginSensiePlugin.")
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}