import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class PrintPage extends StatefulWidget {
  @override
  _PrintPageState createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bluetooth Print')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
            },
            child: Text('Print Label'),
          ),
          ElevatedButton(
            onPressed: () async {
            },
            child: Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}
