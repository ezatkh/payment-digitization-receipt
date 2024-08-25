import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Custom_Widgets/CustomPopups.dart';
import '../Models/Payment.dart';
import '../Services/LocalizationService.dart'; // Adjust import if needed
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;

import '../Services/apiConstants.dart';

class EmailBottomSheet extends StatefulWidget {
  final Payment payment;

  const EmailBottomSheet({
    Key? key,
    required this.payment,
  }) : super(key: key);

  @override
  _EmailBottomSheetState createState() => _EmailBottomSheetState();
}

class _EmailBottomSheetState extends State<EmailBottomSheet> {
  final TextEditingController _toController = TextEditingController();
  final FocusNode _toFocusNode = FocusNode();
  String? _errorText;
  String _selectedLanguage = 'en'; // Default message language is English
  Map<String, dynamic>? _emailJson;
  String? _headerBase64;
  String? _footerBase64;

  @override
  void initState() {
    super.initState();
    _toFocusNode.addListener(() {
      setState(() {
        if (_toFocusNode.hasFocus) {
          _errorText = null; // Clear error when field is focused
        }
      });
    });
    _loadLocalizedEmailContent(_selectedLanguage);
    _loadBase64Images();
  }

  Future<void> _loadLocalizedEmailContent(String languageCode) async {
    try {
      String jsonString = await rootBundle.loadString('assets/languages/$languageCode.json');
      setState(() {
        _emailJson = jsonDecode(jsonString);
      });
    } catch (e) {
      print("Error loading localized strings for $languageCode: $e");
    }
  }

  String getLocalizedEmailContent(String key) {
    if (_emailJson == null) {
      return '** $key not found';
    }
    return _emailJson![key] ?? '** $key not found';
  }

  Future<void> _loadBase64Images() async {
    try {
      final headerBase64 = await encodeImageToBase64('assets/images/headerEmail.jpg');
      final footerBase64 = await encodeImageToBase64('assets/images/footerEmail.jpg');
      setState(() {
        _headerBase64 = headerBase64;
        _footerBase64 = footerBase64;
      });
    } catch (e) {
      print("Error encoding images to Base64: $e");
    }
  }

  Future<String> encodeImageToBase64(String path) async {
    final ByteData data = await rootBundle.load(path);
    final List<int> bytes = data.buffer.asUint8List();
    return base64Encode(bytes);
  }

