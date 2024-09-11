import 'package:flutter/material.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class BluetoothPrintService {
  final BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  BluetoothDevice? _device;
  bool _connected = false;

  BluetoothPrintService() {
    bluetoothPrint.state.listen((state) {
      print('Current device status: $state');
      switch (state) {
        case BluetoothPrint.CONNECTED:
          _connected = true;
          break;
        case BluetoothPrint.DISCONNECTED:
          _connected = false;
          break;
        default:
          break;
      }
    });
  }

  Future<void> startScan() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 4));
  }

  Stream<List<BluetoothDevice>> getScanResults() {
    return bluetoothPrint.scanResults;
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await bluetoothPrint.connect(device);
      _device = device;
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }

  Future<void> disconnect() async {
    try {
      await bluetoothPrint.disconnect();
      _device = null;
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }

  Future<void> printReceipt() async {
    if (_device == null) return;

    Map<String, dynamic> config = {};
    List<LineText> list = [];

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'A Title',
        weight: 1,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'This is content left',
        weight: 0,
        align: LineText.ALIGN_LEFT,
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'This is content right',
        align: LineText.ALIGN_RIGHT,
        linefeed: 1));
    list.add(LineText(linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_BARCODE,
        content: 'A12312112',
        size: 10,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    list.add(LineText(linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_QRCODE,
        content: 'qrcode i',
        size: 10,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    list.add(LineText(linefeed: 1));

    ByteData data = await rootBundle.load("assets/images/guide3.png");
    List<int> imageBytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    String base64Image = base64Encode(imageBytes);
    list.add(LineText(
        type: LineText.TYPE_IMAGE,
        content: base64Image,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));

    await bluetoothPrint.printReceipt(config, list);
  }

  Future<void> printLabel() async {
    if (_device == null) return;

    Map<String, dynamic> config = {
      'width': 40,
      'height': 70,
      'gap': 2
    };

    List<LineText> list = [];
    list.add(LineText(type: LineText.TYPE_TEXT, x: 10, y: 10, content: 'A Title'));
    list.add(LineText(type: LineText.TYPE_TEXT, x: 10, y: 40, content: 'This is content'));
    list.add(LineText(type: LineText.TYPE_QRCODE, x: 10, y: 70, content: 'qrcode i\n'));
    list.add(LineText(type: LineText.TYPE_BARCODE, x: 10, y: 190, content: 'barcode i\n'));

    ByteData data = await rootBundle.load("assets/images/guide3.png");
    List<int> imageBytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    String base64Image = base64Encode(imageBytes);
    List<LineText> list1 = [
      LineText(type: LineText.TYPE_IMAGE, x: 10, y: 10, content: base64Image)
    ];

    await bluetoothPrint.printLabel(config, list);
    await bluetoothPrint.printLabel(config, list1);
  }
}
