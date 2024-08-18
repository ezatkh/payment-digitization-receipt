import 'package:digital_payment_app/Services/secure_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:digital_payment_app/Services/database.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../Models/LoginState.dart';
import '../Screens/LoginScreen.dart';
import 'apiConstants.dart';


class PaymentService {
  static final StreamController<void> _syncController = StreamController<
      void>.broadcast();

  static Stream<void> get syncStream => _syncController.stream;

  static void navigateToLoginScreen(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false, // This disables popping the LoginScreen route
    );
  }

  static String convertAmountToWords(dynamic amount) {
    if (amount == null) {
      return ''; // Handle the case where amount is null
    }

    // Convert to int if amount is a double
    int amountInt = (amount is double) ? amount.toInt() : amount as int;

    return NumberToWordsEnglish.convert(amountInt);
  }

  static void startPeriodicNetworkTest(BuildContext context) {
    Timer.periodic(Duration(seconds: 5), (Timer timer) async {
      await testNetwork(context);
    });
  }

  static Future<void> testNetwork(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    print(connectivityResult);
    if (connectivityResult == ConnectivityResult.none) {}
    else {
      PaymentService.syncPayments(context);
    }
  }

  static Future<void> syncPayments(BuildContext context) async {
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
    // Retrieve all confirmed payments
    List<Map<String,
        dynamic>> ConfirmedAndCancelledPendingPayments = await DatabaseProvider
        .getConfirmedOrCancelledPendingPayments();
    List<Map<String, dynamic>> confirmedPayments = [];
    List<Map<String, dynamic>> cancelledPendingPayments = [];

    // Iterate through the results and separate them based on status
    for (var payment in ConfirmedAndCancelledPendingPayments) {
      if (payment['status'] == 'Confirmed') {
        confirmedPayments.add(payment);
      } else if (payment['status'] == 'CancelPending') {
        cancelledPendingPayments.add(payment);
      }
    }
// Assuming NumberToWordsEnglish.convert expects an int


    for (var payment in confirmedPayments) {
      PaymentService.syncPayment(payment, apiUrl, headers,context);
    }
print("tt");
    for (var p in cancelledPendingPayments) {
      Map<String, String> body = {
        "voucherSerialNumber": p["voucherSerialNumber"],
        "cancelReason": p["cancelReason"].toString(),
        "cancelTransactionDate": p["cancellationDate"] ,
      };
      print("kk");
      print(body);
      try {
        final response = await http.delete(
          Uri.parse(apiUrlCancel),
          headers: headers,
          body: json.encode(body),
        );
        if (response.statusCode == 200) {
          print("inside status code 200 of cancel api");
          await DatabaseProvider.updatePaymentStatus(p["id"], 'Cancelled');
          _syncController.add(null);
        } else {
          print('Failed to cancel payment: ${response.body}');
        }
      } catch (e) {
        // Handle exceptions
        print('Error syncing payment: $e');
      }
    }
    _syncController.add(null);
  }

  static Future <void> syncPayment(Map<String, dynamic> payment, String apiUrl,
      Map<String, String> headers, BuildContext context) async {
    String theSumOf = payment['paymentMethod'].toLowerCase() == 'cash'
        ? convertAmountToWords(payment['amount'])
        : convertAmountToWords(payment['amountCheck']);

    Map<String, dynamic> body = {
      'transactionDate': payment['transactionDate'],
      'accountName': payment['customerName'],
      'msisdn': payment['msisdn'],
      'pr': payment['prNumber'],
      'amount': payment['amount'],
      'currency': payment['currency'],
      'paymentMethod': payment['paymentMethod'],
      'checkNumber': payment['checkNumber'],
      'checkAmount': payment['amountCheck'],
      'checkBank': payment['bankBranch'],
      'checkDueDate': payment['dueDateCheck'] != null &&
          payment['dueDateCheck'] != 'null'
          ? DateTime.parse(payment['dueDateCheck']).toIso8601String()
          : null,
      'theSumOf': theSumOf
    };
    print(body);

    try {
      print("before send sync api");
      // Make POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        print("inside status code 200 of sync api");

        // Parse the response
        Map<String, dynamic> responseBody = json.decode(response.body);
        String? voucherSerialNumber = responseBody['voucherSerialNumber'];
        print("voucherSerialNumber :");
        print(voucherSerialNumber!);

        // Update payment in local database
        await DatabaseProvider.updatePaymentvoucherSerialNumber(
            payment["id"], voucherSerialNumber);

        // Update payment status to 'Synced'
        await DatabaseProvider.updatePaymentStatus(payment["id"], 'Synced');
        _syncController.add(null);
      } else {
        Map<String, dynamic> errorResponse = json.decode(response.body);
        print("failed to sync heres the body of response: ${response.body}");
        if (errorResponse['error'] == 'Unauthorized' &&
            errorResponse['errorInDetail'] == 'JWT Authentication Failed') {
          await _attemptReLoginAndRetrySync(context);
        } else {
          print('Failed to sync payment: ${response.body}');

        }
      }
    } catch (e) {
      print('Error syncing payment: $e');
    }
  }


  static Future <void> cancelPayment(String voucherSerial,
      String reason, BuildContext context) async {
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

      DateFormat formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
      String cancelDateTime = formatter.format(DateTime.now());

      // Create the body map with the necessary information
      Map<String, String> body = {
        "voucherSerialNumber": voucherSerial,
        "cancelReason": reason,
        "cancelTransactionDate": cancelDateTime,
      };
    print("jj");
      print(body);
      try {
        final response = await http.delete(
          Uri.parse(apiUrlCancel),
          headers: headers,
          body: json.encode(body),
        );
        if (response.statusCode == 200) {
          print("inside status code 200 of cancel api :${response.body}");
          await DatabaseProvider.cancelPayment(
              voucherSerial, reason, cancelDateTime, 'Cancelled');

          _syncController.add(null);
        }
        else {
          Map<String, dynamic> errorResponse = json.decode(response.body);
          print("failed to sync heres the body of response: ${response.body}");
          if (errorResponse['error'] == 'Unauthorized' &&  errorResponse['errorInDetail'] == 'JWT Authentication Failed')
          {
            await _attemptReLoginAndRetrySync(context);
          } else {
            print('^ Failed to cancel/sync payment: ${response.body}');
          }
        }
      } catch (e) {
        await DatabaseProvider.cancelPayment(
            voucherSerial, reason, cancelDateTime,
            'CancelPending');
        _syncController.add(null);
        print('Error cancelling payment: $e');
      }
  }

  static Future<void> _attemptReLoginAndRetrySync(BuildContext context) async {
    Map<String, String?> credentials = await getCredentials();
    String? username = credentials['username'];
    String? password = credentials['password'];
     if (username != null && password != null) {
       LoginState loginState = LoginState();
       bool loginSuccessful = await loginState.login(username, password);
       if (loginSuccessful) {
        print("Re-login successful");
          await syncPayments(context); // Retry the sync with new token
      } else {
        print("Re-login failed. Unable to sync payment.");
        _showSessionExpiredDialog(context); // Show session expired message
        navigateToLoginScreen(context);
      }
    } else {
      print("Username or password is missing. Cannot attempt re-login.");
     }
  }

  static void _showSessionExpiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Session Expired'),
          content: Text('Your session has expired. Please contact the admin.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                navigateToLoginScreen(context); // Navigate to login screen
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  static Future <void> getExpiredPaymentsNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenID = prefs.getString('token');
    if (tokenID == null) {
      print('Token not found');
      return;
    }
    String fullToken = "Barer ${tokenID}";
    print("the token to user hen cancel :${fullToken}");


    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'tokenID': fullToken,
      };
      final response = await http.get(
        Uri.parse(apiUrlDeleteExpired),
        headers: headers,
      );

      if (response.statusCode == 200) {
        print(response.body);
      }
    } catch (e) {
      // Handle the error if needed
      print('Error deleting expired payment: $e');
    }
  }
}