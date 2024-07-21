import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:digital_payment_app/Services/database.dart';
import 'package:digital_payment_app/Models/Payment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  final String apiUrl = 'http://192.168.20.65:8080/payments/sync';

  Future<void> syncPayments() async {
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

    // Iterate over each payment
    for (var payment in confirmedPayments) {
      // Create request headers
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'tokenID': fullToken,
      };
      // Create request body
      Map<String, dynamic> body = {
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
