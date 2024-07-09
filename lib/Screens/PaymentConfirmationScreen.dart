import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../Models/Payment.dart';
import '../Services/LocalizationService.dart';
import 'DashboardScreen.dart';
import 'package:intl/intl.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final Payment paymentDetails;

  PaymentConfirmationScreen({required this.paymentDetails});

  @override
  State<PaymentConfirmationScreen> createState() => _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  String amountCheck="";
  String checkNumber="";
  String bankBranch="";
  String dueDateCheck="";
  String amount="";
  String currency="";
  String saveTitle = '';
  String confirmPayment = '';
  String savePayment = '';
  String confirmTitle = '';
  String paymentSummary = '';
  String customerName = '';
  String paymentMethod = '';
  String confirm = '';
  String cancel = '';
  String paymentSuccessful = '';
  String paymentSuccessfulBody = '';
  String ok = '';
  String prNumber = '';
  String msisdn = '';

  @override
  void initState() {
    super.initState();
    // Initialize the localization strings
    _initializeLocalizationStrings();
  }

  void _initializeLocalizationStrings() {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    amountCheck = localizationService.getLocalizedString('amountCheck') ?? 'Confirm Payment';
    checkNumber = localizationService.getLocalizedString('checkNumber') ?? 'Confirm Payment';
    bankBranch = localizationService.getLocalizedString('bankBranchCheck') ?? 'Confirm Payment';
    dueDateCheck = localizationService.getLocalizedString('dueDateCheck') ?? 'Confirm Payment';
    amount = localizationService.getLocalizedString('amount') ?? 'Confirm Payment';
    currency = localizationService.getLocalizedString('currency') ?? 'Confirm Payment';
    ok = localizationService.getLocalizedString('ok') ?? 'Confirm Payment';

    prNumber = localizationService.getLocalizedString('PR') ?? 'Confirm Payment';
    msisdn = localizationService.getLocalizedString('MSISDN') ?? 'Confirm Payment';

    saveTitle = localizationService.getLocalizedString('saveTitle') ?? 'Confirm Payment';
    confirmTitle = localizationService.getLocalizedString('confirmTitle') ?? 'Confirm Payment';

    savePayment = localizationService.getLocalizedString('savePayment') ?? 'Save Payment';
    confirmPayment = localizationService.getLocalizedString('confirmPayment') ?? 'Confirm Payment';

    paymentSummary = localizationService.getLocalizedString('paymentSummary') ?? 'Payment Summary';
    customerName = localizationService.getLocalizedString('customerName') ?? 'Customer Name';
    paymentMethod = localizationService.getLocalizedString('paymentMethod') ?? 'Payment Method';

    confirm = localizationService.getLocalizedString('confirm') ?? 'Confirm';
    paymentSuccessful = localizationService.getLocalizedString('paymentSuccessful') ?? 'Payment Successful';
    paymentSuccessfulBody = localizationService.getLocalizedString('paymentSuccessfulBody') ?? 'Your payment was successful!';
    cancel = localizationService.getLocalizedString('cancel') ?? 'Cancel';
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.paymentDetails.status == 'saved'?saveTitle :confirmTitle, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontFamily: 'NotoSansUI')),
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
            _buildConfirmationActions(),
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
          Text(paymentSummary, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, fontFamily: 'NotoSansUI', color: Color(0xFFC62828))),
          Divider(color: Color(0xFFC62828), thickness: 1, height: 20.h),
          _detailItem(customerName, widget.paymentDetails.customerName),
          _detailItem(paymentMethod, widget.paymentDetails.paymentMethod),
          if (widget.paymentDetails.prNumber != null && widget.paymentDetails.prNumber!.isNotEmpty)
            _detailItem(prNumber, widget.paymentDetails.prNumber.toString()),
          if (widget.paymentDetails.msisdn != null && widget.paymentDetails.msisdn!.isNotEmpty)
            _detailItem(msisdn, widget.paymentDetails.msisdn.toString()),
          if (widget.paymentDetails.paymentMethod.toLowerCase() =="check" ||widget.paymentDetails.paymentMethod =="شيك")
            _detailItem(amountCheck, widget.paymentDetails.amountCheck.toString()),
          if (widget.paymentDetails.paymentMethod.toLowerCase() =="check" ||widget.paymentDetails.paymentMethod =="شيك")
            _detailItem(checkNumber, widget.paymentDetails.checkNumber.toString()),
          if (widget.paymentDetails.paymentMethod.toLowerCase() =="check" ||widget.paymentDetails.paymentMethod =="شيك")
            _detailItem(bankBranch, widget.paymentDetails.bankBranch.toString()),
          if (widget.paymentDetails.paymentMethod.toLowerCase() =="check" ||widget.paymentDetails.paymentMethod =="شيك")
            _detailItem(dueDateCheck, DateFormat('yyyy-MM-dd').format(widget.paymentDetails.dueDateCheck!).toString()),

          if (widget.paymentDetails.paymentMethod.toLowerCase() =="cach" ||widget.paymentDetails.paymentMethod =="كاش")
            _detailItem(amount, widget.paymentDetails.amount.toString()),
          if (widget.paymentDetails.paymentMethod.toLowerCase() =="cach" ||widget.paymentDetails.paymentMethod =="كاش")
          _detailItem(currency, widget.paymentDetails.currency.toString()),


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

  Widget _buildConfirmationActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _actionButton(cancel, Color(0xFFC62828), () => Navigator.of(context).pop()),
        _actionButton(widget.paymentDetails.status == 'saved'?savePayment :confirmPayment, Color(0xFF4CAF50), () => _confirmPayment()),
      ],
    );
  }

  void _confirmPayment() async {
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

    Navigator.pop(context); // Close the CircularProgressIndicator

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
                  color: Colors.white.withOpacity(0.2), // Semi-transparent white for glass effect
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(paymentSuccessful,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontFamily: 'NotoSansUI',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )),
                    SizedBox(height: 16.h),
                    Text(paymentSuccessfulBody,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: 'NotoSansUI',
                          color: Colors.white,
                        )),
                    SizedBox(height: 24.h),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 20.w),
                        backgroundColor: Colors.white.withOpacity(0.3), // Light transparent background
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18), // Rounded corners
                          side: BorderSide(
                            color: Color(0xFF4CAF50), // Same green color as the text
                            width: 1.5, // Not too thick border
                          ),
                        ),
                      ),
                      child: Text(
                        ok,
                        style: TextStyle(
                          fontFamily: 'NotoSansUI',
                          color: Color(0xFF4CAF50), // Green color for text
                          fontSize: 16.sp,
                          decoration: TextDecoration.none,
                        ),
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

  Widget _actionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
        textStyle: TextStyle(decoration: TextDecoration.none, fontSize: 16.sp, fontFamily: 'NotoSansUI', color: Colors.white),
      ),
      child: Text(text),
    );
  }
}
