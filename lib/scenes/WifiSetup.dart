import 'package:flutter/material.dart';

class WifiSetup extends StatefulWidget {
  final String deviceId;

  WifiSetup({Key key, @required this.deviceId}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      WifiSetupState(deviceId: this.deviceId);
}

class WifiSetupState extends State<WifiSetup> {
  final _formKey = GlobalKey();
  final String deviceId;
  TextEditingController _ssidController;
  TextEditingController _pswdController;

  WifiSetupState({@required this.deviceId}) : super();

  @override
  void initState() {
    super.initState();
    _ssidController = TextEditingController();
    _pswdController = TextEditingController();
  }

  TextFormField _renderTextField(
      String label, TextInputType type, TextEditingController controller,
      {ValueChanged<String> onChanged, FormFieldValidator<String> validator}) {
    return TextFormField(
      keyboardType: type,
      controller: controller,
      obscureText: type == TextInputType.visiblePassword,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(),
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
            ),
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
