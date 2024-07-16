import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:digital_payment_app/Services/database.dart';
import 'package:digital_payment_app/Models/Payment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  final String apiUrl = 'https://example.com/api/syncPayment';

  Future<void> syncPayment(Payment payment) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenID = prefs.getString('token');
    if (tokenID == null) {
      print('Token not found');
      return;
    }

    // Create request headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'tokenID': tokenID,
    };

    // Create request body
    Map<String, dynamic> body = {
      'accountName': payment.customerName,
      'msisdn': payment.msisdn,
      'amount': payment.amount,
      'currency': payment.currency,
      'paymentMethod': payment.paymentMethod,
      'checkNumber': payment.checkNumber,
      'checkAmount': payment.amountCheck,
      'checkBank': payment.bankBranch,
      'checkDueDate': payment.dueDateCheck?.toIso8601String(),
    };

    try {
      // Make POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        // Parse the response
        Map<String, dynamic> responseBody = json.decode(response.body);
        String voucherNumber = responseBody['voucherNumber'];

        // Update payment in local database
        await DatabaseProvider.updateVoucherById(payment.id!, voucherNumber);

        // Update payment status to 'Synced'
        await DatabaseProvider.updatePaymentStatus(payment.id!, 'Synced');
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
