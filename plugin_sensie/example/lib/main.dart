import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:plugin_sensie/calibration_session.dart';
import 'package:plugin_sensie/plugin_sensie.dart';
import 'package:flutter/material.dart';
import 'package:plugin_sensie/sensie.dart';
import 'dart:async';

import 'package:plugin_sensie/sensie_engine.dart';
import 'package:plugin_sensie/types.dart';

enum _KeyType { Black, White }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plugin Sensie example app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Plugin Sensie example app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late SensieEngine _se;
  late CalibrationSession _cs;
  late Sensie _sensie;

  void _onPressed1() async {
    print('Button pressed');
    try {
      _se = new SensieEngine(
          initAccessToken: 'Sensi_Sandbox.DCYYXOI-MXLUGSY-TRUJN7Y-OE6JLIQ');
      print(_se.accessToken);
      print(await _se.connect());
      _cs = await _se.startCalibration(CalibrationInput(
          userId: 'junho',
          onEnds: (res) {
            print(res);
          }));
      print(_cs);
    } catch (e) {
      print(e);
    }
  }

  void _onPressed2() async {
    print('Button pressed');
    Map<String, dynamic> sensie = await _cs.captureSensie(CaptureSensieInput(
        flow: false,
        onSensorData: (data) {
          print(data);
        }));
    print(sensie);
  }

  void _onPressed3() async {
    print('Button pressed');
    await _se.startEvaluation('junho');
  }

  void _onPressed4() async {
    print('Button pressed');
    _sensie = await _se.captureSensie(CaptureEvaluateSensieInput(
      userId: 'junho',
      onSensorData: (data) {
        print(data);
      },
    ));
    print(_sensie);
  }

  void _onPressed5() async {
    print('Button pressed');
    _sensie.setAgreement(Agreement.agree);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin Sensie example app'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Running on:'),
            ElevatedButton(onPressed: _onPressed1, child: Text('Button1')),
            ElevatedButton(onPressed: _onPressed2, child: Text('Button2')),
            ElevatedButton(onPressed: _onPressed3, child: Text('Button3')),
            ElevatedButton(onPressed: _onPressed4, child: Text('Button4')),
            ElevatedButton(onPressed: _onPressed5, child: Text('Button5')),
          ],
        ),
      ),
    );
  }
}
