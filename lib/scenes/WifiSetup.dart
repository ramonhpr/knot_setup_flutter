import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:rx_ble/rx_ble.dart';

class WifiSetup extends StatefulWidget {
  final String deviceId;

  WifiSetup({Key key, @required this.deviceId}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      WifiSetupState(deviceId: this.deviceId);
}

class WifiSetupState extends State<WifiSetup> {
  static const String SSID_UUID_CHAR = 'a8a9e49c-aa9a-d441-9bec-817bb4900d41';
  static const String PSWD_UUID_CHAR = 'a8a9e49c-aa9a-d441-9bec-817bb4900d42';
  final _formKey = GlobalKey();
  final String deviceId;
  TextEditingController _ssidController;
  TextEditingController _pswdController;
  bool buttonDisabled = true;
  bool showProgress = false;
  bool passwordVisible = true;

  WifiSetupState({@required this.deviceId}) : super();

  @override
  void initState() {
    super.initState();
    _ssidController = TextEditingController();
    _pswdController = TextEditingController();
    Connectivity().getWifiName().then((value) {
      _ssidController.text = value;
    });
  }

  TextFormField _renderTextField(
      String label, TextInputType type, TextEditingController controller,
      {ValueChanged<String> onChanged, FormFieldValidator<String> validator, bool isSuffixVisible, Function onSuffixPressed}) {
    return TextFormField(
      keyboardType: type,
      controller: controller,
      obscureText: type == TextInputType.visiblePassword && !isSuffixVisible,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isSuffixVisible ? Icons.visibility : Icons.visibility_off,
            semanticLabel: isSuffixVisible ? 'hide password' : 'show password',
          ),
          onPressed: onSuffixPressed,
        ),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }

  String _validatePassword(String value) {
    if (value.isEmpty) return 'Please enter password';
    return null;
  }

  void _onButtonPressed() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() => buttonDisabled = true);
    setState(() => showProgress = true);

    try {
      await for (final state in RxBle.connect(deviceId)) {
        print("device state: $state");
        var deviceState = await RxBle.getConnectionState(deviceId);
        if (deviceState == BleConnectionState.connected) {
          await RxBle.writeChar(
            deviceId,
            SSID_UUID_CHAR,
            RxBle.stringToChar(_ssidController.text),
          );
          await RxBle.writeChar(
            deviceId,
            PSWD_UUID_CHAR,
            RxBle.stringToChar(_pswdController.text),
          );
          await RxBle.disconnect(deviceId: deviceId);
          setState(() => showProgress = false);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print(e);
      Navigator.pop(context, "Unexpected error ocorred on bluetooth connection");
    }
  }

  Widget _showProgressIndication() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('Connecting...'),
        SizedBox(
          height: 15,
          width: 15,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }

  Form _renderForm() {
    return Form(
      key: _formKey,
      autovalidate: true,
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 50),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: _renderTextField(
              "Network Name",
              TextInputType.text,
              _ssidController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: _renderTextField(
              "Password",
              TextInputType.visiblePassword,
              _pswdController,
              validator: _validatePassword,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() => buttonDisabled = false);
                }
              },
              isSuffixVisible: passwordVisible,
              onSuffixPressed: () {
                setState(() {
                  passwordVisible = !passwordVisible;
                });
              },
            ),
          ),
          RaisedButton(
            onPressed: buttonDisabled ? null : _onButtonPressed,
            child: showProgress ? _showProgressIndication() : Text('Connect'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wifi configure page',
      theme: ThemeData(primarySwatch: Colors.green),
      home: Scaffold(
          appBar: AppBar(
            title: Text('Configure Gateway Wifi'),
          ),
          body: Center(
            child: _renderForm(),
          )),
    );
  }
}
