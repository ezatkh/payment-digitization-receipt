import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Services/LocalizationService.dart';
import 'package:provider/provider.dart';
import 'PrintSettingsScreen.dart';
import 'SendReceiptScreen.dart';

class PrintReceiptScreen extends StatefulWidget {
  @override
  _PrintReceiptScreenState createState() => _PrintReceiptScreenState();
}

class _PrintReceiptScreenState extends State<PrintReceiptScreen> {
  List<Map<String, dynamic>> receipts = [
    {
      'voucherNumber': 'W-12345',
      'transactionDate': DateTime.now().subtract(Duration(days: 1)),
      'amount': '150 USD',
      'synced': true,
      'selected': false,
    },
    {
      'voucherNumber': 'W-12346',
      'transactionDate': DateTime.now().subtract(Duration(days: 2)),
      'amount': '200 USD',
      'synced': false,
      'selected': false,
    },
    {
      'voucherNumber': 'W-12347',
      'transactionDate': DateTime.now(),
      'amount': '250 USD',
      'synced': true,
      'selected': false,
    },
  ];

  // Variables for localized strings
  String printReceipt = '';
  String searchByFilterNumber ='';
  String voucher ='';
  String amount ='';
  String sendSelected ='';
  String printSelected ='';
  String receiptDate ='';

  void _initializeLocalizationStrings() {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    printReceipt = localizationService.getLocalizedString('printreceipt');
    searchByFilterNumber = localizationService.getLocalizedString('filterNumber');
    voucher = localizationService.getLocalizedString('voucher');
    amount = localizationService.getLocalizedString('amount');
    sendSelected = localizationService.getLocalizedString('sendSelected');
    printSelected = localizationService.getLocalizedString('printSelected');
    receiptDate = localizationService.getLocalizedString('date');

  }

  @override
  void initState() {
    super.initState();
    // Initialize the localization strings
    _initializeLocalizationStrings();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690));
    return Scaffold(
      appBar: _buildAppBar(printReceipt), // Use the AppBar method here
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildFilterOptions(searchByFilterNumber),
            ListView.builder(
              itemCount: receipts.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => _buildReceiptCard(receipts[index], index,amount,voucher,receiptDate),
            ),
            _buildActionButtons(printSelected,sendSelected),
          ],
        ),
      ),
      backgroundColor: Color(0xFFF9F9F9),
    );
  }

  AppBar _buildAppBar(String printReceipt ) {
    return AppBar(
      elevation: 4,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(4.0),
        child: Container(
          color: Colors.white.withOpacity(0.2),
          height: 1.0,
        ),
      ),
      title: Text(printReceipt,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontFamily: 'NotoSansUI',
          )),
      backgroundColor: Color(0xFFC62828),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildFilterOptions(String voucherNumber) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: voucherNumber,
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Adjust border radius here
                  borderSide: BorderSide(
                    color: Colors.red, // Example color, you can change it to your preference
                    width: 2.0, // Width of the border
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Adjust border radius here
                  borderSide: BorderSide(
                    color: Colors.black, // Example color, you can change it to your preference
                    width: 2.0, // Width of the border
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Adjust border radius here
                  borderSide: BorderSide(
                    color: Colors.red, // Example color, you can change it to your preference
                    width: 2.0, // Width of the border
                  ),
                ),
              ),
              style: TextStyle(
                color: Colors.black87, // Adjust text color here
                fontSize: 16.0, // Adjust font size
              ),
              onChanged: (value) {
                // Filter logic here
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildReceiptCard(Map<String, dynamic> receipt, int index, String amountLabel,String voucherLabel , String dateLabel) {
    return Card(
      elevation: 5,
      shadowColor: Colors.grey.withOpacity(0.5),
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: ListTile(
        leading: Checkbox(
          value: receipt['selected'],
          onChanged: (bool? value) {
            setState(() {
              receipts[index]['selected'] = value!;
            });
          },
        ),
        title: Text('$voucherLabel: ${receipt['voucherNumber']}'),
        subtitle: Text('$amountLabel: ${receipt['amount']}           $dateLabel: ${receipt['transactionDate'].toString().split(' ')[0]}'),
        trailing: Wrap(
          spacing: 1, // space between two icons
          children: <Widget>[
            Icon(receipt['synced'] ? Icons.check_circle : Icons.error, color: receipt['synced'] ? Colors.green : Colors.red),
            IconButton(
              icon: Icon(Icons.print),
              onPressed: receipt['synced'] ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrintSettingsScreen()),
                );
              } : null,
            ),

            IconButton(
              icon: Icon(Icons.send),
              onPressed: _sendReceipt
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(String printSelected , String sendSelected) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(  // Use Expanded widget
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),  // Add padding to ensure some space between buttons
              child: ElevatedButton(
                onPressed: _printSelectedReceipts,
                child: Text(printSelected, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC62828),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                  elevation: 5,
                  shadowColor: Colors.black.withOpacity(0.2),
                  textStyle: TextStyle(letterSpacing: 1.2),
                ),
              ),
            ),
          ),
          Expanded(  // Use Expanded widget
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),  // Add padding to ensure some space between buttons
              child: ElevatedButton(
                onPressed: _sendReceipt,
                child: Text(sendSelected, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                  elevation: 5,
                  shadowColor: Colors.black.withOpacity(0.2),
                  textStyle: TextStyle(letterSpacing: 1.2),
                ),
              ),
            ),
          ),
        ],
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

  void _printReceipt(Map<String, dynamic> receipt) {

  }

  void _printSelectedReceipts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PrintSettingsScreen()),
    );
  }

  void _sendSelectedReceipts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SendReceiptScreen()),
    );
  }
}
