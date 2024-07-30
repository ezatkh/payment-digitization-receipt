import 'dart:typed_data'; // Import the dart:typed_data library
import 'package:flutter/material.dart';
import 'package:flutter_social_content_share/flutter_social_content_share.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Services/database.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class ShareScreenOptions extends StatefulWidget {
  final int idToShare;

  ShareScreenOptions({required this.idToShare});

  @override
  _ShareScreenOptionsState createState() => _ShareScreenOptionsState();
}

class _ShareScreenOptionsState extends State<ShareScreenOptions> {
  Map<String, dynamic>? paymentDetails;

  @override
  void initState() {
    super.initState();
    _fetchPaymentDetails();
  }

  Future<void> _fetchPaymentDetails() async {
    try {
      // Assuming you have a method to fetch payment details by ID
      // Replace this with your actual implementation
      paymentDetails = await DatabaseProvider.getPaymentById(widget.idToShare);
      if (paymentDetails != null) {
        print(paymentDetails);
        setState(() {});
      } else {
        print('No payment details found for ID ${widget.idToShare}');
      }
    } catch (e) {
      print('Error fetching payment details: $e');
    }
  }

  void _shareEmail() async {
    String? result = await FlutterSocialContentShare.shareOnEmail(
      recipients: ["example@example.com"],
      subject: "Subject appears here",
      body: "Body appears here",
      isHTML: true,
    );
    print(result);
  }

  Future<void> _shareWhatsApp() async {
    if (paymentDetails == null) return;

    // // Sharing text message via WhatsApp
    String message = 'Payment details';
    final pdfBytes = await preparePDFFile();
    String? result = await FlutterSocialContentShare.shareOnWhatsapp(
      "0000000",
      message,
    );
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Share Options',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  _buildCustomDivider(), // Custom divider
                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.solidEnvelope),
                    title: Text(
                      'Share via Email',
                      style: TextStyle(fontSize: 14.0), // Reduced font size
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _shareEmail();
                    },
                  ),
                  _buildCustomDivider(), // Custom divider
                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                    title: Text(
                      'Share via WhatsApp',
                      style: TextStyle(fontSize: 14.0), // Reduced font size
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _shareWhatsApp();
                    },
                  ),
                  _buildCustomDivider(), // Custom divider
                  ListTile(
                    leading: Icon(Icons.print, color: Colors.blue), // Default Flutter icon for Printer
                    title: Text(
                      'Print',
                      style: TextStyle(fontSize: 14.0), // Reduced font size
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _sharePrinter();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _sharePrinter() async {
    if (paymentDetails == null) return;
    final pdfBytes = await preparePDFFile();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  Widget _buildCustomDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      height: 1.0,
      color: Colors.grey[200], // Custom grey color for the divider
    );
  }

  // void SavePDFFile(){
  //   final output = await getTemporaryDirectory();
  //   final file = File("${output.path}/receipt.pdf");
  //   await file.writeAsBytes(await preparePDFFile());
  // }

  Future<Uint8List> preparePDFFile() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Padding(
          padding: const pw.EdgeInsets.all(16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Payment Invoice',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              // Payment Details
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  _buildTableRow(
                    'Transaction Date:',
                    (paymentDetails?['transactionDate'] as String?)?.toString() ?? 'N/A',
                  ),
                  _buildTableRow(
                    'Voucher Serial Number:',
                    paymentDetails?['voucherSerialNumber'] ?? 'N/A',
                  ),
                  _buildTableRow(
                    'Customer Name:',
                    paymentDetails?['customerName'] ?? 'N/A',
                  ),
                  _buildTableRow(
                    'MSISDN:',
                    paymentDetails?['msisdn'] ?? 'N/A',
                  ),
                  _buildTableRow(
                    'PR Number:',
                    paymentDetails?['prNumber'] ?? 'N/A',
                  ),
                  _buildTableRow(
                    'Payment Method:',
                    paymentDetails?['paymentMethod'] ?? 'N/A',
                  ),
                  (paymentDetails?['amount'].toString().toLowerCase() == 'cash') ?
                  _buildTableRow(
                    'Amount:',
                    paymentDetails?['amount'] != null ? '${paymentDetails?['amount']} ${paymentDetails?['currency'] ?? 'Currency'}' : 'N/A',
                  ):
                  _buildTableRow(
                    'Amount Check:',
                    paymentDetails?['amountCheck'] != null ? '${paymentDetails?['amountCheck']} ${paymentDetails?['currency'] ?? 'Currency'}' : 'N/A',
                  ),
                  _buildTableRow(
                    'Check Number:',
                    paymentDetails?['checkNumber']?.toString() ?? 'N/A',
                  ),
                  _buildTableRow(
                    'Bank Branch:',
                    paymentDetails?['bankBranch'] ?? 'N/A',
                  ),
                  _buildTableRow(
                    'Due Date Check:',
                    (paymentDetails?['dueDateCheck'] as String?)?.toString() ?? 'N/A',
                  ),
                  _buildTableRow(
                    'Currency:',
                    paymentDetails?['currency'] ?? 'N/A',
                  ),
                  _buildTableRow(
                    'Payment Invoice For:',
                    paymentDetails?['paymentInvoiceFor'] ?? 'N/A',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return pdf.save();
  }

// Helper function to build table rows
  pw.TableRow _buildTableRow(String title, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            title,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }

}
