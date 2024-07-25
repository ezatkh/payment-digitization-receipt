import 'dart:async';
import 'package:digital_payment_app/Screens/PaymentCancellationScreen.dart';
import 'package:digital_payment_app/Screens/PrintSettingsScreen.dart';
import 'package:digital_payment_app/Screens/RecordPaymentScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../Services/LocalizationService.dart';
import 'package:provider/provider.dart';
import '../Services/database.dart';
import '../Models/Payment.dart';
import 'PaymentConfirmationScreen.dart';
import '../Services/PaymentService.dart';
import 'package:intl/intl.dart';
import '../Services/database.dart';
import '../Custom_Widgets/CustomPopups.dart';




class PaymentHistoryScreen extends StatefulWidget {
  @override
  _PaymentHistoryScreenState createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  DateTime? _selectedFromDate;
  DateTime? _selectedToDate;
  String paymentHistory='';
  String from='';
  String to='';
  String search='';
  late StreamSubscription _syncSubscription;

  List<Payment> _paymentRecords = [];
  void _initializeLocalizationStrings( ) {
    final localizationService = Provider.of<LocalizationService>(
        context, listen: false);
    paymentHistory = localizationService.getLocalizedString('paymentHistory');
    from = localizationService.getLocalizedString('from');
    to = localizationService.getLocalizedString('to');
    search = localizationService.getLocalizedString('search');
  }

  @override
  void initState() {
    _fetchPayments();
    super.initState();
        // Initialize the localization strings
    print("payment after retrieve from database :");
    _initializeLocalizationStrings();
    _syncSubscription = PaymentService.syncStream.listen((_) {
      _fetchPayments(); // Refresh payment records
    });
  }

