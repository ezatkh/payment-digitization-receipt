import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'BlutoothService.dart'; // Adjust path

class PrintPage extends StatefulWidget {
  @override
  _PrintPageState createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  final BluetoothPrintService _printService = BluetoothPrintService();
  BluetoothDevice? _selectedDevice;

  @override
  void initState() {
    super.initState();
    _printService.startScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bluetooth Print')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<BluetoothDevice>>(
              stream: _printService.getScanResults(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No devices found.'));
                }

                return ListView(
                  children: snapshot.data!.map((device) {
                    return ListTile(
                      title: Text(device.name ?? 'Unknown'),
                      subtitle: Text(device.address.toString()),
                      onTap: () async {
                        setState(() {
                          _selectedDevice = device;
                        });
                        await _printService.connectToDevice(device);
                      },
                      trailing: _selectedDevice?.address == device.address
                          ? Icon(Icons.check, color: Colors.green)
                          : null,
                    );
                  }).toList(),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _printService.printReceipt();
            },
            child: Text('Print Receipt'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _printService.printLabel();
            },
            child: Text('Print Label'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _printService.disconnect();
            },
            child: Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}
