import 'dart:typed_data';
import 'package:digital_payment_app/Models/LoginState.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/Payment.dart';
import '../Services/LocalizationService.dart';
import '../Services/database.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../Utils/Enum.dart';
import 'EmailBottomSheet.dart';
import 'SMSBottomSheet.dart';

class ShareScreenOptions {
  static String? _selectedLanguageCode;

  static Future<File?> sharePdf(BuildContext context, int id, String languageCode) async {
    try {
      // Get the current localization service without changing the app's locale
      final localizationService = Provider.of<LocalizationService>(context, listen: false);
      // Fetch localized strings for the specified language code
      final localizedStrings = await localizationService.getLocalizedStringsForLanguage(languageCode);

      // Fetch payment details from the database
      final paymentMap = await DatabaseProvider.getPaymentById(id);
      if (paymentMap == null) {
        print('No payment details found for ID $id');
        return null;
      }

      // Create a Payment instance from the fetched map
      final payment = Payment.fromMap(paymentMap);
      final currency = await DatabaseProvider.getCurrencyById(payment.currency!); // Implement this method
      Map<String, String>? bankDetails;

      if (payment.paymentMethod == 'cash') {
        // Handle cash payment case
        print('Payment is made in cash. No need to fetch bank details.');
      } else {
        try {
          final dynamicFetchedBank = await DatabaseProvider.getBankById(payment.bankBranch!);
          if (dynamicFetchedBank != null) {
            // Convert the fetched map from Map<String, dynamic>? to Map<String, String>
            bankDetails = Map<String, String>.from(dynamicFetchedBank.map(
                  (key, value) => MapEntry(key, value.toString()), // Ensure all values are strings
            ));
            print('Bank details retrieved: $bankDetails');
          } else {
            print('No bank details found.');
          }
        } catch (e) {
          print('Failed to retrieve bank details: $e');
        }
      }      // Load fonts
      final notoSansFont = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
      final amiriFont = pw.Font.ttf(await rootBundle.load('assets/fonts/Amiri-Regular.ttf'));

      final isEnglish = languageCode == 'en';
      final font = isEnglish ? notoSansFont : amiriFont;


      // Generate PDF content with payment details
      final pdf = pw.Document();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? usernameLogin = prefs.getString('usernameLogin');
      final List<Map<String, String>> customerDetails = [
        {'title': localizedStrings['customerName'], 'value': payment.customerName},
        if (payment.msisdn != null && payment.msisdn.toString().length>0)
        {'title': localizedStrings['mobileNumber'], 'value': payment.msisdn.toString()},
        {'title': localizedStrings['transactionDate'], 'value': payment.transactionDate.toString()},
        {'title': localizedStrings['voucherNumber'], 'value': payment.voucherSerialNumber},
      ];

      String receiptVoucher = localizedStrings['receiptVoucher'];
      String customersDetail = localizedStrings['customersDetail'];
      String additionalDetails = localizedStrings['additionalDetails'];

      List<Map<String, String>> paymentDetails=[];

      if(payment.paymentMethod.toLowerCase() == 'cash' || payment.paymentMethod.toLowerCase() == 'كاش')
        paymentDetails = [
          {'title': localizedStrings['paymentMethod'], 'value': payment.paymentMethod},
          {'title': localizedStrings['amount'], 'value': payment.amount.toString()},
          {'title': localizedStrings['currency'], 'value': languageCode =='ar' ? currency!["arabicName"] ?? '' : currency!["englishName"]},
        ];
      else if(payment.paymentMethod.toLowerCase() == 'check' || payment.paymentMethod.toLowerCase() == 'شيك')
        paymentDetails = [
          {'title': localizedStrings['paymentMethod'], 'value': localizedStrings[payment.paymentMethod.toLowerCase()]},
          {'title': localizedStrings['amountCheck'], 'value': payment.amountCheck.toString()},
          {'title': localizedStrings['currency'], 'value': languageCode =='ar' ? currency!["arabicName"] ?? '' : currency!["englishName"]},
          {'title': localizedStrings['checkNumber'], 'value': payment.checkNumber.toString()},
          {'title': localizedStrings['bankBranchCheck'], 'value': languageCode =='ar' ? bankDetails!["arabicName"] ??'' : bankDetails!["englishName"] ?? ''},
          {'title': localizedStrings['dueDateCheck'], 'value': payment.dueDateCheck != null
              ? DateFormat('yyyy-MM-dd').format(payment.dueDateCheck!)
              : ''},
        ];
      final List<Map<String, String>> additionalDetail= [
        {'title': localizedStrings['userid'], 'value': usernameLogin!},
       ];

      String paymentDetail = localizedStrings['paymentDetail'];
      String footerPdf = localizedStrings['footerPdf'];

      pdf.addPage(
        pw.Page(
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) {
            return pw.Directionality(
              textDirection: isEnglish ? pw.TextDirection.ltr : pw.TextDirection.rtl,
              child: pw.Container(
                color: PdfColors.white,
                padding: pw.EdgeInsets.zero, // Remove padding
                child: pw.Column(
                  children: [
                    pw.Container(
                      alignment: pw.Alignment.center,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey),
                        color: PdfColors.white,
                      ),
                      child: pw.Text(
                        'Ooredoo',
                        style: pw.TextStyle(
                          color: PdfColors.black,
                          fontSize: 40,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Container(
                      alignment: pw.Alignment.center,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.black,
                        border: pw.Border.all(color: PdfColors.black),
                      ),
                      child: pw.Text(
                        receiptVoucher,
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          font: font,
                        ),
                      ),
                    ),
                    pw.Container(
                      alignment: pw.Alignment.center,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey300,
                        border: pw.Border.all(color: PdfColors.black),
                      ),
                      child: pw.Text(
                        customersDetail,
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          font: font,
                        ),
                      ),
                    ),
                    _buildInfoTableDynamic(customerDetails, notoSansFont, amiriFont, isEnglish),
                    pw.Container(
                      alignment: pw.Alignment.center,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey300,
                        border: pw.Border.all(color: PdfColors.black),
                      ),
                      child: pw.Text(
                        paymentDetail,
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          font: font,
                        ),
                      ),
                    ),
                    _buildInfoTableDynamic(paymentDetails, notoSansFont, amiriFont, isEnglish),
                    pw.Container(
                      alignment: pw.Alignment.center,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey300,
                        border: pw.Border.all(color: PdfColors.black),
                      ),
                      child: pw.Text(
                        additionalDetails,
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          font: font,
                        ),
                      ),
                    ),
                    _buildInfoTableDynamic(additionalDetail, notoSansFont, amiriFont, isEnglish),
                    pw.Container(
                      alignment: pw.Alignment.center,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        border: pw.Border.all(color: PdfColors.black),
                      ),
                      child: pw.Text(
                        footerPdf,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          font: font,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      // Get the external storage directory
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/payment.pdf';
      final file = File(path);

      // Write the PDF file
      await file.writeAsBytes(await pdf.save());
      return file;
      // Share the PDF file

      // await Share.shareFiles(
      //   [file.path],
      //   text: Provider.of<LocalizationService>(context, listen: false).getLocalizedString('checkoutPdf'),
      //   mimeTypes: ['application/pdf'],
      // );
    } catch (e) {
      print('Error: $e');
      return null;
      // Handle the error (e.g., show a snackbar or dialog in the UI)
    }
  }
  // Build info table with dynamic localization
  static pw.Widget _buildInfoTableDynamic(List<Map<String, String>> rowData, pw.Font fontEnglish, pw.Font fontArabic, bool isEnglish) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FlexColumnWidth(2), // Adjust as needed
        1: pw.FlexColumnWidth(3), // Adjust as needed
      },
      children: rowData.map((row) => _buildTableRowDynamic(row['title']!, row['value']!, fontEnglish, fontArabic, isEnglish)).toList().cast<pw.TableRow>(),
    );
  }

  static pw.TableRow _buildTableRowDynamic(String title, String value, pw.Font fontEnglish, pw.Font fontArabic, bool isEnglish) {
    // Function to determine if the text is Arabic
    bool isArabic(String text) {
      final arabicCharRegExp = RegExp(r'[\u0600-\u06FF]');
      return arabicCharRegExp.hasMatch(text);
    }

    // Determine the font and text direction based on the content language
    final fontForTitle = isArabic(title) ? fontArabic : fontEnglish;
    final fontForValue = isArabic(value) ? fontArabic : fontEnglish;
    final textDirectionForValue = isArabic(value) ? pw.TextDirection.rtl : pw.TextDirection.ltr;

    return pw.TableRow(
      children: isEnglish
          ? [
        pw.Container(
          padding: pw.EdgeInsets.all(6),
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            title,
            style: pw.TextStyle(font: fontForTitle, fontSize: 14),
            textDirection: isArabic(title) ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          ),
        ),
        pw.Container(
          padding: pw.EdgeInsets.all(6),
          alignment: pw.Alignment.centerRight,
          child: pw.Directionality(
            textDirection: textDirectionForValue,
            child: pw.Text(
              value,
              style: pw.TextStyle(font: fontForValue, fontSize: 14),
            ),
          ),
        ),
      ]
          : [
        pw.Container(
          padding: pw.EdgeInsets.all(6),
          alignment: pw.Alignment.centerLeft,
          child: pw.Directionality(
            textDirection: textDirectionForValue,
            child: pw.Text(
              value,
              style: pw.TextStyle(font: fontForValue, fontSize: 14),
            ),
          ),
        ),
        pw.Container(
          padding: pw.EdgeInsets.all(6),
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            title,
            style: pw.TextStyle(font: fontForTitle, fontSize: 14),
            textDirection: isArabic(title) ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          ),
        ),
      ],
    );
  }

  static void showLanguageSelectionAndShare(BuildContext context, int id, ShareOption option) {
    switch (option) {
      case ShareOption.sendEmail:
        _shareViaEmail(context, id);
        break;
      case ShareOption.sendSms:
        _shareViaSms(context, id);
        break;
      case ShareOption.print:
        _shareViaPrint(context, id, _selectedLanguageCode!);
        break;
      case ShareOption.sendWhats:
        _shareViaWhatsApp(context, id, _selectedLanguageCode!);
        break;
      default:
      // Optionally handle unexpected values
        break;
    }

  }

  static Future<void> _shareViaEmail(BuildContext context, int id) async {
    // Fetch payment details from the database
    final paymentMap = await DatabaseProvider.getPaymentById(id);
    if (paymentMap == null) {
      print('No payment details found for ID $id');
      return null;
    }

    // Create a Payment instance from the fetched map
    final payment = Payment.fromMap(paymentMap);

    showEmailBottomSheet(context,payment);
  }

  static Future<void> _shareViaSms(BuildContext context, int id) async {
    // Fetch payment details from the database
    final paymentMap = await DatabaseProvider.getPaymentById(id);
    if (paymentMap == null) {
      print('No payment details found for ID $id');
      return null;
    }

    // Create a Payment instance from the fetched map
    final payment = Payment.fromMap(paymentMap);

    showSmsBottomSheet(context,payment);
  }
  static void _shareViaPrint(BuildContext context, int id, String languageCode) {
    // Implement print logic using the selected language
  }
  static void _shareViaWhatsApp(BuildContext context, int id, String languageCode) async {
    final file = await sharePdf(context, id, languageCode);
    if (file != null) {
      Share.shareFiles(
        [file.path],
        text: 'Here is the payment receipt.',
        mimeTypes: ['application/pdf'],
      );
    } else {
      print('Failed to generate PDF.');
    }
  }
  static void _showLanguageSelectionDialog(BuildContext context, Function(String) onLanguageSelected) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12.0,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Provider.of<LocalizationService>(context, listen: false).getLocalizedString("selectPreferredLanguage"),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _buildLanguageButton(context, Provider.of<LocalizationService>(context, listen: false).getLocalizedString("english"), 'en', Icons.language, onLanguageSelected),
              SizedBox(height: 12),
              _buildLanguageButton(context, Provider.of<LocalizationService>(context, listen: false).getLocalizedString("arabic"), 'ar', Icons.language, onLanguageSelected),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildLanguageButton(BuildContext context, String language, String code, IconData icon, Function(String) onLanguageSelected) {
    return ElevatedButton(
      onPressed: () {
        onLanguageSelected(code);
        Navigator.of(context).pop();
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, backgroundColor: Colors.white,
        elevation: 4,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            language,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Icon(
            icon,
            color: Colors.blueAccent,
          ),
        ],
      ),
    );
  }

}