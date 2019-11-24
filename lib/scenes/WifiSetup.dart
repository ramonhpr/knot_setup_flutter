import 'package:flutter/material.dart';

class WifiSetup extends StatefulWidget {
  final String deviceId;

  WifiSetup({Key key, @required this.deviceId}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      WifiSetupState(deviceId: this.deviceId);
}

class WifiSetupState extends State<WifiSetup> {
  final String deviceId;

  WifiSetupState({@required this.deviceId}) : super();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wifi configure page',
      theme: ThemeData(primarySwatch: Colors.green),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Configure Gateway Wifi'),
        ),
      ),
    );
  }
}
