import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Services/LocalizationService.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Services/PaymentService.dart';
import '../Services/database.dart';

class PaymentCancellationScreen extends StatefulWidget {
  final int id;

  PaymentCancellationScreen({required this.id});

  @override
  _PaymentCancellationScreenState createState() => _PaymentCancellationScreenState();
}

class _PaymentCancellationScreenState extends State<PaymentCancellationScreen> {
  final TextEditingController _reasonController = TextEditingController();
  String? _errorText;

  void _initializeLocalizationStrings(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
  }

  Future<String?> _fetchVoucherNumber(int id) async {
    print("_fetchVoucherNumber method , PaymentCancellation.dart started");
    final payment = await DatabaseProvider.getPaymentById(id);
    print(payment);
    print("_fetchVoucherNumber method , PaymentCancellation.dart finished");

    return payment?['voucherSerialNumber'];
  }

  void _confirmCancellationAction(BuildContext context, String voucher, String reason) async {
    try {
      // Get the current date and time
      DateTime now = DateTime.now();



      // Call the cancelPayment method with the formatted date string
      await DatabaseProvider.cancelPayment(voucher, reason, now);
      // Sync payments after cancellation
      PaymentService.syncPayments();

      // Close the dialog
      Navigator.of(context).pop();
    } catch (e) {
      // Handle the error if needed
      print('Error cancelling payment: $e');
    }
  }

  void _handleCancellation(BuildContext context, String voucher) {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      setState(() {
        _errorText = 'Reason for cancellation is required';
      });
    } else {
      setState(() {
        _errorText = null;
      });
      _confirmCancellationAction(context, voucher, reason);
    }
  }

  @override
  Widget build(BuildContext context) {
    _initializeLocalizationStrings(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: FutureBuilder<String?>(
          future: _fetchVoucherNumber(widget.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error fetching voucher number'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('No voucher number found'));
            }

            final voucherNumber = snapshot.data!;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cancel Payment',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Voucher Number: $voucherNumber',
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Reason for Cancellation',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter the reason...',
                    fillColor: Color(0xFFF2F2F2),
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    errorText: _errorText,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel', style: TextStyle(fontSize: 16.sp)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFC62828),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        _handleCancellation(context, voucherNumber);
                      },
                      child: Text('Confirm', style: TextStyle(fontSize: 16.sp)),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}
