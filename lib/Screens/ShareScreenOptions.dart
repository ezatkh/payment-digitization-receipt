import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../Models/Payment.dart';
import '../Services/database.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart' show rootBundle;

String reverseText(String text) {
  return text.split('').reversed.join('');
}

class ShareScreenOptions {
  static Future<void> sharePdf(int id, String languageCode) async {
    try {
      // Fetch payment details from the database
      final paymentMap = await DatabaseProvider.getPaymentById(id);
      if (paymentMap == null) {
        print('No payment details found for ID $id');
        return;
      }
      print(paymentMap.toString());

      // Create a Payment instance from the fetched map
      final payment = Payment.fromMap(paymentMap);

      // Load fonts
      final notoSansFont = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
      final amiriFont = pw.Font.ttf(await rootBundle.load('assets/fonts/Amiri-Regular.ttf'));

      final isEnglish = languageCode == 'en';
      final font =  isEnglish? notoSansFont : amiriFont;


      // Load the logo image
      final ByteData logoData = await rootBundle.load('assets/images/logo_ooredoo.png');
      final Uint8List logoBytes = logoData.buffer.asUint8List();
      final logoImage = pw.MemoryImage(logoBytes);

      // Generate PDF content with payment details
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Center(
            child: pw.Directionality(
              textDirection: isEnglish ? pw.TextDirection.ltr : pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            isEnglish ? 'Payment Details' : 'تفاصيل الدفعة',
                            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, font: font),
                          ),
                          pw.Text(
                            isEnglish ? 'Ooredoo Details' : 'أوريدو',
                            style: pw.TextStyle(fontSize: 18, font: font),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Container(
                            width: 100,
                            height: 100,
                            child: pw.Image(logoImage),
                          ),
                          pw.Text(
                            isEnglish
                                ? 'INVOICE #: ${payment.voucherSerialNumber}'
                                : 'رقم الفاتورة: ${payment.voucherSerialNumber}',
                            style: pw.TextStyle(font: font),
                          ),
                          pw.Text(
                            isEnglish
                                ? 'TRANSACTION DATE: ${payment.transactionDate}'
                                : 'تاريخ المعاملة: ${payment.transactionDate}',
                            style: pw.TextStyle(font: font),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Container(
                          padding: pw.EdgeInsets.all(6),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text(
                            isEnglish ? 'CUSTOMER Name: ${payment.customerName}' : 'اسم العميل: ${payment.customerName}',
                            style: pw.TextStyle(color: PdfColors.black, font: font),
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Expanded(
                        child: pw.Container(
                          padding: pw.EdgeInsets.all(6),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text(
                            isEnglish ? 'PR #: ${payment.prNumber}' : 'رقم الطلب: ${payment.prNumber}',
                            style: pw.TextStyle(color: PdfColors.black, font: font),
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Expanded(
                        child: pw.Container(
                          padding: pw.EdgeInsets.all(6),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text(
                            isEnglish ? 'MSISDN: ${payment.msisdn}' : 'رقم الهاتف: ${payment.msisdn}',
                            style: pw.TextStyle(color: PdfColors.black, font: font),
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    isEnglish ? 'Payment Details' : 'تفاصيل الدفع',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, font: font),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    isEnglish ? 'Payment Method: ${payment.paymentMethod}' : 'طريقة الدفع: ${payment.paymentMethod}',
                    style: pw.TextStyle(font: font),
                  ),
                  pw.Text(
                    isEnglish ? 'Amount: ${payment.amount?.toString() ?? ''}' : 'المبلغ: ${payment.paymentMethod.toLowerCase() == 'cash' ? payment.amount?.toString() : payment.amountCheck?.toString()?? ''}',
                    style: pw.TextStyle(font: font),
                  ),
                  pw.Text(
                    isEnglish ? 'Currency: ${payment.currency ?? ''}' : 'العملة: ${payment.currency ?? ''}',
                    style: pw.TextStyle(font: font),
                  ),
                  pw.Text(
                    isEnglish ? 'Check Number: ${payment.checkNumber?.toString() ?? ''}' : 'رقم الشيك: ${payment.checkNumber?.toString() ?? ''}',
                    style: pw.TextStyle(font: font),
                  ),
                  pw.Text(
                    isEnglish ? 'Bank Branch: ${payment.bankBranch ?? ''}' : 'فرع البنك: ${payment.bankBranch ?? ''}',
                    style: pw.TextStyle(font: font),
                  ),
                  pw.Text(
                    isEnglish ? 'Due Date Check: ${payment.dueDateCheck?.toIso8601String() ?? ''}' : 'تاريخ استحقاق الشيك: ${payment.dueDateCheck?.toIso8601String() ?? ''}',
                    style: pw.TextStyle(font: font),
                  ),
                  pw.Text(
                    isEnglish ? 'Payment Invoice For: ${payment.paymentInvoiceFor ?? ''}' : 'فاتورة الدفع لـ: ${payment.paymentInvoiceFor ?? ''}',
                    style: pw.TextStyle(font: font),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    isEnglish ? 'Thank you for your business!' : 'شكرا لتعاملكم معنا!',
                    style: pw.TextStyle(fontSize: 18, font: font),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Get the external storage directory
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory?.path}/payment.pdf';
      final file = File(path);

      // Write the PDF file
      await file.writeAsBytes(await pdf.save());

      // Share the PDF file
      await Share.shareFiles(
        [file.path],
        text: 'Check out this PDF',
        mimeTypes: ['application/pdf'],
      );
    } catch (e) {
      print('Error: $e');
      // Handle the error (e.g., show a snackbar or dialog in the UI)
    }
  }

  static void _showLanguageSelectionDialog(BuildContext context, Function(String) onLanguageSelected) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 12,
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Language',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                _buildLanguageOption(context, 'English', 'en', onLanguageSelected),
                SizedBox(height: 8),
                _buildLanguageOption(context, 'Arabic', 'ar', onLanguageSelected),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildLanguageOption(BuildContext context, String language, String code, Function(String) onLanguageSelected) {
    return InkWell(
      onTap: () {
        onLanguageSelected(code);
        Navigator.of(context).pop();
      },
      onHover: (isHovered) {
        // You can add additional actions when the item is hovered if needed
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6.0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Icon(
              Icons.language,
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }
  static void showLanguageSelectionAndShare(BuildContext context, int id) {
    _showLanguageSelectionDialog(context, (String languageCode) {
      sharePdf(id, languageCode);
    });
  }
}
