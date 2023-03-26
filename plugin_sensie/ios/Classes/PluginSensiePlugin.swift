import Flutter
import UIKit
import SensieFramework

public class PluginSensiePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.sensie.plugin_sensie/swift_function", binaryMessenger: registrar.messenger())
    let instance = PluginSensiePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "whipCounter" {
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        return
      }
      let arg1 = args["yaw"] as? Array<Double>
      let nativeResult = SensieFramework.whipCounter(param: arg1)
      result(nativeResult)
    } else if call.method == "signalStrength" {
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        return
      }
      let arg1 = args["sensies"] as? Array<Dictionary<String, Any>>
      let nativeResult = SensieFramework.signalStrength(sensies: arg1)
      result(nativeResult)
    } else if call.method == "evaluateSensie" {
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        return
      }
      let arg1 = args["sensie"] as? Dictionary<String, Any>
      let arg2 = args["sensies"] as? Array<Dictionary<String, Any>>
      let nativeResult = SensieFramework.evaluateSensie(sensie: arg1, sensies: arg2)
      result(nativeResult)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
}