  Future<void> shareEmail(String toEmail, String subject, String body) async {
    // This will open the default email client with the provided details
    await Share.share(
      body,
      subject: subject,
      sharePositionOrigin: Rect.fromLTWH(0, 0, 100, 100), // Adjust position as needed
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_emailJson == null || _headerBase64 == null || _footerBase64 == null) {
      return Center(child: CircularProgressIndicator());
    }


    String subject = "${getLocalizedEmailContent('emailSubject')} ${widget.payment.transactionDate}";
    String body2 = '${getLocalizedEmailContent('emailBodyLine1')},\n\n${getLocalizedEmailContent('emailBodyLine2')} ${widget.payment.transactionDate} \n\n${getLocalizedEmailContent('emailBodyLine3')}';
    var appLocalization = Provider.of<LocalizationService>(context, listen: false);
    String currentLanguageCode = Localizations.localeOf(context).languageCode;

    final body = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title></title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            text-align: center;
            color: #333;
        }
        .container {
            width: 100%;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        .header img {
            width: 100%;
            height: auto;
        }
        .footer img {
            width: 100%;
            height: auto;
        }
        .content {
            padding: 20px;
            background-color: #f9f9f9;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <img src="data:image/png;base64,$_headerBase64" alt="Header Image">
        </div>
        <div class="content"
            <p>${getLocalizedEmailContent('emailBodyLine1')},</p>
            <p>${getLocalizedEmailContent('emailBodyLine2')}</p>
            <p>${getLocalizedEmailContent('emailBodyLine3')}</p>
        </div>
        <div class="footer">
            <img src="data:image/png;base64,$_footerBase64" alt="Footer Image">
        </div>
    </div>
</body>
</html>
""";


    return Directionality(
      textDirection: currentLanguageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Padding(
        // Adjust bottom padding dynamically based on keyboard visibility
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Adjust the bottom sheet size
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appLocalization.getLocalizedString('sendEmail'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                // To Field (editable)
                TextField(
                  controller: _toController,
                  focusNode: _toFocusNode,
                  decoration: InputDecoration(
                    labelText: appLocalization.getLocalizedString('to'),
                    labelStyle: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    errorText: _errorText,
                    errorStyle: TextStyle(color: Colors.red, fontSize: 14),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[700]),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 24),

                // Language Switcher for Email
                Row(
                  children: [
                    Text(appLocalization.getLocalizedString('selectLanguageForEmail')),
                    SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _selectedLanguage,
                      items: [
                        DropdownMenuItem(
                          value: 'en',
                          child: Text('English'),
                        ),
                        DropdownMenuItem(
                          value: 'ar',
                          child: Text('Arabic'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value!;
                          _loadLocalizedEmailContent(_selectedLanguage);
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Send Button
                Row(
                  mainAxisAlignment: currentLanguageCode == 'ar' ? MainAxisAlignment.start : MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: currentLanguageCode == 'ar' ? Alignment.centerLeft : Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            setState(() {
                              if (_toController.text.isEmpty) {
                                _errorText = appLocalization.getLocalizedString('toFieldError');
                                return;
                              }
                              _errorText = null; // Clear error if valid
                            });

                            // Handle send action
                            String toEmail = _toController.text;
                            print("To: $toEmail");
                            print("Subject: $subject");
                            print("header: ${_headerBase64}");
                            print("Body1: ${getLocalizedEmailContent('emailBodyLine1')}");
                            print("Body2: ${getLocalizedEmailContent('emailBodyLine2')}");
                            print("Body3: ${getLocalizedEmailContent('emailBodyLine3')}");
                            print("footer: ${_footerBase64}");
                            print("Language Code: $_selectedLanguage");


                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            String? tokenID = prefs.getString('token');
                            if (tokenID == null) {
                              print('Token not found');
                              return;
                            }
                            String fullToken = "Barer ${tokenID}";

                            Map<String, String> headers = {
                              'Content-Type': 'application/json',
                              'tokenID': fullToken,
                            };

                            Map<String, String> body = {
                              "to": toEmail,
                              "languageCode": _selectedLanguage,
                              "subject": subject ,
                            };
                            try {
                              final response = await http.post(
                                Uri.parse(apiUrlEmail),
                                headers: headers,
                                body: json.encode(body),
                              );
                              if (response.statusCode == 200) {
                                CustomPopups.showCustomResultPopup(
                                  context: context,
                                  icon: Icon(Icons.check_circle, color: Colors.green, size: 40),
                                  message: Provider.of<LocalizationService>(context, listen: false).getLocalizedString("paymentSentEmailOk"),
                                  buttonText:  Provider.of<LocalizationService>(context, listen: false).getLocalizedString("ok"),
                                  onPressButton: () {
                                    // Define what happens when the button is pressed
                                    print('Success acknowledged');
                                  },
                                );
                              } else {
                                CustomPopups.showCustomResultPopup(
                                  context: context,
                                  icon: Icon(Icons.error, color: Colors.red, size: 40),
                                  message:  Provider.of<LocalizationService>(context, listen: false).getLocalizedString("paymentSentEmailFailed"),
                                  buttonText: Provider.of<LocalizationService>(context, listen: false).getLocalizedString("ok"),
                                  onPressButton: () {
                                    // Define what happens when the button is pressed
                                    print('Error acknowledged');
                                  },
                                );                              }
                            } catch (e) {
                              // Handle exceptions
                              CustomPopups.showCustomResultPopup(
                                context: context,
                                icon: Icon(Icons.error, color: Colors.red, size: 40),
                                message: '${Provider.of<LocalizationService>(context, listen: false).getLocalizedString("paymentSentEmailFailed")}: $e',
                                buttonText: Provider.of<LocalizationService>(context, listen: false).getLocalizedString("ok"),
                                onPressButton: () {
                                  // Define what happens when the button is pressed
                                  print('Error acknowledged');
                                },
                              );                               }


                            // Close bottom sheet if no error
                            if (_errorText == null) Navigator.pop(context);
                          },
                          icon: Icon(Icons.send),
                          label: Text(appLocalization.getLocalizedString('send')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFC62828),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showEmailBottomSheet(BuildContext context, Payment payment) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Enable the bottom sheet to resize based on the content
    builder: (context) => EmailBottomSheet(payment: payment),
  );
}
