import 'package:flutter/material.dart';
import './scenes/configureGateway.dart';

void main() => runApp(Main());

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KNoT Setup App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('KNoT Setup'),
            bottom: TabBar(
              tabs: [
                Tab(child: Text('Configure WIFI')),
                Tab(child: Text('Gateways connected')),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ConfigureGateway(),
              Text('On page connected gateways'),
            ],
          ),
        ),
      ),
    );
  }
}
