import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../Models/Payment.dart';
import '../Services/LocalizationService.dart';
import '../Services/database.dart';

class SmsBottomSheet extends StatefulWidget {
  final Payment payment;

  const SmsBottomSheet({
    Key? key,
    required this.payment,
  }) : super(key: key);

  @override
  _SmsBottomSheetState createState() => _SmsBottomSheetState();
}

class _SmsBottomSheetState extends State<SmsBottomSheet> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  String? _errorText;
  String _selectedMessageLanguage = 'en'; // Default message language is English
  Map<String, dynamic>? _messageJson;

  @override
  void initState() {
    super.initState();
    if(widget.payment.msisdn! != null)
    _phoneController.text=widget.payment.msisdn!;
    _phoneFocusNode.addListener(() {
      setState(() {
        if (_phoneFocusNode.hasFocus) {
          _errorText = null; // Clear error when field is focused
        }
      });
    });
  }

  Future<void> _loadLocalizedMessage(String languageCode) async {
    // Load the correct language JSON file
    String jsonString = await rootBundle.loadString('assets/languages/$languageCode.json');
    setState(() {
      _messageJson = jsonDecode(jsonString);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Fetching localized strings for the app's UI
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
                  appLocalization.getLocalizedString('sendSms'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                // Phone Number Field (editable)
                TextField(
                  controller: _phoneController,
                  focusNode: _phoneFocusNode,
                  decoration: InputDecoration(
                    labelText: appLocalization.getLocalizedString('phoneNumber'),
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
                    prefixIcon: Icon(Icons.phone, color: Colors.grey[700]),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 24),

                // Language Switcher for Message
                Row(
                  children: [
                    Text(appLocalization.getLocalizedString('selectLanguageForMessage')),
                    SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _selectedMessageLanguage,
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
                          _selectedMessageLanguage = value!;
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
                              if (_phoneController.text.isEmpty) {
                                _errorText = appLocalization.getLocalizedString('phoneNumberFieldError');
                                return;
                              }
                              _errorText = null; // Clear error if valid
                            });

                            // Load the localized message asynchronously
                            await _loadLocalizedMessage(_selectedMessageLanguage);

                            if (_messageJson != null) {

                              Map<String, dynamic>? currency = await DatabaseProvider.getCurrencyById(widget.payment.currency!);
                              String AppearedCurrency='';
                              setState(() {
                                 AppearedCurrency = _selectedMessageLanguage == 'ar' ? currency!["arabicName"] :  currency!["englishName"];
                              });
                              // Fetch the localized message based on the selected language
                              String message ='';
                              if(widget.payment.paymentMethod.toLowerCase() == 'cash' || widget.payment.paymentMethod.toLowerCase() == 'كاش')
                               message = '${_messageJson!['smsSubject']} ${_messageJson![widget.payment.paymentMethod.toLowerCase()]}  ${widget.payment.amount}  ${AppearedCurrency}';
                             else
                               message = '${_messageJson!['smsSubject']} ${_messageJson![widget.payment.paymentMethod.toLowerCase()]}  ${widget.payment.amountCheck}  ${widget.payment.currency}';

                              print("Phone Number: ${_phoneController.text}");
                              print("Message Language: $_selectedMessageLanguage");
                              print("Message: $message");

                              // Close bottom sheet if no error
                              if (_errorText == null) Navigator.pop(context);
                            }
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

void showSmsBottomSheet(BuildContext context, Payment payment) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Enable the bottom sheet to resize based on the content
    builder: (context) => SmsBottomSheet(payment: payment),
  );
}
