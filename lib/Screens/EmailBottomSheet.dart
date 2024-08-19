import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../Models/Payment.dart';
import '../Services/LocalizationService.dart'; // Adjust import if needed

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

  @override
  Widget build(BuildContext context) {
    if (_emailJson == null) {
      return Center(child: CircularProgressIndicator());
    }

    String subject = "${getLocalizedEmailContent('emailSubject')} ${widget.payment.transactionDate}";
    String body = '${getLocalizedEmailContent('emailBodyLine1')},\n\n${getLocalizedEmailContent('emailBodyLine2')} ${widget.payment.transactionDate} \n\n${getLocalizedEmailContent('emailBodyLine3')}';
    var appLocalization = Provider.of<LocalizationService>(context, listen: false);
    String currentLanguageCode = Localizations.localeOf(context).languageCode;

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
                            print("Body: $body");
                            print("Language Code: $_selectedLanguage");

                            // Here you can call a method to send the email with the content
                            // For example:
                            // await sendEmail(toEmail, subject, body);

                            // Close bottom sheet if no error
                            if (_errorText == null) Navigator.pop(context);
                          },
                          icon: Icon(Icons.send),
                          label: Text(appLocalization.getLocalizedString('send')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
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
