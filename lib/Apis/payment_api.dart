import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Services/networking.dart';
import '../Services/database.dart';

class PaymentApi {
  static const String apiUrl = 'http://192.168.20.65:8080/payments/sync';

  static Future<void> syncConfirmedPayments() async {
    print("syncConfirmedPayments method invoked successfully *****");
    try {
      List<Map<String, dynamic>> confirmedPayments = await DatabaseProvider.getConfirmedPayments();
      Map<String, dynamic> payload;
      Map<String, dynamic> header;
      double amount;

      // Iterate through each confirmed payment
      for (var payment in confirmedPayments) {
        if(payment['paymentMethod'].toString().toLowerCase()=="cash") {
          amount = payment['amount'];
        }
        else {
          amount = payment['amountCheck'];
        }
          header = {
            "tokenID":"aaaa",
          };
         payload = {
           "accountName":payment['customerName'],
           "msisdn": payment['msisdn'],
           "pr": payment['prNumber'],
           "amount": amount,
           "currency": payment['currency'],
           "paymentMethod": payment['paymentMethod'],
           "checkNumber": payment['checkNumber'],
           "checkAmount":  payment['checkAmount'],
           "checkBank": payment['bankBranch'],
           "checkDueDate": payment['dueDateCheck'],
           "forThePaymentOfTheFollowingInvoice": payment['paymentInvoiceFor']
         };
         print("header:");
         print(header);

        print("payload:");
        print(payload);


        // Send data to API and get response
         var response = await NetworkHelper(url: apiUrl, map: payload).getData();
         print(response);
        //
        // Process API response
        //  if (response != null) {
        //    String voucherNumber = response['voucherNumber'];
        //  } // Adjust this based on your API response structure
        //
        //   // Update the payment in the local database with the voucher number and status 'Synced'
        //   await DatabaseProvider.updatePaymentvoucherSerialNumber(id, voucherNumber);
        //   await DatabaseProvider.updatePaymentStatus(id, 'Synced');
        //
        //   print('Payment with id $id synced successfully with voucher number $voucherNumber');
        // } else {
        //   print('Failed to sync payment with id $id');
        // }
      }
    }
    catch (e) {
      print('Error syncing payments: $e');
      // Handle errors as per your application's requirements
    }
  }
}
