import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart'; // If you're using this for formatting dates

class PrintSettingsScreen extends StatefulWidget {
  @override
  _PrintSettingsScreenState createState() => _PrintSettingsScreenState();
}

class _PrintSettingsScreenState extends State<PrintSettingsScreen> {
  int _numCopies = 1;
  bool _duplex = false;
  String _paperSize = 'A4';
  List<String> _paperSizes = ['A4', 'A5', 'Letter', 'Legal'];
  bool _colorPrint = false;
  bool _isReceiptExpanded = true;  // New state variable

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690));
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 10.h),
            _buildPreviewCard(),
            SizedBox(height: 20.h),
            _buildCopiesSection(),
            _buildPaperSizeDropdown(),
            _buildPrintingOptions(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }
  Widget _buildPrintingOptions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),

      ),
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        children: [
          _buildSwitchListTile('Duplex Printing', _duplex, (bool value) {
            setState(() { _duplex = value; });
          }),
          _buildDivider(),
          _buildSwitchListTile('Color Printing', _colorPrint, (bool value) {
            setState(() { _colorPrint = value; });
          }),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16.w,
      endIndent: 16.w,
    );
  }

  Widget _buildPaperSizeDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      margin: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 5),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,  // Aligns the dropdown menu with the button
          child: DropdownButton<String>(
            value: _paperSize,
            isExpanded: true,  // Ensures the dropdown takes the full width of its parent
            icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),
            iconSize: 24,  // Adjusts the size of the dropdown icon
            onChanged: (String? newValue) {
              setState(() {
                _paperSize = newValue!;
              });
            },
            items: _paperSizes.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(fontSize: 16.sp, fontFamily: 'NotoSansUI')),
              );
            }).toList(),
            style: TextStyle(color: Colors.black87, fontSize: 16.sp, fontFamily: 'NotoSansUI'),
            dropdownColor: Colors.white,
          ),
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
      title: Text('Print Settings', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontFamily: 'NotoSansUI')),
      backgroundColor: Color(0xFFC62828),
      leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
    );
  }

  Widget _buildPreviewCard() {
    return Container(  decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 5),
      ],
    ),
      child: Column(

        children: [
          Center(child: _buildExpandReceiptButton()),

          if (_isReceiptExpanded) _buildFullReceipt(),  // Only build the full receipt if expanded
        ],
      ),
    );
  }

  Widget _buildExpandReceiptButton() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: TextButton.icon(
        icon: Icon(
          _isReceiptExpanded ? Icons.expand_less : Icons.expand_more,
          color: Color(0xFFC62828),
        ),
        label: Text(
          _isReceiptExpanded ? 'Hide Receipt' : 'Show Receipt',
          style: TextStyle(     fontWeight: FontWeight.bold,          fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
              fontFamily: 'NotoSansUI',color: Color(0xFFC62828)),
        ),
        onPressed: () {
          setState(() {
            _isReceiptExpanded = !_isReceiptExpanded;
          });
        },
      ),
    );
  }

  Widget _buildFullReceipt() {
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Simulate receipt paper color
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECEIPT',
            style: TextStyle(
              fontFamily: 'CourierPrime',
              fontWeight: FontWeight.bold,
              fontSize: 24.sp,
            ),
          ),
          SizedBox(height: 12.h),
          _printLine('Date:', DateFormat('yyyy-MM-dd').format(DateTime.now())),
          _printLine('Time:', DateFormat('HH:mm:ss').format(DateTime.now())),
          SizedBox(height: 12.h),
          Divider(color: Colors.grey[800]),
          _printLine('Customer Name', 'John Doe'),
          _printLine('MSISDN', '1234567890'),
          _printLine('PR#', 'PR20231015'),
          _printLine('Amount', '\$250.00'),
          _printLine('Currency', 'USD'),
          _printLine('Method', 'Credit Card'),
          Divider(color: Colors.grey[800]),
          Text('Notes:', style: TextStyle(fontFamily: 'CourierPrime', fontSize: 14.sp, fontWeight: FontWeight.bold)),
          Text('Payment for services rendered.', style: TextStyle(fontFamily: 'CourierPrime', fontSize: 14.sp)),
          Divider(color: Colors.grey[800]),
          Center(
            child: Text(
              '--- Thank You! ---',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'CourierPrime',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _printLine(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(fontFamily: 'CourierPrime', fontSize: 14.sp, fontWeight: FontWeight.bold)),
          ),
          Text(value, style: TextStyle(fontFamily: 'CourierPrime', fontSize: 14.sp)),
        ],
      ),
    );
  }






  Widget _buildCopiesSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select the number of copies:',
            style: TextStyle(
              fontFamily: 'NotoSansUI',
              fontWeight: FontWeight.bold,
              fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
              color: Theme.of(context).textTheme.titleMedium?.color,
              // You can continue to apply other properties from titleMedium if needed
            ),
          ),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Theme.of(context).primaryColor,
              thumbColor: Theme.of(context).primaryColor,
              overlayColor: Theme.of(context).primaryColor.withAlpha(32),
              valueIndicatorTextStyle: TextStyle(  fontFamily: 'NotoSansUI',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Slider(
              value: _numCopies.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$_numCopies',
              onChanged: (double value) {
                setState(() {
                  _numCopies = value.toInt();
                });
              },
            ),
          ),
          Row(
            children: [
              Text('Copies:', style: Theme.of(context).textTheme.subtitle1),
              Spacer(),
              Text('$_numCopies', style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchListTile(String title, bool value, Function(bool) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),

      ),
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: SwitchListTile(
        title: Text(title, style: TextStyle(  fontFamily: 'NotoSansUI',fontWeight: FontWeight.bold)),
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      ),
    );
  }
  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _styledElevatedButton(
            text: 'Cancel',
            color: Colors.grey.shade400,
            onPressed: () => Navigator.pop(context),
            isPrimary: false,
          ),
          _styledElevatedButton(
            text: 'Print',
            color: Theme.of(context).primaryColor,
            onPressed: () {
              generateAndPrintReceipt();
            },
            isPrimary: true,
          ),
        ],
      ),
    );
  }
  Future<void> generateAndPrintReceipt() async {
    final pdf = pw.Document();
    final now = DateTime.now();
    const double fontSize = 14.0;
    const double titleFontSize = 24.0;
    const double paddingValue = 16.0;

    // Build the PDF page
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Container(
          padding: pw.EdgeInsets.all(paddingValue),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('RECEIPT', style: pw.TextStyle(font: pw.Font.courierBold(), fontSize: titleFontSize)),
              pw.SizedBox(height: paddingValue),
              _printLine2(pdf, 'Date:', DateFormat('yyyy-MM-dd').format(now), fontSize),
              _printLine2(pdf, 'Time:', DateFormat('HH:mm:ss').format(now), fontSize),
              pw.Divider(color: PdfColors.grey),
              _printLine2(pdf, 'Customer Name', 'John Doe', fontSize),
              _printLine2(pdf, 'MSISDN', '1234567890', fontSize),
              _printLine2(pdf, 'PR#', 'PR20231015', fontSize),
              _printLine2(pdf, 'Amount', '\$250.00', fontSize),
              _printLine2(pdf, 'Currency', 'USD', fontSize),
              _printLine2(pdf, 'Method', 'Credit Card', fontSize),
              pw.Divider(color: PdfColors.grey),
              pw.Text('Notes:', style: pw.TextStyle(font: pw.Font.courierBold(), fontSize: fontSize)),
              pw.Text('Payment for services rendered.', style: pw.TextStyle(font: pw.Font.courier(), fontSize: fontSize)),
              pw.Divider(color: PdfColors.grey),
              pw.Center(
                child: pw.Text(
                  '--- Thank You! ---',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: pw.Font.courierBold(), fontSize: titleFontSize),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Trigger the printing process
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Widget _printLine2(pw.Document pdf, String label, String value, double fontSize) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(label, style: pw.TextStyle(font: pw.Font.courierBold(), fontSize: fontSize)),
          ),
          pw.Text(value, style: pw.TextStyle(font: pw.Font.courier(), fontSize: fontSize)),
        ],
      ),
    );
  }

  Widget _styledElevatedButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'NotoSansUI',
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: isPrimary ? Colors.white : Colors.black,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 40.w),
      ),
    );
  }


}
