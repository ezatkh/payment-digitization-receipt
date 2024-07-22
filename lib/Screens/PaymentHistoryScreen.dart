import 'package:digital_payment_app/Screens/PaymentCancellationScreen.dart';
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
              fontSize: 20.sp,
              fontFamily: 'NotoSansUI',
            )),
        backgroundColor: Color(0xFFC62828),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.network_cell),
            onPressed: () {
              PaymentService paymentService= new PaymentService();
              paymentService.syncPayments();
            },
          ),
        ],
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => RecordPaymentScreen()));
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
          subtitle: Text('${record.status} ',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
          childrenPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          children: [
            (record.status.toLowerCase() == 'saved')?
            _paymentDetailRow('Transaction Date', formatDateTimeWithoutMilliseconds(record.lastUpdatedDate!).toString()):
            _paymentDetailRow('Transaction Date', formatDateTimeWithoutMilliseconds(record.transactionDate!).toString()),
            _paymentDetailRow('Payment Method', record.paymentMethod),
            _paymentDetailRow('Status', record.status),
            if (record.msisdn != null && record.msisdn!.length > 0)
              _paymentDetailRow('MSISDN', record.msisdn.toString()),
            if (record.prNumber != null && record.prNumber!.length > 0)
              _paymentDetailRow('#PR', record.prNumber.toString()),
            if (record.paymentMethod.toLowerCase() == 'cash')
              _paymentDetailRow('Amount', record.amount.toString()),
            if (record.paymentMethod.toLowerCase() == 'cash')
              _paymentDetailRow('Currency', record.currency.toString()),
            if (record.paymentMethod.toLowerCase() == 'check')
              _paymentDetailRow('Amount', record.amountCheck.toString()),
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.cancel, color: record.status.toLowerCase() == 'confirmed' ? Colors.red : Colors.grey), // View icon
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentCancellationScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.visibility, color: Colors.blue), // View icon
                  onPressed: () {
                    if (record.id != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentConfirmationScreen(paymentId: record.id!),
                        ),
                      );
                    } else {
                      // Handle the case when record.id is null, e.g., show an error message
                      print('Error: record.id is null');
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: record.status.toLowerCase() == 'confirmed' ? Colors.grey : Colors.blue),
                  onPressed: record.status.toLowerCase() == 'confirmed' ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RecordPaymentScreen(id: record.id)),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: record.status.toLowerCase() == 'confirmed' ? Colors.grey : Colors.red),
                  onPressed: record.status.toLowerCase() == 'confirmed' ? null : () async {
                    // Show a confirmation dialog before deleting
                    bool confirmDelete = await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: Text('Confirm Delete'),
                          content: Text('Are you sure you want to delete this payment record?'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(dialogContext).pop(false); // Return false
                              },
                            ),
                            TextButton(
                              child: Text('Delete'),
                              onPressed: () {
                                Navigator.of(dialogContext).pop(true); // Return true
                              },
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmDelete) {
                      final int id = record.id!;
                      await DatabaseProvider.deletePayment(id);
                      // Update the UI to reflect the deletion
                      setState(() {
                        _paymentRecords.removeWhere((item) => item.id == id);
                      });
                    }
                  },
                ),
              ],
            ),
          ],
          onExpansionChanged: (bool expanded) {
            // Optionally add analytics or state management hooks here
          },
        ),
      ),
    );
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
    //await DatabaseProvider.clearDatabase();
    print("_fetchPayments method in PaymentHistory screen started");
    List<Map<String, dynamic>> payments = await DatabaseProvider.getAllPayments();

    // Print the raw data retrieved from the database


    String? dueDateCheckString ;
    DateTime? dueDateCheck;
    String? lastUpdatedDateString ;
    DateTime? lastUpdatedDate;
    String? transactionDateString ;
    DateTime? transactionDate;
    setState(() {
      _paymentRecords = payments.map((payment) {
        dueDateCheckString = payment['dueDateCheck'];
        lastUpdatedDateString = payment['lastUpdatedDate'];
        transactionDateString = payment['transactionDate'];
        print("before parse the date :");
        print(lastUpdatedDate);
        print(transactionDate);

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
        );
      }).toList();

    });
    print("_fetchPayments method in PaymentHistory screen finished");

  }
}

