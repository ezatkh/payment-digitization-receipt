import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:digital_payment_app/Services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'apiConstants.dart';

class PaymentService {
  static final StreamController<void> _syncController = StreamController<void>.broadcast();
  static Stream<void> get syncStream => _syncController.stream;

  static Future<void> testNetwork() async {
     var connectivityResult = await (Connectivity().checkConnectivity());
     print(connectivityResult);
     if(connectivityResult == ConnectivityResult.none){
       print("no internet");
     }
      else {
        print("connected enternet ");
        PaymentService.syncPayments();
     }
     }

  static void startPeriodicNetworkTest() {
    Timer.periodic(Duration(seconds: 10), (Timer timer) async {
      await testNetwork();
    });
  }

  static Future<void> syncPayments() async {

    print("syncPayments methodse");
     SharedPreferences prefs = await SharedPreferences.getInstance();
     String? tokenID = prefs.getString('token');

     if (tokenID == null) {
       print('Token not found');
       return;
     }
     String fullToken="Barer ${tokenID}";;

     // Retrieve all confirmed payments
    List<Map<String, dynamic>> confirmedPayments = await DatabaseProvider.getConfirmedPayments();
// Assuming NumberToWordsEnglish.convert expects an int
    String convertAmountToWords(dynamic amount) {
      if (amount == null) {
        return ''; // Handle the case where amount is null
      }

      // Convert to int if amount is a double
      int amountInt = (amount is double) ? amount.toInt() : amount as int;

      return NumberToWordsEnglish.convert(amountInt);
    }

    // Iterate over each payment
    for (var payment in confirmedPayments) {
      // Create request headers
      String theSumOf = payment['paymentMethod'].toLowerCase() == 'cash'
          ? convertAmountToWords(payment['amount'])
          : convertAmountToWords(payment['amountCheck']);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'tokenID': fullToken,
      };
      // Create request body
      Map<String, dynamic> body = {
        'transactionDate':  payment['transactionDate'],
        'accountName':  payment['customerName'],
        'msisdn': payment['msisdn'] ,
        'pr': payment['prNumber'] ,
        'amount': payment['amount'] ,
        'currency': payment['currency'] ,
        'paymentMethod': payment['paymentMethod'] ,
        'checkNumber': payment['checkNumber'] ,
        'checkAmount': payment['amountCheck'] ,
        'checkBank': payment['bankBranch'] ,
        'checkDueDate': payment['dueDateCheck'] != null && payment['dueDateCheck'] != 'null' ? DateTime.parse(payment['dueDateCheck']).toIso8601String() : null,
        'theSumOf': theSumOf
      };
      //
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
          // Handle errors
          print('Failed to sync payment: ${response.body}');
        }
      } catch (e) {
        // Handle exceptions
        print('Error syncing payment: $e');
      }
    }
  }
}
