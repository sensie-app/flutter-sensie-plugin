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
      guard let unwrappedArg1 = args as? NSDictionary else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        return
      }
      let nativeResult = SensieFramework.whipCounter(param: unwrappedArg1)
      result(nativeResult)
    } else if call.method == "signalStrength" {
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        return
      }
      let arg1 = args["sensies"] as? Array<Dictionary<String, Any>>
      guard let unwrappedArg1 = arg1 else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        return
      }
      let nativeResult = SensieFramework.signalStrength(sensies: unwrappedArg1)
      result(nativeResult)
    } else if call.method == "evaluateSensie" {
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        return
      }
      let arg1 = args["sensie"] as? Dictionary<String, Any>
      let arg2 = args["sensies"] as? Array<Dictionary<String, Any>>
      guard let unwrappedArg1 = arg1 else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        return
      }
      guard let unwrappedArg2 = arg2 else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        return
      }
      let nativeResult = SensieFramework.evaluateSensie(sensie: unwrappedArg1, sensies: unwrappedArg2)
      result(nativeResult)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
}