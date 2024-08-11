import 'dart:typed_data';
import 'package:digital_payment_app/Models/LoginState.dart';
import 'package:flutter/material.dart';
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

class ShareScreenOptions {

  static Future<void> sharePdf(BuildContext context, int id, String languageCode) async {

    try {
      // Get the current localization service without changing the app's locale
      final localizationService = Provider.of<LocalizationService>(context, listen: false);

      // Temporarily load the localization for the selected language code
      final currentLanguageCode = localizationService.selectedLanguageCode;
      localizationService.changeLanguage(languageCode);

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
      final font = isEnglish ? notoSansFont : amiriFont;

      // Generate PDF content with payment details
      final pdf = pw.Document();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? usernameLogin = prefs.getString('usernameLogin');

      final List<Map<String, String>> customerDetails = [
        {'title': localizationService.getLocalizedString('customerName'), 'value': payment.customerName},
        {'title': localizationService.getLocalizedString('mobileNumber'), 'value': payment.msisdn!},
        {'title': localizationService.getLocalizedString('transactionDate'), 'value': payment.transactionDate.toString()},
        {'title': localizationService.getLocalizedString('voucherNumber'), 'value': payment.voucherSerialNumber},
      ];
      String receiptVoucher = localizationService.getLocalizedString('receiptVoucher');
      String customersDetail = localizationService.getLocalizedString('customersDetail');
      String additionalDetails = localizationService.getLocalizedString('additionalDetails');
      List<Map<String, String>> paymentDetails=[];

      final Map<String, Map<String, String>> currencyMap = {
        "usd": {"en": "USD", "ar": "دولار"},
        "euro": {"en": "Euro", "ar": "يورو"},
        "ils": {"en": "ILS", "ar": "شيقل"},
        "jd": {"en": "JOD", "ar": "دينار"},
      };
      String getCurrencyString(String currencyCode, bool isEnglish) {
        return isEnglish
            ? currencyMap[currencyCode]!['en'] ?? currencyCode
            : currencyMap[currencyCode]!['ar'] ?? currencyCode;
      }
    //  print(getCurrencyString(payment.currency!,isEnglish));
      if(payment.paymentMethod.toLowerCase() == 'cash' || payment.paymentMethod.toLowerCase() == 'كاش')
        paymentDetails = [
        {'title': localizationService.getLocalizedString('paymentMethod'), 'value': payment.paymentMethod},
   //     {'title': localizationService.getLocalizedString('currency'), 'value': getCurrencyString(payment.currency!,isEnglish)},
        {'title': localizationService.getLocalizedString('amount'), 'value': payment.amount.toString()},
      ];
      else if(payment.paymentMethod.toLowerCase() == 'check' || payment.paymentMethod.toLowerCase() == 'شيك')
        paymentDetails = [
          {'title': localizationService.getLocalizedString('paymentMethod'), 'value': payment.paymentMethod},
          {'title': localizationService.getLocalizedString('amountCheck'), 'value': payment.amountCheck.toString()},
          {'title': localizationService.getLocalizedString('checkNumber'), 'value': payment.checkNumber.toString()},
          {'title': localizationService.getLocalizedString('bankBranchCheck'), 'value': payment.bankBranch.toString()},
          {'title': localizationService.getLocalizedString('dueDateCheck'), 'value': payment.dueDateCheck.toString()},
        //  {'title': localizationService.getLocalizedString('currency'), 'value': getCurrencyString(payment.currency!.toLowerCase(),isEnglish)},
        ];
      final List<Map<String, String>> additionalDetail= [
        {'title': localizationService.getLocalizedString('userid'), 'value': usernameLogin!},
       ];

      String paymentDetail = localizationService.getLocalizedString('paymentDetail');
      String footerPdf = localizationService.getLocalizedString('footerPdf');

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Directionality(
              textDirection: isEnglish ? pw.TextDirection.ltr : pw.TextDirection.rtl,
              child: pw.Container(
                color: PdfColors.white,
                padding: pw.EdgeInsets.all(10),
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

      // Restore the original language code
      localizationService.changeLanguage(currentLanguageCode);

      // Get the external storage directory
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/payment.pdf';
      final file = File(path);

      // Write the PDF file
      await file.writeAsBytes(await pdf.save());

      // Share the PDF file
      await Share.shareFiles(
        [file.path],
        text: Provider.of<LocalizationService>(context, listen: false).getLocalizedString('checkoutPdf'),
        mimeTypes: ['application/pdf'],
      );
    } catch (e) {
      print('Error: $e');
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

  static void showLanguageSelectionAndShare(BuildContext context, int id) {
    _showLanguageSelectionDialog(context, (String languageCode) {
      sharePdf(context, id, languageCode);
    });
  }
  // Language selection dialog
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
              color: Colors.white,
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
                  Provider.of<LocalizationService>(context, listen: false).getLocalizedString('selectPreferredLanguage'),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                _buildLanguageOption(context, Provider.of<LocalizationService>(context, listen: false).getLocalizedString('english'), 'en', onLanguageSelected),
                SizedBox(height: 8),
                _buildLanguageOption(context, Provider.of<LocalizationService>(context, listen: false).getLocalizedString('arabic'), 'ar', onLanguageSelected),
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
}
