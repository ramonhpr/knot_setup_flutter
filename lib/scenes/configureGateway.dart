import 'package:flutter/material.dart';
import 'package:knot_setup_flutter/scenes/WifiSetup.dart';
import 'package:rx_ble/rx_ble.dart';

class ConfigureGateway extends StatefulWidget {
  @override
  BLEManager createState() => BLEManager();
}

class BLEManager extends State<ConfigureGateway> {
  final String gatewayWifiServiceUUID = 'a8a9e49c-aa9a-d441-9bec-817bb4900e40';
  final GlobalKey<BLEManager> _key = GlobalKey<BLEManager>();
  var connectionState = BleConnectionState.disconnected;
  final results = <String, ScanResult>{};

  Future<Null> _startScan() async {
    try {
      await for (final scanResult in RxBle.startScan(service: gatewayWifiServiceUUID).timeout(Duration(seconds: 10))) {
        setState(() => results[scanResult.deviceId] = scanResult);
      }
    } catch (e) {
      print(e);
    }
  }

  Widget _renderMessageNotFound() {
    return ListView(
      padding: const EdgeInsets.only(top: 180),
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.bluetooth, size: 80.0),
            Text('No devices found'),
          ],
        ),
      ],
    );
  }

  Widget _cardBuilder(BuildContext context, int i) {
    var deviceId = results.keys.toList()[i];
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(results[deviceId].deviceName),
            subtitle: Text(deviceId),
            trailing: Column(
              children: <Widget>[
                Icon(Icons.bluetooth),
                Text(results[deviceId].rssi.toString()),
              ],
            ),
            onTap: () async {
              RxBle.stopScan();
              String err = await Navigator.push(context, MaterialPageRoute(builder: (context) => WifiSetup(deviceId: deviceId)));
              if (err != null && err.isNotEmpty) {
                Scaffold.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text("$err")));
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    RxBle.requestAccess();
  }

  @override
  void dispose() {
    RxBle.stopScan();
    for (var deviceId in results.keys) {
      RxBle.disconnect(deviceId: deviceId);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _key,
      onRefresh: _startScan,
      child: results.isEmpty ? _renderMessageNotFound() : ListView.builder(
        itemCount: results.length,
        itemBuilder: _cardBuilder,
      ),
    );
  }
}