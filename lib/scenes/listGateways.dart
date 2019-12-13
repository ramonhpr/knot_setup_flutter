import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mdns_plugin/mdns_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ListGateways extends StatefulWidget {
  @override
  StateList createState() => StateList();
}

class KnotGateway implements MDNSPluginDelegate {
  static const String serviceName = "KNoT Gateway on";
  Function onResolved;

  KnotGateway(Function onResolved) {
    this.onResolved = onResolved;
  }

  void onDiscoveryStarted() {
    print("Discovery started");
  }

  void onDiscoveryStopped() {
    print("Discovery stopped");
  }

  bool onServiceFound(MDNSService service) {
    print("Found: $service:${service.port}");
    // Always returns true which begins service resolution
    return true;
  }

  void onServiceResolved(MDNSService service) {
    if (service.name.startsWith(serviceName)) {
      onResolved(service);
    }
  }

  void onServiceUpdated(MDNSService service) {
    print("Updated: $service");
  }

  void onServiceRemoved(MDNSService service) {
    print("Removed: $service");
  }
}

class StateList extends State<ListGateways> {
  static const String serviceType = "_http._tcp";
  final services = <String, MDNSService>{};
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  MDNSPlugin mdns;
  bool isInDevicesRoute = false;
  SharedPreferences prefs;

  Widget _addButton() {
    return FloatingActionButton(
      onPressed: null,
      child: Icon(Icons.add),
    );
  }

  Widget _cardBuilder(BuildContext context, int i) {
    var gatewayIP = services.keys.toList()[i];
    var tmp;
    String expectedRoute = "";
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text("${services[gatewayIP].name}.local"),
            subtitle: Text(gatewayIP),
            trailing: Icon(Icons.wifi_tethering),
            onTap: () async {
              prefs = await SharedPreferences.getInstance();
              String url = "http://${services[gatewayIP].hostName}:${services[gatewayIP].port}";
              String err = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return Scaffold(
                    appBar: AppBar(
                      title: Text(services[gatewayIP].name),
                    ),
                    body: WebView(
                      initialUrl: url,
                      javascriptMode: JavascriptMode.unrestricted,
                      javascriptChannels: <JavascriptChannel>[
                        JavascriptChannel(
                          name: "getToken",
                          onMessageReceived: (JavascriptMessage message) async {
                            String token = jsonDecode(message.message)["ngStorage-token"];
                            if (token != null) {
                              prefs.setString("ngStorage-token", jsonDecode(message.message)["ngStorage-token"]);
                              await tmp.reload();
                            } else {
                              print("not signed");
                            }
                          },
                        ),
                        JavascriptChannel(
                          name: "setToken",
                          onMessageReceived: (JavascriptMessage message) async {

                          }
                        )
                      ].toSet(),
                      onWebViewCreated: (WebViewController ctl) async {
                        if (!_controller.isCompleted) _controller.complete(ctl);
                        tmp = ctl;
                      },
                      onPageFinished: (String url) async {
                        print("finished $url");
                        String token = prefs.getString("ngStorage-token") ?? "";

                        if (token.isEmpty) {
                          print('entrou');
                          await tmp.evaluateJavascript(
                          'getToken.postMessage(JSON.stringify(sessionStorage))'
                          );
                        } else {
                          print("expected route = $expectedRoute");
                          if (expectedRoute.isEmpty) {
                            String hasToken = await tmp.evaluateJavascript(
                              'sessionStorage.getItem("ngStorage-token")'
                              );
                            print('hastoken = ${hasToken=="null"}');
                            
                            if (hasToken == "null") {
                              await tmp.evaluateJavascript(
                              'sessionStorage.setItem("ngStorage-token", ${json.encode(token)})'
                              );
                              expectedRoute = 'devices';
                              await tmp.reload();
                            }
                          } else {
                            if (!url.endsWith(expectedRoute)) {
                              prefs.remove('ngStorage-token');
                              expectedRoute = "";
                            } else if (url.endsWith('devices')) {
                              setState(() {
                                isInDevicesRoute = true;
                              });
                            }
                          }
                          // await fetch("http://knot.local/api/me", { headers : { 'Authorization': 'Bearer $token'}})
                        }
                      },
                    ),
                    floatingActionButton: isInDevicesRoute ? _addButton() : null,
                  );
                }),
              );
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

  void _onResolved(MDNSService service) {
    print("Resolved: $service");
    setState(() {
      services[service.hostName] = service;
    });
  }

  void _list() async {
    mdns = new MDNSPlugin(KnotGateway(_onResolved));
    await mdns.startDiscovery(serviceType, enableUpdating: true);
  }

  @override
  void initState() {
    super.initState();
    _list();
  }

  @override
  void dispose() async {
    await mdns.stopDiscovery();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: services.length,
      itemBuilder: _cardBuilder,
    );
  }
}
