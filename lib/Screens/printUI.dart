// import 'dart:async';
// import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
// import 'package:esc_pos_utils/esc_pos_utils.dart';
// import 'package:flutter/material.dart';
//
// class PrintPage extends StatefulWidget {
//   @override
//   _PrintPageState createState() => _PrintPageState();
// }
//
// class _PrintPageState extends State<PrintPage> {
//   PrinterBluetoothManager printerManager = PrinterBluetoothManager();
//   List<PrinterBluetooth> _devices = [];
//   bool _isLoading = false;
//   bool _isPrinting = false;
//   PrinterBluetooth? _selectedPrinter;
//
//   @override
//   void initState() {
//     super.initState();
//     _startScan();
//   }
//
//   void _startScan() {
//     setState(() {
//       _isLoading = true;
//     });
//     // Start scanning for devices
//     printerManager.startScan(Duration(seconds: 2));
//     printerManager.scanResults.listen((devices) {
//       setState(() {
//         _devices = devices;
//         _isLoading = false;
//       });
//     });
//   }
//
//   Future<void> _printReceipt(PrinterBluetooth printer) async {
//     setState(() {
//       _isPrinting = true;
//     });
//
//     try {
//       // Ensure the printer is selected
//       printerManager.selectPrinter(printer);
//
//       // Load printer profile and create generator
//       final profile = await CapabilityProfile.load();
//       final paper = PaperSize.mm80; // Adjust based on your printer
//       final generator = Generator(paper, profile);
//
//       // Generate print data
//       final ticket = <int>[];
//       ticket.addAll(generator.text(
//         'Hello World',
//         styles: PosStyles(align: PosAlign.center, bold: true),
//       ));
//       ticket.addAll(generator.feed(2));
//       ticket.addAll(generator.cut());
//
//       // Print data
//       final result = await printerManager.writeBytes(ticket);
//       print("result message : ${result}");
//       // Check print result
//
//       _showMessage('Print result: ${result.msg}');
//
//     } catch (e) {
//       _showMessage('Error printing receipt: $e');
//     } finally {
//       setState(() {
//         _isPrinting = false;
//       });
//     }
//   }
//
//
//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }
//
//   void _disconnectPrinter() {
//     printerManager.stopScan();
//     setState(() {
//       _selectedPrinter = null;
//     });
//     print("Printer disconnected");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(title: Text('Bluetooth Print')),
//         body: _isPrinting
//             ? Center(child: CircularProgressIndicator())
//             : Column(
//             children: [
//               _isLoading
//                   ? Center(child: CircularProgressIndicator())
//                   : _devices.isEmpty
//                   ? Text('No Bluetooth devices found')
//                   : DropdownButton<PrinterBluetooth>(
//                 hint: Text('Select Printer'),
//                 value: _selectedPrinter,
//                 onChanged: (PrinterBluetooth? printer) {
//                   setState(() {
//                     _selectedPrinter = printer;
//                   });
//                 },
//                 items: _devices
//                     .map((device) => DropdownMenuItem(
//                   child: Text(device.name ?? ''),
//                   value: device,
//                 ))
//                     .toList(),
//               ),
//               ElevatedButton(
//                 onPressed: _selectedPrinter != null
//                     ? () {
//                   print("Printer selected: ${_selectedPrinter!.name}");
//                   _printReceipt(_selectedPrinter!);
//                 }
//                     : null, // Button is disabled until a printer is selected
//                 child: Text('Test Select Printer'),
//               ),
//               ElevatedButton(
//                 onPressed: _selectedPrinter != null
//                     ? _disconnectPrinter
//                     : null, // Button is disabled if no printer is selected
//                 child: Text('Disconnect'),
//               ),
//             ],
//            ),
//        );
//     }
// }
