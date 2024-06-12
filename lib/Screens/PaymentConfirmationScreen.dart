import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'DashboardScreen.dart';

class PaymentConfirmationScreen extends StatelessWidget {
  final PaymentDetails paymentDetails;

  PaymentConfirmationScreen({required this.paymentDetails});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690));
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Payment', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontFamily: 'NotoSansUI')),
        backgroundColor: Color(0xFFC62828),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPaymentDetailCard(),
            SizedBox(height: 24.h),
            _buildConfirmationActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Summary', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, fontFamily: 'NotoSansUI', color: Color(0xFFC62828))),
          Divider(color: Color(0xFFC62828), thickness: 1, height: 20.h),
          _detailItem('Customer Name', paymentDetails.customerName),
          _detailItem('MSISDN', paymentDetails.msisdn),
          _detailItem('PR#', paymentDetails.prNumber),
          _detailItem('Amount', ' ${paymentDetails.amount.toStringAsFixed(2)}'),
          _detailItem('Currency', paymentDetails.currency),
          _detailItem('Payment Method', paymentDetails.paymentMethod),
          _detailItem('Date', paymentDetails.date),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, fontFamily: 'NotoSansUI', color: Colors.grey.shade800)),
          Flexible(
            child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontSize: 16.sp, fontFamily: 'NotoSansUI', color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _actionButton(context, 'Cancel', Colors.red.shade300, () => Navigator.of(context).pop()),
        _actionButton(context, 'Confirm', Color(0xFF4CAF50), () => _confirmPayment(context)),
      ],
    );
  }
  void _confirmPayment(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // Simulate a network request/waiting time
    await Future.delayed(Duration(seconds: 2));

    Navigator.pop(context);  // Close the CircularProgressIndicator

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                width: 300.w,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),  // Semi-transparent white for glass effect
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Payment Successful',
                        textAlign: TextAlign.center,
                        style: TextStyle(decoration: TextDecoration.none,
                          fontSize: 20.sp,
                          fontFamily: 'NotoSansUI',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )
                    ),
                    SizedBox(height: 16.h),
                    Text('The payment has been successfully processed.',
                        textAlign: TextAlign.center,
                        style: TextStyle(decoration: TextDecoration.none,
                          fontSize: 16.sp,
                          fontFamily: 'NotoSansUI',
                          color: Colors.white,
                        )
                    ),
                    SizedBox(height: 24.h),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 20.w),
                        backgroundColor: Colors.white.withOpacity(0.3), // Light transparent background
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18), // Rounded corners
                            side: BorderSide(
                                color: Color(0xFF4CAF50), // Same green color as the text
                                width: 1.5 // Not too thick border
                            )
                        ),
                      ),
                      child: Text(
                          'OK',
                          style: TextStyle(
                            fontFamily: 'NotoSansUI',
                            color: Color(0xFF4CAF50), // Green color for text
                            fontSize: 16.sp,
                            decoration: TextDecoration.none,
                          )
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop(); // Dismiss the dialog
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen())); // Navigate to Dashboard
                      },
                    )

                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

  }

  Widget _actionButton(BuildContext context, String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
        textStyle: TextStyle(decoration: TextDecoration.none,fontSize: 16.sp, fontFamily: 'NotoSansUI', color: Colors.white),
      ),
      child: Text(text),
    );
  }
}

class PaymentDetails {
  final String customerName;
  final String msisdn;
  final String prNumber;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String date;

  PaymentDetails({
    required this.customerName,
    required this.msisdn,
    required this.prNumber,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.date,
  });
}
