import 'package:flutter/material.dart';
import 'package:rx_ble/rx_ble.dart';

class ConfigureGateway extends StatefulWidget {
  @override
  BLEManager createState() => BLEManager();
}

class BLEManager extends State<ConfigureGateway> {
  final GlobalKey<BLEManager> _key = GlobalKey<BLEManager>();
  var connectionState = BleConnectionState.disconnected;
  List<Widget> results = [];

  Future<Null> _startScan() async {
    try {
      await for (final scanResult in RxBle.startScan().timeout(Duration(seconds: 10))) {
        setState(() {
          results.add(Text(scanResult.toString()));
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _key,
      onRefresh: _startScan,
      child: ListView(
        children: results,
      ),
    );
  }
}