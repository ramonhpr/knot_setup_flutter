import 'package:flutter/material.dart';
import 'package:rx_ble/rx_ble.dart';

class ConfigureGateway extends StatefulWidget {
  @override
  BLEManager createState() => BLEManager();
}

class BLEManager extends State<ConfigureGateway> {
  final String gatewayWifiServiceUUID = 'a8a9e49c-aa9a-d441-9bec-817bb4900e40';
  final GlobalKey<BLEManager> _key = GlobalKey<BLEManager>();
  var connectionState = BleConnectionState.disconnected;
  List<Widget> results = [];

  Future<Null> _startScan() async {
    try {
      await for (final scanResult in RxBle.startScan(service: gatewayWifiServiceUUID).timeout(Duration(seconds: 10))) {
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