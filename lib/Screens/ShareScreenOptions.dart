import 'dart:typed_data'; // Import the dart:typed_data library
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../Models/Payment.dart';
import '../Services/database.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class ShareScreenOptions {
  static Future<void> sharePdf(int id) async {
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

      // Generate PDF content with payment details
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) =>
              pw.Center(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Ooredoo', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 20),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              children: [
                                pw.Container(
                                  color: PdfColors.blue,
                                  padding: pw.EdgeInsets.all(8),
                                  child: pw.Text('INVOICE # :${payment.voucherSerialNumber}', style: pw.TextStyle(color: PdfColors.white)),
                                ),
                                pw.Container(
                                  color: PdfColors.blue,
                                  padding: pw.EdgeInsets.all(8),
                                  child: pw.Text('Transaction Date :${payment.transactionDate}', style: pw.TextStyle(color: PdfColors.white)),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 20),
                            pw.Row(
                              children: [
                                pw.Container(
                                  color: PdfColors.blue,
                                  padding: pw.EdgeInsets.all(8),
                                  child: pw.Text('CUSTOMER Name: ${payment.customerName}', style: pw.TextStyle(color: PdfColors.white)),
                                ),
                                pw.Container(
                                  color: PdfColors.blue,
                                  padding: pw.EdgeInsets.all(8),
                                  child: pw.Text('PR# :${payment.prNumber}', style: pw.TextStyle(color: PdfColors.white)),
                                ),
                                pw.Container(
                                  color: PdfColors.blue,
                                  padding: pw.EdgeInsets.all(8),
                                  child: pw.Text('MSISDN :${payment.msisdn}', style: pw.TextStyle(color: PdfColors.white)),
                                ),
                              ],
                            ),

                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 20),

                    //previous one
                    pw.Text('Payment Details', style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 16),
                    pw.Text('Payment Method: ${payment.paymentMethod}'),
                    pw.Text('Amount: ${payment.amount?.toString() ?? ''}'),
                    pw.Text('Amount Check: ${payment.amountCheck?.toString() ??
                        ''}'),
                    pw.Text('Currency: ${payment.currency ?? ''}'),
                    pw.Text('Check Number: ${payment.checkNumber?.toString() ??
                        ''}'),
                    pw.Text('Bank Branch: ${payment.bankBranch ?? ''}'),
                    pw.Text('Due Date Check: ${payment.dueDateCheck
                        ?.toIso8601String() ?? ''}'),
                    pw.Text('Payment Invoice For: ${payment.paymentInvoiceFor ??
                        ''}'),
                  ],
                ),
              ),
        ),
      );

      // Get the external storage directory
      final directory = await getExternalStorageDirectory();
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
}
