import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../Models/Payment.dart';
import '../Services/LocalizationService.dart';
import 'package:provider/provider.dart';
import 'package:number_to_word_arabic/number_to_word_arabic.dart';
import 'package:number_to_words_english/number_to_words_english.dart';

import '../Services/database.dart';


class PrintSettingsScreen extends StatefulWidget {
  final int id;  // Add this line

  PrintSettingsScreen({required this.id});  // Update the constructor

  @override
  _PrintSettingsScreenState createState() => _PrintSettingsScreenState();
}

class _PrintSettingsScreenState extends State<PrintSettingsScreen> {
  Payment? _payment;
  int _numCopies = 1;
  bool _duplex = false;
  String _paperSize = 'A4';
  List<String> _paperSizes = ['A4', 'A5', 'Letter', 'Legal'];
  bool _colorPrint = false;
  bool _isReceiptExpanded = true;  // New state variable

  String print = '';
  String cancel = '';
  String copies = '';
  String  colorPrinting= '';
  String  duplexPrinting= '';
  String  numberCopies= '';
  String  hideReceipt= '';
  String  showReceipt= '';
  String  printSettings= '';
  String languageCode="";


  String receipt ='';
  String date ='';
  String time ='';
  String customerName ='';
  String MSISDN ='';
  String PR ='';
  String paymentMethod ='';
  String amount ='';
  String currency ='';
  String theSumOf ='';
  String notes ='';
  String thankYou ='';



  void _initializeLocalizationStrings() {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    print = localizationService.getLocalizedString('print');
    cancel = localizationService.getLocalizedString('cancel');
    copies = localizationService.getLocalizedString('copies');
    colorPrinting = localizationService.getLocalizedString('colorPrinting');
    numberCopies = localizationService.getLocalizedString('duplexPrinting');
    duplexPrinting = localizationService.getLocalizedString('duplexPrinting');
    numberCopies = localizationService.getLocalizedString('numberCopies');
    hideReceipt = localizationService.getLocalizedString('hideReceipt');
    showReceipt = localizationService.getLocalizedString('showReceipt');
    printSettings = localizationService.getLocalizedString('printSettings');
    receipt = localizationService.getLocalizedString('receipt');
    date = localizationService.getLocalizedString('date');
    time = localizationService.getLocalizedString('time');
    customerName = localizationService.getLocalizedString('customerName');
    MSISDN = localizationService.getLocalizedString('MSISDN');
    PR = localizationService.getLocalizedString('PR');
    paymentMethod = localizationService.getLocalizedString('paymentMethod');
    amount = localizationService.getLocalizedString('amount');
    currency = localizationService.getLocalizedString('currency');
    notes = localizationService.getLocalizedString('notes');
    thankYou = localizationService.getLocalizedString('thankYou');
    theSumOf = localizationService.getLocalizedString('theSumOf');
    languageCode = localizationService.selectedLanguageCode;

  }

  Future<void> _loadPaymentData() async {
    Payment? payment = await fetchPayment(widget.id);
    setState(() {
      _payment = payment;
    });
  }
  @override
  void initState() {
    super.initState();
    // Initialize the localization strings
    _initializeLocalizationStrings();
    _loadPaymentData();
  }

