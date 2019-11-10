import 'package:flutter/material.dart';

class ConfigureGateway extends StatefulWidget {
  @override
  BLEManager createState() => BLEManager();
}

class BLEManager extends State<ConfigureGateway> {
  final GlobalKey<BLEManager> _key = GlobalKey<BLEManager>();

  Future<Null> _startScan() async {

  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _key,
      onRefresh: _startScan,
      child: ListView(
        children: <Widget>[],
      ),
    );
  }
}