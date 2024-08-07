import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../Services/LocalizationService.dart';
import 'package:intl/intl.dart';
import 'package:number_to_word_arabic/number_to_word_arabic.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import '../Services/PaymentService.dart';
import '../Services/database.dart';
import 'PaymentCancellationScreen.dart';
import 'PaymentHistoryScreen.dart';
import '../Custom_Widgets/CustomPopups.dart';
import 'package:digital_payment_app/Screens/RecordPaymentScreen.dart';
import 'package:digital_payment_app/Screens/ShareScreenOptions.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final int paymentId;
  Map<String, dynamic>? paymentDetails;
  late StreamSubscription _syncSubscription;
  PaymentConfirmationScreen({required this.paymentId});

  @override
  State<PaymentConfirmationScreen> createState() => _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  String voucherNumber = "";
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
  String transactionDate = '';
  String cancellationDate = '';
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
  String cancelReason = "";

  String saved= "";
  String synced= "";
  String confirmed= "";
  String cancelled= "";
  String cancelPending= "";

  late StreamSubscription _syncSubscription;

  @override
  void initState() {
    super.initState();
    _initializeLocalizationStrings();
  //  syncPayments
    _syncSubscription = PaymentService.syncStream.listen((_) {
      _fetchPaymentDetails();
    });
  }

  @override
  void dispose() {
    _syncSubscription.cancel();
    super.dispose();
  }

  void _initializeLocalizationStrings() {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    languageCode = localizationService.selectedLanguageCode;
    voucherNumber = localizationService.getLocalizedString('voucherNumber') ?? 'Voucher Number';
    paymentInvoiceFor = localizationService.getLocalizedString('paymentInvoiceFor') ?? 'Confirm Payment';
    amountCheck = localizationService.getLocalizedString('amountCheck') ?? 'Confirm Payment';
    checkNumber = localizationService.getLocalizedString('checkNumber') ?? 'Confirm Payment';
    bankBranch = localizationService.getLocalizedString('bankBranchCheck') ?? 'Confirm Payment';
    dueDateCheck = localizationService.getLocalizedString('dueDateCheck') ?? 'Confirm Payment';
    amount = localizationService.getLocalizedString('amount') ?? 'Confirm Payment';
    currency = localizationService.getLocalizedString('currency') ?? 'Confirm Payment';
    cancellationDate = localizationService.getLocalizedString('cancellationDate') ?? 'Confirm Payment';

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
    cancelReason = localizationService.getLocalizedString('cancelReason') ?? 'Confirm Payment';

    transactionDate = localizationService.getLocalizedString('transactionDate') ?? 'Confirm Payment';
    saved = localizationService.getLocalizedString('saved') ?? 'Confirm Payment';
    synced = localizationService.getLocalizedString('synced') ?? 'Confirm Payment';
    confirmed = localizationService.getLocalizedString('confirmed') ?? 'Confirm Payment';
    cancelled = localizationService.getLocalizedString('cancelled') ?? 'Confirm Payment';
    cancelPending = localizationService.getLocalizedString('cancelpending') ?? 'Confirm Payment';

  }

  Future<void> _fetchPaymentDetails() async {
    try {
      widget.paymentDetails = await DatabaseProvider.getPaymentById(widget.paymentId);
      if (widget.paymentDetails != null) {
        setState(() {});
      } else {
        print('No payment details found for ID ${widget.paymentId}');
      }
    } catch (e) {
      print('Error fetching payment details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          viewPayment,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontFamily: 'NotoSansUI',
          ),
        ),
        backgroundColor: Color(0xFFC62828),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => PaymentHistoryScreen()),
            );
          },
        ),
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
    if (widget.paymentDetails == null) {
      return Center(child: CircularProgressIndicator());
    }

     final paymentDetails = widget.paymentDetails!;

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
          _buildSummaryHeader(paymentDetails['status'].toLowerCase()),

          Divider(color: Color(0xFFC62828), thickness: 2, height: 15.h),

          if ((paymentDetails['status']?.toLowerCase() == "synced") || (paymentDetails['status']?.toLowerCase() == "cancelled") || (paymentDetails['status']?.toLowerCase() == "canceldpending")) ...[
            _detailItem(voucherNumber, paymentDetails['voucherSerialNumber'] ?? ''),
            _divider(),

          ],
          _detailItem(transactionDate, paymentDetails['status']?.toLowerCase() == "saved"
              ? (paymentDetails['lastUpdatedDate'] != null
              ? DateFormat('yyyy-MM-dd').format(DateTime.parse(paymentDetails['lastUpdatedDate']))
              : '')
              : (paymentDetails['transactionDate'] != null
              ? DateFormat('yyyy-MM-dd').format(DateTime.parse(paymentDetails['transactionDate']))
              : '')),
          _divider(),
          if ((paymentDetails['status']?.toLowerCase() == "cancelled") || (paymentDetails['status']?.toLowerCase() == "canceldpending"))
            ...[
              _detailItem(cancellationDate, paymentDetails['cancellationDate']?.toString() ?? ''),
              _divider(),
              _detailItem(cancelReason, paymentDetails['cancelReason']?.toString() ?? ''),
              _divider(),
            ],


            _detailItem(customerName, paymentDetails['customerName'] ?? ''),
          _divider(),
          _detailItem(status,Provider.of<LocalizationService>(context, listen: false).getLocalizedString(paymentDetails['status'].toLowerCase()) ?? ''),
          _divider(),
          _detailItem(prNumber, paymentDetails['prNumber']?.toString() ?? ''),
          _divider(),
          _detailItem(msisdn, paymentDetails['msisdn']?.toString() ?? ''),
          _divider(),
          _detailItem(paymentMethod, paymentDetails['paymentMethod'] ?? ''),

          if ((paymentDetails['paymentMethod']?.toLowerCase() == "check") || (paymentDetails['paymentMethod'] == "شيك")) ...[
            _divider(),
            _detailItem(amountCheck, paymentDetails['amountCheck']?.toString() ?? ''),
            _divider(),
            _detailItem(currency, paymentDetails['currency']?.toString() ?? ''),
            _divider(),
            _detailNoteItem(
                theSumOf,
                languageCode == 'ar'
                    ? Tafqeet.convert(paymentDetails['amountCheck']?.toString() ?? '')
                    : NumberToWordsEnglish.convert(paymentDetails['amountCheck'] != null ? (paymentDetails['amountCheck'] as double).toInt() : 0)
            ),
            _divider(),
            _detailItem(checkNumber, paymentDetails['checkNumber']?.toString() ?? ''),
            _divider(),
            _detailItem(bankBranch, paymentDetails['bankBranch']?.toString() ?? ''),
            _divider(),
            _detailItem(dueDateCheck, paymentDetails['dueDateCheck']?.toString() ?? ''),
          ],
          if ((paymentDetails['paymentMethod']?.toLowerCase() == "cash") || (paymentDetails['paymentMethod'] == "كاش")) ...[
            _divider(),
            _detailItem(amount, paymentDetails['amount']?.toString() ?? ''),
            _divider(),
            _detailItem(currency, paymentDetails['currency']?.toString() ?? ''),
            _divider(),
            _detailNoteItem(
              theSumOf,
              languageCode == 'ar'
                  ? Tafqeet.convert(paymentDetails['amount']?.toString() ?? '')
                  : NumberToWordsEnglish.convert(paymentDetails['amount'] != null ? (paymentDetails['amount'] as double).toInt() : 0),
            ),
          ],
          _divider(),
          _detailNoteItem(paymentInvoiceFor, paymentDetails['paymentInvoiceFor']?.toString() ?? ''),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(String paymentStatus) {
    // Determine if icons should be shown based on conditions
    bool canEdit = paymentStatus == 'saved';
    bool canDelete = paymentStatus == 'saved';
    bool canConfirm = paymentStatus == 'saved';
    bool canSend = paymentStatus == 'synced';
    bool canCancel = paymentStatus == 'synced';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          paymentSummary,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            if (canCancel)
              Tooltip(
                message: 'Cancel Payment',
                child: IconButton(
                  icon: Icon(Icons.cancel, color: Colors.red),
                  onPressed: () {
                    if (widget.paymentId != null) {
                      final int idToCancel = widget.paymentId!;
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return PaymentCancellationScreen(id: idToCancel);
                        },
                      );
                    }
                  },
                ),
              ),
            if (canSend)
              Tooltip(
                  message: 'Share Payment',
                  child:IconButton(
              icon: Icon(Icons.send, color: Colors.green),
              onPressed: () {
                ShareScreenOptions.showLanguageSelectionAndShare(context, widget.paymentId);

              },
                  ),),

            if (canDelete)
              Tooltip(
                message: 'Delete Payment',
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    CustomPopups.showCustomDialog(  context: context,
                      icon: Icon(Icons.delete_forever, size: 60, color: Colors.red),
                      title: 'Cancel Payment',
                      message: 'Are you sure you want to cancel this payment?',
                      deleteButtonText: 'Ok',
                      onPressButton: () {
                        // Your delete logic here
                      },);
                  },
                ),
              ),
            if (canEdit)
              Tooltip(
                message: 'Edit Payment',
                child: IconButton(
                  icon: Icon(Icons.edit, color: Color(0xFFA67438)),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => RecordPaymentScreen(id: widget.paymentId)),
                    );
                  },
                ),
              ),
            if (canConfirm)
              Tooltip(
                message: 'Save & Confirm Payment',
                child: IconButton(
                  icon: Icon(Icons.check_circle, color: Colors.blue),
                  onPressed: () {
                    CustomPopups.showCustomDialog(
                      context: context,
                      icon: Icon(Icons.warning, size: 60.0, color: Color(0xFFC62828)),
                      title: 'Save & Confirm Payment',
                      message: 'Are you sure you want to save & confirm this payment record?',
                      deleteButtonText: 'Ok',
                      onPressButton: () async {
                        showDialog( context: context,  barrierDismissible: false,  builder: (BuildContext dialogContext) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        );
                        // Simulate a network request/waiting time
                        await Future.delayed(Duration(seconds: 2));
                        DatabaseProvider.updatePaymentStatus(widget.paymentId,'Confirmed');
                        Navigator.pop(context); // pop the dialog
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PaymentConfirmationScreen(paymentId: widget.paymentId))); // Navigate to view payment screen after agreed

                      },
                    );
                    },
                ),
              ),

          ],
        ),
      ],
    );
  }


  Widget _detailItem(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailNoteItem(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(color: Color(0xFFCCCCCC), height: 10.h);
  }
}