  @override
  Widget build(BuildContext context) {
    if (_payment == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    ScreenUtil.init(context, designSize: Size(360, 690));
    return Scaffold(
      appBar: _buildAppBar(printSettings),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 10.h),
            _buildPreviewCard(),
            SizedBox(height: 20.h),
            _buildCopiesSection(copies,numberCopies),
            _buildPaperSizeDropdown(),
            _buildPrintingOptions(duplexPrinting,colorPrinting),
            _buildActionButtons(cancel , print),
          ],
        ),
      ),
    );
  }
  Widget _buildPrintingOptions(String dublexPrint, String colorPrinting) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),

      ),
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        children: [
          _buildSwitchListTile(dublexPrint, _duplex, (bool value) {
            setState(() { _duplex = value; });
          }),
          _buildDivider(),
          _buildSwitchListTile(colorPrinting, _colorPrint, (bool value) {
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


  AppBar _buildAppBar(String printSettings) {
    return AppBar(
      elevation: 4,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(4.0),
        child: Container(
          color: Colors.white.withOpacity(0.2),
          height: 1.0,
        ),
      ),
      title: Text(printSettings, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontFamily: 'NotoSansUI')),
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
          Center(child: _buildExpandReceiptButton(hideReceipt,showReceipt)),

          if (_isReceiptExpanded) _buildFullReceipt(),  // Only build the full receipt if expanded
        ],
      ),
    );
  }

  Widget _buildExpandReceiptButton(String hideReceipt, String showReceipt) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: TextButton.icon(
        icon: Icon(
          _isReceiptExpanded ? Icons.expand_less : Icons.expand_more,
          color: Color(0xFFC62828),
        ),
        label: Text(
          _isReceiptExpanded ? hideReceipt : showReceipt,
          style: TextStyle(     fontWeight: FontWeight.bold,
              fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
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
            receipt,
            style: TextStyle(
              fontFamily: 'CourierPrime',
              fontWeight: FontWeight.bold,
              fontSize: 24.sp,
            ),
          ),
          SizedBox(height: 12.h),
          _printLine(
              "$date:",
              _payment?.transactionDate != null
                  ? DateFormat('yyyy-MM-dd HH:mm:ss').format(_payment!.transactionDate!)
                  : 'N/A'
          ),          SizedBox(height: 12.h),
          Divider(color: Colors.grey[800]),
          _printLine("$customerName:", _payment!.customerName),
          _printLine('MSISDN:', (_payment!.msisdn != null && _payment!.msisdn.toString().length >1) ?  _payment!.msisdn.toString() : 'N/A'),
          _printLine('$PR:',(_payment!.prNumber != null && _payment!.prNumber.toString().length >1) ? _payment!.prNumber.toString() : 'N/A'),

          _printLine('$paymentMethod:', _payment!.paymentMethod.toString()),
          if(_payment!.paymentMethod.toString().toLowerCase() =='cash' ) ...[
          _printLine('$amount:', _payment!.amount.toString()),
          _printLine('$currency:', _payment!.currency.toString()),
          ],
          if(_payment!.paymentMethod.toString().toLowerCase() =='check' ) ...[
            _printLine('$amount:', _payment!.amount.toString()),
            _printLine('$amount:', _payment!.amountCheck.toString()),
            _printLine('$amount:', _payment!.bankBranch.toString()),
            _printLine('$amount:',_payment?.dueDateCheck != null
                ? DateFormat('yyyy-MM-dd').format(_payment!.dueDateCheck!)
                : 'N/A'),
          ],
          Divider(color: Colors.grey[800]),
          Text('$theSumOf:', style: TextStyle(fontFamily: 'CourierPrime', fontSize: 14.sp, fontWeight: FontWeight.bold)),
          Text((languageCode) == 'ar' ? Tafqeet.convert((_payment!.paymentMethod.toLowerCase() == 'cash') ? _payment!.amount.toString() : _payment!.amountCheck.toString()) : NumberToWordsEnglish.convert((_payment!.paymentMethod.toLowerCase() == 'cash')? _payment!.amount!.toInt() :_payment!.amountCheck!.toInt()), style: TextStyle(fontFamily: 'CourierPrime', fontSize: 14.sp)),
          Divider(color: Colors.grey[800]),
          if(_payment!.paymentInvoiceFor != null)
          Text('$notes:', style: TextStyle(fontFamily: 'CourierPrime', fontSize: 14.sp, fontWeight: FontWeight.bold)),
          if(_payment!.paymentInvoiceFor != null)
          Text('${_payment!.paymentInvoiceFor}:', style: TextStyle(fontFamily: 'CourierPrime', fontSize: 14.sp, fontWeight: FontWeight.bold)),
          if(_payment!.paymentInvoiceFor != null)
            Divider(color: Colors.grey[800]),
          Center(
            child: Text(
              thankYou,
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

  Widget _buildCopiesSection(String copies , String numberCopies) {
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
            numberCopies,
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
              Text(copies+":", style: Theme.of(context).textTheme.titleMedium),
              Spacer(),
              Text('$_numCopies', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
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
  Widget _buildActionButtons(String cancel , String print) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _styledElevatedButton(
            text: cancel,
            color: Colors.grey.shade400,
            onPressed: () => Navigator.pop(context),
            isPrimary: false,
          ),
          _styledElevatedButton(
            text: print,
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

  Future<Payment?> fetchPayment(int id) async {
    try {
      // Get the payment data from the database
      final paymentData = await DatabaseProvider.getPaymentById(id);

      if (paymentData != null) {
        // Create a Payment instance from the fetched data
        return Payment.fromMap(paymentData);
      } else {
      //  print("No payment found with id $id");
        return null;
      }
    } catch (e) {
     // print('Error fetching payment: $e');
      return null;
    }
  }


}