  @override
  void dispose() {
    _syncSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690));
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Container(
            color: Colors.white.withOpacity(0.2),
            height: 1.0,
          ),
        ),
        title: Text(paymentHistory,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontFamily: 'NotoSansUI',
            )),
        backgroundColor: Color(0xFFC62828),

      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildDateFilterSection(),
            SizedBox(height: 20.h),
            _buildSearchButton(),
            SizedBox(height: 20.h),
            _buildPaymentRecordsList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the RecordPaymentScreen to add a new payment
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RecordPaymentScreen()));
        },
        backgroundColor: Color(0xFFC62828),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildDateFilterSection() {
    return Row(
      children: [
        Expanded(
          child: _buildDateField(
            context,
            label: from,
            controller: _fromDateController,
            onDateSelected: (date) {
              setState(() => _selectedFromDate = date);
            },
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildDateField(
            context,
            label: to,
            controller: _toDateController,
            onDateSelected: (date) {
              setState(() => _selectedToDate = date);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context,
      {required String label,
        required TextEditingController controller,
        required Function(DateTime) onDateSelected}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Icon(Icons.calendar_today, color: Color(0xFFC62828)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        fillColor: Colors.white,
        filled: true,
      ),
      readOnly: true,
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null && picked != _selectedFromDate) {
          controller.text = DateFormat('yyyy-MM-dd').format(picked);
          onDateSelected(picked);
        }
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return ''; // handle null date
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Widget _buildSearchButton() {
    return ElevatedButton.icon(
      icon: Icon(Icons.search, color: Colors.white),
      label: Text(search,
          style: TextStyle(fontSize: 14.sp, fontFamily: 'NotoSansUI')),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFC62828),
        minimumSize: Size(double.infinity, 40.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () async {
        await DatabaseProvider.clearDatabase();
        // Add any post-operation logic if needed
      },
    );
  }

  Widget _buildPaymentRecordsList() {
    return _paymentRecords.isEmpty
        ? Center(child: Text('No records found'))
        : ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _paymentRecords.length,
      itemBuilder: (context, index) {
        return _buildPaymentRecordItem(_paymentRecords[index] );
      },
    );
  }
  String formatDateTimeWithoutMilliseconds(DateTime dateTime) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(dateTime);
  }

  Widget _buildPaymentRecordItem(Payment record) {
    IconData statusIcon;
    Color statusColor;

    // Determine icon and color based on payment status
    switch (record.status.toLowerCase()) {
      case 'saved':
        statusIcon = Icons.save_rounded;
        statusColor = Color(0xFF284DA6);
        break;
      case 'confirmed':
        statusIcon = Icons.sync_problem_outlined;
        statusColor = Colors.blue;
        break;
      case 'synced':
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        break;
      case 'canceled':
        statusIcon = Icons.cancel;
        statusColor = Colors.red;
        break;
      default:
        statusIcon = Icons.payment;
        statusColor = Color(0xFFC62828); // Default color
        break;
    }

    return Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    child: Theme(
    data: ThemeData(dividerColor: Colors.transparent),
    child: ExpansionTile(
    leading: CircleAvatar(
    backgroundColor: Colors.white,
    child: Icon(statusIcon, color: statusColor, size: 26),
    ),
    title: Text(record.customerName,
    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
    subtitle: Text('${record.status}',
    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
    childrenPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
    children: [
    (record.status.toLowerCase() == 'saved') ?
    _paymentDetailRow('Transaction Date', formatDateTimeWithoutMilliseconds(record.lastUpdatedDate!).toString()) :
    _paymentDetailRow('Transaction Date', formatDateTimeWithoutMilliseconds(record.transactionDate!).toString()),
       if (record.status.toLowerCase() == 'synced' || record.status.toLowerCase() == 'canceled')
       _paymentDetailRow('Voucher Serial Number', record.voucherSerialNumber),
    _paymentDetailRow('Payment Method', record.paymentMethod),
    _paymentDetailRow('Status', record.status),
    if (record.msisdn != null && record.msisdn!.isNotEmpty)
    _paymentDetailRow('MSISDN', record.msisdn.toString()),
    if (record.prNumber != null && record.prNumber!.isNotEmpty)
    _paymentDetailRow('#PR', record.prNumber.toString()),
    if (record.paymentMethod.toLowerCase() == 'cash')
    _paymentDetailRow('Amount', record.amount.toString()),
    if (record.paymentMethod.toLowerCase() == 'check')
    _paymentDetailRow('Amount', record.amountCheck.toString()),
      _paymentDetailRow('Currency', record.currency.toString()),
      if (record.paymentMethod.toLowerCase() == 'check')
    _paymentDetailRow('Check Number', record.checkNumber.toString()),
    if (record.paymentMethod.toLowerCase() == 'check')
    _paymentDetailRow('Bank/Branch', record.bankBranch.toString()),
    if (record.paymentMethod.toLowerCase() == 'check')
    _paymentDetailRow('Due Date', _formatDate(record.dueDateCheck)),
    if (record.paymentInvoiceFor != null && record.paymentInvoiceFor!.isNotEmpty)
    _paymentDetailRowWithMultiline('Payment Invoice For:', record.paymentInvoiceFor.toString()),
    SizedBox(height: 8.h),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Tooltip(
        message: 'View Payment Summary',
      child: IconButton(
      icon: Icon(Icons.visibility, color: Colors.blue), // View icon always on the left
      onPressed: () {
      if (record.id != null) {
      Navigator.pushReplacement(
      context,
      MaterialPageRoute(
      builder: (context) => PaymentConfirmationScreen(paymentId: record.id!),
      ),
      );
      } else {
      // Handle the case when record.id is null
      print('Error: record.id is null');
      }
      },
      ),
    ),
    // Icons to be shown based on status
    if (record.status.toLowerCase() == 'saved') ...[
      Tooltip(
        message: 'Delete Payment',
        child: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            CustomPopups.showCustomDialog(
              context: context,
              icon: Icon(Icons.delete_forever, size: 60, color: Colors.red),
              title: 'Confirm Delete',
              message: 'Are you sure you want to delete this payment record?',
              deleteButtonText: 'Delete',
              onPressButton: () async {
                final int id = record.id!;
                await DatabaseProvider.deletePayment(id);
                // Update the UI to reflect the deletion
                setState(() {
                _paymentRecords.removeWhere((item) => item.id == id);
                });
              },
            );

          },

        ),
      ),
      Tooltip(
        message: 'Edit Payment',
      child: IconButton(
      icon: Icon(Icons.edit, color: Color(0xFFA67438)),
      onPressed: () {
      Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => RecordPaymentScreen(id: record.id)),
      );
      },
      ),
    ),

      Tooltip(
        message: 'Save & Confirm Payment',
        child: IconButton(
          icon: Icon(Icons.check_circle, color: Colors.green),
          onPressed: () async {
            CustomPopups.showConfirmDialog(context, () async {
              if (record.id != null) {
                final int idToConfirm = record.id!;
                await DatabaseProvider.updatePaymentStatus(idToConfirm, 'Confirmed');
                _fetchPayments();
                PaymentService.syncPayments();
              }
            });
          },
        ),
      ),
    ] else if (record.status.toLowerCase() == 'synced') ...[
      Tooltip(
        message: 'Cancel Payment',
        child: IconButton(
          icon: Icon(Icons.cancel, color: Colors.red),
          onPressed: () {
            if (record.id != null) {
              final int idToCancel = record.id!;
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
      Tooltip(
        message: 'print Payment',
      child: IconButton(
      icon: Icon(Icons.print, color: Colors.black),
      onPressed: () {
        if (record.id != null) {
          final int idToPrint = record.id!;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrintSettingsScreen(id:idToPrint),
            ),
          );
        }
      },
      ),
    ),
    Tooltip(
      message: 'Send Payment Via whatsapp',
      child: IconButton(
      icon: Icon(Icons.send, color: Colors.green),
      onPressed: () {
      // Handle send action
      },
      ),
    ),

    ],
    ],
    ),
    ],
    onExpansionChanged: (bool expanded) {
    // Optionally add analytics or state management hooks here
    },
    ),
    ),);
  }


  Widget _paymentDetailRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 14.sp,fontWeight: FontWeight.w400,color: Colors.grey.shade500)),
          Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _paymentDetailRowWithMultiline(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(title,
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400,color: Colors.grey.shade500)),
          ),
          SizedBox(height: 4.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(value,
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  void _fetchPayments() async {
    print("_fetchPayments method in PaymentHistory screen started");
    List<Map<String, dynamic>> payments = await DatabaseProvider.getAllPayments();

    String? dueDateCheckString ;
    DateTime? dueDateCheck;
    String? lastUpdatedDateString ;
    DateTime? lastUpdatedDate;
    String? transactionDateString ;
    DateTime? transactionDate;
    String serialNumber="";
    setState(() {
      _paymentRecords = payments.map((payment) {
        dueDateCheckString = payment['dueDateCheck'];
        lastUpdatedDateString = payment['lastUpdatedDate'];
        transactionDateString = payment['transactionDate'];
        if(payment['voucherSerialNumber'] != null)
          serialNumber=payment['voucherSerialNumber'];
        if (dueDateCheckString != null && dueDateCheckString!.isNotEmpty) {
          try {
            dueDateCheck = DateFormat('yyyy-MM-dd').parse(dueDateCheckString!);
          } catch (e) {
            print('Error parsing dueDateCheck: $dueDateCheckString');
            dueDateCheck = null;
          }
        } else {
          dueDateCheck = null;
        }
        if (lastUpdatedDateString != null && lastUpdatedDateString!.isNotEmpty) {
          try {
            lastUpdatedDate =  DateTime.parse(lastUpdatedDateString!);
          } catch (e) {
            print('Error parsing dueDateCheck: $lastUpdatedDate');
            lastUpdatedDate = null;
          }
        } else {
          lastUpdatedDate = null;
        }
        if (transactionDateString != null && transactionDateString!.isNotEmpty) {
          try {
            transactionDate =  DateTime.parse(transactionDateString!);
          } catch (e) {
            print('Error parsing dueDateCheck: $transactionDate');
            transactionDate = null;
          }
        } else {
          transactionDate = null;
        }

        return Payment(
          id:payment['id'],
          transactionDate:transactionDate,
          lastUpdatedDate:lastUpdatedDate,
          customerName: payment['customerName'],
          msisdn: payment['msisdn'],
          prNumber: payment['prNumber'],
          paymentMethod: payment['paymentMethod'],
          amount: payment['amount'],
          currency: payment['currency'],
          amountCheck: payment['amountCheck'],
          checkNumber: payment['checkNumber'],
          bankBranch: payment['bankBranch'],
          dueDateCheck: dueDateCheck,
          paymentInvoiceFor: payment['paymentInvoiceFor'],
          status: payment['status'],
          voucherSerialNumber:serialNumber
        );
      }).toList();

    });
    print("_fetchPayments method in PaymentHistory screen finished");

  }
}

