package com.sensie.plugin_sensie;

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.sensie.SensieLibrary

class KotlinFlutterPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.sensie.plugin_sensie/swift_function")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "whipCounter") {
            val arg1 = call.argument<List<Double>>("arg1") ?: [""]
            val kotlinResult = SensieLibrary.whipCounter(arg1)
            result.success(kotlinResult)
        } else if (call.method == "signalStrength") {
            val arg1 = call.argument<List<Map<String, Any>>>("arg1") ?: []
            val kotlinResult = SensieLibrary.signalStrength(arg1)
            result.success(kotlinResult)
        } else if (call.method == "evaluateSensie") {
            val arg1 = call.argument<Map<String, Any>>("arg1") ?: mapOf()
            val arg2 = call.argument<List<Map<String, Any>>>("arg2") ?: []
            val kotlinResult = SensieLibrary.evaluateSensie(arg1, arg2)
            result.success(kotlinResult)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
