import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Custom_Widgets/CustomPopups.dart';
import '../Models/Payment.dart';
import '../Services/LocalizationService.dart';
import '../Services/PaymentService.dart';
import '../Services/apiConstants.dart';
import '../Services/database.dart';
import 'package:http/http.dart' as http;

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
    _loadSavedLanguageCode();
    if(widget.payment.msisdn != null)
    _phoneController.text=widget.payment.msisdn!;
    _phoneFocusNode.addListener(() {
      setState(() {
        if (_phoneFocusNode.hasFocus) {
          _errorText = null; // Clear error when field is focused
        }
      });
    });
  }

  Future<void> _loadSavedLanguageCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLanguageCode = prefs.getString('language_code');
    setState(() {
      // If a language code is saved, use it as the default, otherwise keep 'en' as default
      _selectedMessageLanguage = savedLanguageCode ?? 'en';
    });

    // Load the localized message for the saved/default language
    await _loadLocalizedMessage(_selectedMessageLanguage);
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
                               message = '${_messageJson!['smsSubject']} ${_messageJson![widget.payment.paymentMethod.toLowerCase()]} ${_messageJson!['withValue']}  ${widget.payment.amount}  ${AppearedCurrency}';
                             else
                               message = '${_messageJson!['smsSubject']} ${_messageJson![widget.payment.paymentMethod.toLowerCase()]} ${_messageJson!['withValue']}  ${widget.payment.amountCheck}  ${widget.payment.currency}';

                              print("Phone Number: ${_phoneController.text}");
                              print("Message Language: $_selectedMessageLanguage");
                              print("Message: $message");

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
                                "to": _phoneController.text,
                                "lang": _selectedMessageLanguage,
                                "message": message ,
                              };
                              try {
                                final response = await http.post(
                                  Uri.parse(apiUrlSMS),
                                  headers: headers,
                                  body: json.encode(body),
                                ).timeout(Duration(seconds:3));
                                if (response.statusCode == 200) {
                                  CustomPopups.showCustomResultPopup(
                                    context: context,
                                    icon: Icon(Icons.check_circle, color: Colors.green, size: 40),
                                    message: Provider.of<LocalizationService>(context, listen: false).getLocalizedString("paymentSentSmsOk"),
                                    buttonText:  Provider.of<LocalizationService>(context, listen: false).getLocalizedString("ok"),
                                    onPressButton: () {
                                      // Define what happens when the button is pressed
                                      print('Success acknowledged');
                                    },
                                  );
                                }
                                else if(response.statusCode == 401){
                                  int responseNumber = await PaymentService.attemptReLogin(context);
                                  print("the response number from get expend the session is :${responseNumber}");
                                  if(responseNumber == 200 ){
                                    print("relogin successfully");
                                    tokenID = prefs.getString('token');
                                    if (tokenID == null) {
                                      print('Token not found');
                                      return;
                                    }
                                    fullToken = "Barer ${tokenID}";

                                    headers = {
                                      'Content-Type': 'application/json',
                                      'tokenID': fullToken,
                                    };
                                    final reloginResponse = await http.post(
                                      Uri.parse(apiUrlSMS),
                                      headers: headers,
                                      body: json.encode(body),
                                    );
                                    if(reloginResponse.statusCode == 200){
                                      CustomPopups.showCustomResultPopup(
                                        context: context,
                                        icon: Icon(Icons.check_circle, color: Colors.green, size: 40),
                                        message: Provider.of<LocalizationService>(context, listen: false).getLocalizedString("paymentSentSmsOk"),
                                        buttonText:  Provider.of<LocalizationService>(context, listen: false).getLocalizedString("ok"),
                                        onPressButton: () {
                                          // Define what happens when the button is pressed
                                          print('Success acknowledged');
                                        },
                                      );
                                    }
                                    else{
                                      CustomPopups.showCustomResultPopup(
                                        context: context,
                                        icon: Icon(Icons.error, color: Colors.red, size: 40),
                                        message:  Provider.of<LocalizationService>(context, listen: false).getLocalizedString("paymentSentSmsFailed"),
                                        buttonText: Provider.of<LocalizationService>(context, listen: false).getLocalizedString("ok"),
                                        onPressButton: () {
                                          // Define what happens when the button is pressed
                                          print('Error acknowledged');
                                          print(response.body);
                                          print(response.statusCode);

                                        },
                                      );
                                    }
                                  }
                                }
                                else if (response.statusCode == 408) {
                                  CustomPopups.showCustomResultPopup(
                                    context: context,
                                    icon: Icon(Icons.error, color: Colors.red, size: 40),
                                    message: appLocalization.getLocalizedString("networkTimeoutError"),
                                    buttonText: appLocalization.getLocalizedString("ok"),
                                    onPressButton: () {
                                      print('Error timeout');
                                    },
                                  );
                                }
                                else {
                                  CustomPopups.showCustomResultPopup(
                                    context: context,
                                    icon: Icon(Icons.error, color: Colors.red, size: 40),
                                    message:  Provider.of<LocalizationService>(context, listen: false).getLocalizedString("paymentSentSmsFailed"),
                                    buttonText: Provider.of<LocalizationService>(context, listen: false).getLocalizedString("ok"),
                                    onPressButton: () {
                                      // Define what happens when the button is pressed
                                      print('Error acknowledged');
                                      print(response.body);
                                      print(response.statusCode);

                                    },
                                  );
                                }
                              }
                              on SocketException catch (e) {
                                CustomPopups.showCustomResultPopup(
                                  context: context,
                                  icon: Icon(Icons.error, color: Colors.red, size: 40),
                                  message: appLocalization.getLocalizedString("networkError"),
                                  buttonText: appLocalization.getLocalizedString("ok"),
                                  onPressButton: () {
                                    print('Network error acknowledged');
                                  },
                                );
                              } on TimeoutException catch (e) {
                                CustomPopups.showCustomResultPopup(
                                  context: context,
                                  icon: Icon(Icons.error, color: Colors.red, size: 40),
                                  message: appLocalization.getLocalizedString("networkTimeoutError"),
                                  buttonText: appLocalization.getLocalizedString("ok"),
                                  onPressButton: () {
                                    print('Timeout error acknowledged');
                                  },
                                );
                              }
                              catch (e) {
                                // Handle exceptions
                                CustomPopups.showCustomResultPopup(
                                  context: context,
                                  icon: Icon(Icons.error, color: Colors.red, size: 40),
                                  message: '${Provider.of<LocalizationService>(context, listen: false).getLocalizedString("paymentSentSmsFailed")}: $e',
                                  buttonText: Provider.of<LocalizationService>(context, listen: false).getLocalizedString("ok"),
                                  onPressButton: () {
                                    // Define what happens when the button is pressed
                                    print('Error acknowledged :${e}');
                                  },
                                );                              }
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
