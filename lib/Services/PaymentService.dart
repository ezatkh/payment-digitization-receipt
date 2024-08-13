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
  static final StreamController<void> _syncController = StreamController<void>.broadcast();
  static Stream<void> get syncStream => _syncController.stream;

  void navigateToLoginScreen(BuildContext context) {
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

  static void startPeriodicNetworkTest() {
    Timer.periodic(Duration(seconds: 5), (Timer timer) async {
      await testNetwork();
    });
  }

  static Future<void> testNetwork() async {
     var connectivityResult = await (Connectivity().checkConnectivity());
     print(connectivityResult);
     if(connectivityResult == ConnectivityResult.none){}
      else {
        PaymentService.syncPayments();
     }
     }

  static Future <void> syncPayment(Map<String, dynamic> payment, String apiUrl, Map<String, String> headers)async {

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
      'checkDueDate': payment['dueDateCheck'] != null && payment['dueDateCheck'] != 'null'
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
        await DatabaseProvider.updatePaymentvoucherSerialNumber(payment["id"], voucherSerialNumber);

        // Update payment status to 'Synced'
        await DatabaseProvider.updatePaymentStatus(payment["id"], 'Synced');
        _syncController.add(null);
      } else {
        Map<String, String?> credentials = await getCredentials();
        String? username = credentials['username'];
        String? password = credentials['password'];
print("username for relogin is : ${username} : password is : ${password}");
        if (username != null && password != null) {
          LoginState loginState = LoginState();
          bool loginSuccessful = await loginState.login(username, password);
          if (loginSuccessful) {
            print("relogin successfull");
          }
          else {
            print("expand relogin wrong");
          }

          }
        // Handle errors
        print('Failed to sync payment: ${response.body}');
      }
    } catch (e) {
      // Handle exceptions
      print('Error syncing payment: $e');
    }
  }

  static Future<void> syncPayments() async {

     SharedPreferences prefs = await SharedPreferences.getInstance();
     String? tokenID = prefs.getString('token');

     if (tokenID == null) {
       print('Token not found');
       return;
     }

     String fullToken="Barer ${tokenID}";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'tokenID': fullToken,
    };
     // Retrieve all confirmed payments
    List<Map<String, dynamic>> ConfirmedAndCancelledPendingPayments = await DatabaseProvider.getConfirmedOrCancelledPendingPayments();
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
      PaymentService.syncPayment(payment,apiUrl,headers);
    }

    for(var p in cancelledPendingPayments){
      Map<String, String> body = {
        "voucherSerialNumber": p["voucherSerialNumber"],
        "cancelReason": p["reason"].toString(),
        "cancellationDate":  DateTime.parse(p["cancellationDate"]).toIso8601String(),
      };
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

  static Future <void> cancelPayment(String voucherSerial , String reason) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenID = prefs.getString('token');

    if (tokenID == null) {
      print('Token not found');
      return;
    }
    String fullToken="Barer ${tokenID}";
    print("the token to user hen cancel :${fullToken}");


    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'tokenID': fullToken,
      };

       DateFormat formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
      String cancelDateTime= formatter.format(DateTime.now());

      // Create the body map with the necessary information
      Map<String, String> body = {
        "voucherSerialNumber": voucherSerial,
        "cancelReason": reason,
        "cancelTransactionDate":  cancelDateTime,
      };
      print(body);
      print("cancellation date : $cancelDateTime");
      try {
        final response = await http.delete(
          Uri.parse(apiUrlCancel),
          headers: headers,
          body: json.encode(body),
        );
        if (response.statusCode == 200) {
          print("inside status code 200 of cancel api");
          await DatabaseProvider.cancelPayment(voucherSerial,reason,cancelDateTime.toString(),'Cancelled');

          _syncController.add(null);
        } else {
          await DatabaseProvider.cancelPayment(voucherSerial,reason,cancelDateTime.toString(),'CancelPending');
          _syncController.add(null);
          print('Failed to cancel payment: ${response.body}');
        }
      } catch (e) {
        await DatabaseProvider.cancelPayment(voucherSerial,reason,cancelDateTime.toString(),'CancelPending');
        _syncController.add(null);
        // Handle exceptions
        print('Error syncing payment: $e');
      }


    } catch (e) {
      // Handle the error if needed
      print('Error cancelling payment: $e');
    }
  }

  static Future <void> getExpiredPaymentsNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenID = prefs.getString('token');
    if (tokenID == null) {
      print('Token not found');
      return;
    }
    String fullToken="Barer ${tokenID}";
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
