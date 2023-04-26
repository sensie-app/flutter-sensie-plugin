package com.sensie.plugin_sensie;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import java.util.List;
import java.util.Map;
import com.sensie.sensielibrary.Sensie;

public class PluginSensiePlugin implements FlutterPlugin, MethodCallHandler {
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        setupMethodChannel(binding.getBinaryMessenger());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        tearDownMethodChannel();
    }

    private void setupMethodChannel(BinaryMessenger messenger) {
        channel = new MethodChannel(messenger, "com.sensie.plugin_sensie/swift_function");
        channel.setMethodCallHandler(this);
    }

    private void tearDownMethodChannel() {
        channel.setMethodCallHandler(null);
        channel = null;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "whipCounter":
                handleWhipCounter(call, result);
                break;
            case "signalStrength":
                handleSignalStrength(call, result);
                break;
            case "evaluateSensie":
                handleEvaluateSensie(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void handleWhipCounter(MethodCall call, Result result) {
        Sensie s = new Sensie();
        Map<String, Object> param = call.argument("param");
        result.success(s.whipCounter(param));
    }

    private void handleSignalStrength(MethodCall call, Result result) {
        Sensie s = new Sensie();
        List<Map<String, Object>> sensies = call.argument("sensies");
        result.success(s.signalStrength(sensies));
    }

    private void handleEvaluateSensie(MethodCall call, Result result) {
        Sensie s = new Sensie();
        Map<String, Object> sensie = call.argument("sensie");
        List<Map<String, Object>> sensies = call.argument("sensies");
        result.success(s.evaluateSensie(sensie, sensies));
    }
}