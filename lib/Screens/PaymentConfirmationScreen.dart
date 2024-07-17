import 'dart:async';
import 'dart:ui';
import 'package:digital_payment_app/Screens/PaymentHistoryScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../Models/Payment.dart';
import '../Services/LocalizationService.dart';
import 'package:intl/intl.dart';
import 'package:number_to_word_arabic/number_to_word_arabic.dart';
import 'package:number_to_words_english/number_to_words_english.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final Payment paymentDetails;

  PaymentConfirmationScreen({required this.paymentDetails});

  @override
  State<PaymentConfirmationScreen> createState() => _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  String paymentInvoiceFor = "";
  String amountCheck = "";
  String checkNumber = "";
  String bankBranch = "";
  String dueDateCheck = "";
  String amount = "";
  String currency = "";
  String viewPayment = '';
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
  String status = '';
  String theSumOf = '';
  String numberConvertBody = '';
  String languageCode = "";

  @override
  void initState() {
    super.initState();
    _initializeLocalizationStrings();
  }

  void _initializeLocalizationStrings() {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    languageCode = localizationService.selectedLanguageCode;
    paymentInvoiceFor = localizationService.getLocalizedString('paymentInvoiceFor') ?? 'Confirm Payment';
    amountCheck = localizationService.getLocalizedString('amountCheck') ?? 'Confirm Payment';
    checkNumber = localizationService.getLocalizedString('checkNumber') ?? 'Confirm Payment';
    bankBranch = localizationService.getLocalizedString('bankBranchCheck') ?? 'Confirm Payment';
    dueDateCheck = localizationService.getLocalizedString('dueDateCheck') ?? 'Confirm Payment';
    amount = localizationService.getLocalizedString('amount') ?? 'Confirm Payment';
    currency = localizationService.getLocalizedString('currency') ?? 'Confirm Payment';

    ok = localizationService.getLocalizedString('ok') ?? 'Confirm Payment';
    status = localizationService.getLocalizedString('status') ?? '';
    prNumber = localizationService.getLocalizedString('PR') ?? 'Confirm Payment';
    msisdn = localizationService.getLocalizedString('MSISDN') ?? 'Confirm Payment';
    theSumOf = localizationService.getLocalizedString('theSumOf') ?? 'Confirm Payment';

    viewPayment = localizationService.getLocalizedString('viewPayment') ?? 'Confirm Payment';
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
        title: Text(viewPayment, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontFamily: 'NotoSansUI')),
        backgroundColor: Color(0xFFC62828),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPaymentDetailCard(),
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
          _buildSummaryHeader(),
          Divider(color: Color(0xFFC62828), thickness: 1, height: 20.h),
          _detailItem(customerName, widget.paymentDetails.customerName),
          _divider(),
          _detailItem(status, widget.paymentDetails.status),
          _divider(),
          _detailItem(paymentMethod, widget.paymentDetails.paymentMethod),
          _divider(),
          (widget.paymentDetails.prNumber != null && widget.paymentDetails.prNumber!.isNotEmpty)
              ? _detailItem(prNumber, widget.paymentDetails.prNumber.toString())
              : _detailItem(prNumber, ''),
          _divider(),
          (widget.paymentDetails.msisdn != null && widget.paymentDetails.msisdn!.isNotEmpty)
              ? _detailItem(msisdn, widget.paymentDetails.msisdn.toString())
              : _detailItem(msisdn, ''),
          if (widget.paymentDetails.paymentMethod.toLowerCase() == "check" || widget.paymentDetails.paymentMethod == "شيك")
            _divider(),
          if (widget.paymentDetails.paymentMethod.toLowerCase() == "check" || widget.paymentDetails.paymentMethod == "شيك")
            _detailItem(amountCheck, widget.paymentDetails.amountCheck.toString()),
          if (widget.paymentDetails.paymentMethod.toLowerCase() == "check" || widget.paymentDetails.paymentMethod == "شيك")
            _detailNoteItem(theSumOf, (languageCode) == 'ar' ? Tafqeet.convert(widget.paymentDetails.amountCheck.toString()) : NumberToWordsEnglish.convert(widget.paymentDetails.amountCheck!.toInt())),
          if (widget.paymentDetails.paymentMethod.toLowerCase() == "cash" || widget.paymentDetails.paymentMethod == "كاش")
            _divider(),
          if (widget.paymentDetails.paymentMethod.toLowerCase() == "check" || widget.paymentDetails.paymentMethod == "شيك")
          _divider(),
          if (widget.paymentDetails.paymentMethod.toLowerCase() == "check" || widget.paymentDetails.paymentMethod == "شيك")
            _detailItem(checkNumber, widget.paymentDetails.checkNumber.toString()),
          if (widget.paymentDetails.paymentMethod.toLowerCase() == "check" || widget.paymentDetails.paymentMethod == "شيك")
          _divider(),
          if (widget.paymentDetails.paymentMethod.toLowerCase() == "check" || widget.paymentDetails.paymentMethod == "شيك")
            _detailItem(bankBranch, widget.paymentDetails.bankBranch.toString()),
          if (widget.paymentDetails.paymentMethod.toLowerCase() == "check" || widget.paymentDetails.paymentMethod == "شيك")
          _divider(),
          if (widget.paymentDetails.paymentMethod.toLowerCase() == "check" || widget.paymentDetails.paymentMethod == "شيك")
            _detailItem(dueDateCheck, DateFormat('yyyy-MM-dd').format(widget.paymentDetails.dueDateCheck!).toString()),
          if (widget.paymentDetails.paymentMethod.toLowerCase() == "check" || widget.paymentDetails.paymentMethod == "شيك")
            _divider(),
          if (widget.paymentDetails.paymentMethod.toLowerCase() == "cash" || widget.paymentDetails.paymentMethod == "كاش")
            _detailItem(amount, widget.paymentDetails.amount.toString()),
          if (widget.paymentDetails.paymentMethod.toLowerCase() == "cash" || widget.paymentDetails.paymentMethod == "كاش")
          _divider(),
          if (widget.paymentDetails.paymentMethod.toLowerCase() == "cash" || widget.paymentDetails.paymentMethod == "كاش")
            _detailNoteItem(theSumOf, (languageCode) == 'ar' ? Tafqeet.convert(widget.paymentDetails.amount.toString()) : NumberToWordsEnglish.convert(widget.paymentDetails.amount!.toInt())),
          if (widget.paymentDetails.paymentMethod.toLowerCase() == "cash" || widget.paymentDetails.paymentMethod == "كاش")
            _divider(),
          if (widget.paymentDetails.paymentMethod.toLowerCase() == "cash" || widget.paymentDetails.paymentMethod == "كاش")
            _detailItem(currency, widget.paymentDetails.currency.toString()),
          if (widget.paymentDetails.paymentMethod.toLowerCase() == "cash" || widget.paymentDetails.paymentMethod == "كاش")
            _divider(),
          (widget.paymentDetails.paymentInvoiceFor != null && widget.paymentDetails.paymentInvoiceFor!.isNotEmpty)
              ? _detailNoteItem(paymentInvoiceFor, widget.paymentDetails.paymentInvoiceFor.toString())
              : _detailNoteItem(paymentInvoiceFor, ""),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          paymentSummary,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, fontFamily: 'NotoSansUI', color: Color(0xFFC62828)),
        ),
        IconButton(
          icon: Icon(Icons.more_horiz, color: Color(0xFFC62828)),
          onPressed: () {
            _showActionMenu(context);
          },
        ),
      ],
    );
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildActionButtons(),
          ),
        );
      },
    );
  }
  List<Widget> _buildActionButtons() {
    List<Widget> buttons = [];

    if (widget.paymentDetails.status.toLowerCase() == 'saved') {
      buttons.add(_actionButton('Confirm', Icons.thumb_up, () {
        // Handle edit action
        Navigator.pop(context);
      }));
      buttons.add(_actionButton('Edit', Icons.edit, () {
        // Handle edit action
        Navigator.pop(context);
      }));
      buttons.add(_actionButton('Delete', Icons.delete, () {
        // Handle delete action
        Navigator.pop(context);
      }));
    } else if (widget.paymentDetails.status.toLowerCase() == 'synced') {
      buttons.add(_actionButton('Print', Icons.print, () {
        // Handle print action
        Navigator.pop(context);
      }));
      buttons.add(_actionButton('Send', Icons.send, () {
        // Handle send action
        Navigator.pop(context);
      }));
      buttons.add(_actionButton('Cancel', Icons.cancel, () {
        // Handle cancel action
        Navigator.pop(context);
      }));
    }

    return buttons;
  }



  Widget _actionButton(String label, IconData icon, VoidCallback onPressed) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(label, style: TextStyle(color: Colors.black)),
      onTap: onPressed,
    );
  }

  Widget _detailNoteItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, fontFamily: 'NotoSansUI', color: Colors.grey.shade800)),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white, // Set to white
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, width: 1), // Add border here
            ),
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp, fontFamily: 'NotoSansUI', color: Colors.black87),
              maxLines: null, // Allow unlimited lines
              textAlign: TextAlign.left,
            ),
          ),
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
          Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, fontFamily: 'NotoSansUI', color: Colors.grey.shade800)),
          Flexible(
            child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontSize: 14.sp, fontFamily: 'NotoSansUI', color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(color: Colors.grey.shade300, height: 10.h);
  }
}
