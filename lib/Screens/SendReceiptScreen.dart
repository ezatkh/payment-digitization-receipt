import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
class SendReceiptScreen extends StatefulWidget {
  final int id;  // Add this line

  PrintSettingsScreen({required this.id});  // Update the constructor

  @override
  _SendReceiptScreenState createState() => _SendReceiptScreenState();
}

class _SendReceiptScreenState extends State<SendReceiptScreen> {
  String? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690));
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Text(
              'Choose how to send the receipt:',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],  // Subtle and professional color
                fontFamily: 'NotoSansUI',

                decorationColor: Colors.grey[800],

              ),
            ),

            SizedBox(height: 20.h),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                children: <String>['Email', 'SMS', 'WhatsApp'].map((String method) {
                  return _buildMethodCard(method, _iconForMethod(method), 'Send via $method.');
                }).toList(),
              ),
            ),
            SizedBox(height: 20.h), // Space before the button for better UX
            Center(
              child: _sendButton(),
            ),
            SizedBox(height: 20.h), // Additional space at the bottom
          ],
        ),
      ),
    );
  }


  AppBar _buildAppBar() {
    return AppBar(
      elevation: 4,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(4.0),
        child: Container(
          color: Colors.white.withOpacity(0.2),
          height: 1.0,
        ),
      ),
      title: Text('Send Receipt', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontFamily: 'NotoSansUI')),
      backgroundColor: Color(0xFFC62828),
      leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
    );
  }

  Widget _buildMethodCard(String method, IconData icon, String description) {
    bool isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: isSelected ? 5 : 1,
        child: Container(
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40.sp, color: isSelected ? Theme.of(context).primaryColor : Colors.grey),
              SizedBox(height: 10.h),
              Text(method, style: TextStyle(fontSize: 16.sp, color: isSelected ? Theme.of(context).primaryColor : Colors.black)),
              Text(description, style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sendButton() {
    return ElevatedButton.icon(
      icon: Icon(Icons.send, color: Colors.white), // Icon for sending action
      label: Text('Send Receipt', style: TextStyle(fontSize: 16.sp, color: Colors.white)),
      onPressed:   () => _sendReceipt()  ,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFC62828),
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 50.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5, // Adding some shadow for a 3D effect
      ),
    );
  }


  void _sendReceipt() async {
    try {
      final pdf = pw.Document();

      // Add fake PDF content here
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Container(
              padding: pw.EdgeInsets.all(16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'RECEIPT',
                    style: pw.TextStyle(
                      font: pw.Font.courierBold(),
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  _printLine(pdf, 'Date:', DateFormat('yyyy-MM-dd').format(DateTime.now()), 14),
                  _printLine(pdf, 'Time:', DateFormat('HH:mm:ss').format(DateTime.now()), 14),
                  pw.Divider(color: PdfColors.grey800),
                  _printLine(pdf, 'Customer Name', 'John Doe', 14),
                  _printLine(pdf, 'MSISDN', '1234567890', 14),
                  _printLine(pdf, 'PR#', 'PR20231015', 14),
                  _printLine(pdf, 'Amount', '\$250.00', 14),
                  _printLine(pdf, 'Currency', 'USD', 14),
                  _printLine(pdf, 'Method', 'Credit Card', 14),
                  pw.Divider(color: PdfColors.grey800),
                  pw.Text(
                    'Notes:',
                    style: pw.TextStyle(
                      font: pw.Font.courierBold(),
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Payment for services rendered.',
                    style: pw.TextStyle(
                      font: pw.Font.courier(),
                      fontSize: 14,
                    ),
                  ),
                  pw.Divider(color: PdfColors.grey800),
                  pw.Center(
                    child: pw.Text(
                      '--- Thank You! ---',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: pw.Font.courierBold(),
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Save the PDF file
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/receipt.pdf");
      await file.writeAsBytes(await pdf.save());

      Share.shareFiles(
          [file.path],
          subject: 'Receipt from Your Company',
          text: 'Attached is your receipt.',
          sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1) // Used for iPad sharing dialog positioning
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send receipt: $e')),
      );
    }
  }

  pw.Widget _printLine(pw.Document pdf, String label, String value, double fontSize) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: pw.Font.courierBold(),
            fontSize: fontSize,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: pw.Font.courier(),
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
  IconData _iconForMethod(String method) {
    switch (method) {
      case 'Email':
        return Icons.email;
      case 'SMS':
        return Icons.message;
      case 'WhatsApp':
        return Icons.r_mobiledata_outlined;
      default:
        return Icons.device_unknown;
    }
  }
}
